#!/usr/bin/env /bin/bash
# ACL rule maker for iptables to block countries
# Optional dependencies: dialog
# Dependencies: ipset
# Change user
SAFE_USER="gdb"

DIR="/home/${SAFE_USER}/.cache/ipblock"
TORRC="/etc/torrc"
FLAG="$1"

# make our cache directory, to hold all of our files
if [ ! -d "${DIR}" ]; then
	mkdir -p "${DIR}"
fi

USAGE() {

	echo """$(basename $0): GeoIP Rule maker for ipset and tor
	Usage: $(basename $0) [-d,-m,-t,-u,-z]
	-g	Open a dialog gui
	-m	Force updating the master file from ipdeny.com
	-t	Update ${TORRC} after making changes to ${DIR}/block.list
	-u      Update ipset, after making changes to ${DIR}/block.list
	-z	Update zonefiles in ${DIR} and apply the changes to ipset"""
}




GUI_DIALOG() {

	if [ $(id -u) == 0 ]; then
		echo "You are not allowed to run this part of the script as root."
		exit 1
	fi

	# Get master list, if the file doesnt exist
	if [ ! -f "${DIR}/master.list" ]; then
		UpdateMaster
	fi

	# Make our default settings, if there is no file
	if [ ! -f "${DIR}/block.list" ]; then
		cp "${DIR}/master.list" "${DIR}/block.list"
	fi

	# Open file descriptor
	exec 3>&1

	# VALUE = COUNTRY_CODE
	VALUES=$(dialog --checklist "Country IP List" 100 100 100 $(cat ${DIR}/block.list) 2>&1 1>&3)

	# Close it
	exec 3>&-

	# Turn off all values first
	#sed 's/on/off/' -i "${DIR}/block.list"
	cp "${DIR}/master.list" "${DIR}/block.list"

	for i in ${VALUES}; do
		LINE=$(grep -n "${i} " "${DIR}/block.list" | cut -d ":" -f1)
		sed "${LINE}s/off/on/" -i ${DIR}/block.list
		# could do this before hand
		#ZONE=$(echo ${i} | tr [:upper:] [:lower:])
		#wget -c http://www.ipdeny.com/ipblocks/data/countries/${ZONE}.zone -O ${DIR}/${ZONE}.zone
	done
	UpdateZone

}

# Updates the master list file from ipdeny.com, shouldnt be edited by a human
UpdateMaster() {

	if [ $(id -u) == 0 ]; then
		echo "You are not allowed to run this part of the script as root."
		exit 1
	fi

	# Remove html tags
	COUNTRIES_LIST=$(wget -q -O - http://www.ipdeny.com/ipblocks/ | grep -o -P '(?<=<td><p>).*(?= \[)')

	# Remove useless parentheses, while making a 2D table
	COUNTRY=$(echo "${COUNTRIES_LIST}" | cut -d "(" -f1)
	CODE=$(echo "${COUNTRIES_LIST}" | cut -d "(" -f2 | cut -d ')' -f1)

	# Get our line count
	COUNTRY_L=$(echo "${COUNTRY}" | wc -l)
	CODE_L=$(echo "${CODE}" | wc -l)

	# Verify if they are both the same, a small failsafe
	if [ ${COUNTRY_L} == ${CODE_L} ]; then
		# counter
		c=1
		# while loop until counter = line count
		while [ ${c} -le ${CODE_L} ]; do
			# Loop through each entry in the Country Code and the Country
			arr[$c]="$(echo $(echo "${CODE}" | head -n ${c} | tail -n1 | sed 's/VATICAN CITY STATE/VA/') $(echo "${COUNTRY}" | head -n ${c} | tail -n1 | tr [:space:] _) 0)"
			c=$[$c+1]
        	done

	else
		EXIT
	fi
	# copy the contents of the array, make it human readable
	echo ${arr[@]} | sed -e 's/0 /off\n/g' -e 's/  / /g' > "${DIR}/master.list"

}

# Download the zone files
UpdateZone() {

	if [ $(id -u) == 0 ]; then
		echo "You are not allowed to run this part of the script as root."
	fi

	for i in $(grep "on" "${DIR}/block.list" | cut -d " " -f1 | tr [:upper:] [:lower:]); do

		if [ ! -f "${DIR}/${i}.zone" ];then
			wget -q -c http://www.ipdeny.com/ipblocks/data/countries/${i}.zone -O "${DIR}/${i}.zone"
		fi
	done
}

CreateIpSet() {

	if [ ! $(id -u) == 0 ]; then
		echo "Please run as root to make changes"
        	exit 1
	fi
	[[ $(which ipset 2> /dev/null) ]] || $(echo "Please install ipset first" && exit 1)
	SETNAME="GeoIpACL"
	ipset destroy ${SETNAME}

	# Create our setname, if it doesnt exit
	[[ $(ipset list ${SETNAME} 2>/dev/null) ]] || ipset create ${SETNAME} hash:net
	for CODE in $(grep "on" "${DIR}/block.list" | cut -d " " -f1 | tr [:upper:] [:lower:]); do
		for ENTRY in $(cat ${DIR}/${CODE}.zone); do
			ipset add ${SETNAME} ${ENTRY}
		done
	done


	ipset save > /etc/ipset.conf
	iptables -I INPUT -m set --match-set myset src -j DROP

}

CreateTorSet() {

	if [ ! $(id -u) == 0 ]; then
		echo "Please run as root to make changes"
		exit 1
	fi

	NODES=$(grep "on" "${DIR}/block.list" | cut -d " " -f1 | tr [:upper:] [:lower:] | sed 's/^/{/' | tr '\n' ',' | sed -e 's/,/},/g' -e '$s/,$//')

	if [ ! -f ${TORRC} ]; then
		touch ${TORRC}
	fi
	# Check if the current setting exists, if so, change it. if not make it
	[[ $(grep "^ExcludeNodes" ${TORRC}) ]] && sed -i "s/^ExcludeNodes.*$/ExcludeNodes ${NODES}/" ${TORRC} || echo "ExcludeNodes ${NODES}" >> ${TORRC}

	exit 0
}

EXIT() {
	echo "BORKED"
	exit 1
}


case "${FLAG}" in
	"-g")
		if [ ${COUNTRY_L} == ${CODE_L} ]; then
			GUI_DIALOG
		else
			EXIT

		fi


		exit 0
        ;;

	"-m") UpdateMaster;;

	"-t") CreateTorSet;;

	"-u") CreateIpSet;;

	"-z") UpdateZone;;

	*) USAGE; exit 1;;
esac





