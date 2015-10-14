#!/usr/bin/env bash
#*****************************************************************#
#*  Monuting defCon images
#*  author: Tomas Trnka         email:trnkato2@fel.cvut.cz       
#*****************************************************************#

if [ $# -lt 3 ]; then
	echo "You must specify at least 3 parameters" >&2
	echo "Try ${0} -h for more informations" >&2
	exit 1
fi

#initializing flags
v=""
m="/mnt/defCon"
p=""
u=0

#processing input agruments using getopts
while getopts "hv:m:p:u" opt; do
  case $opt in
	v)
			v="$OPTARG";;
	m)
			m="$OPTARG";;
	p)
			p="$OPTARG";;
	u)
			u=1;;
	h) 
			echo "Usage: ${0} -p file_with_passwords -v first_crypto_volume [-m mount_point] "
			echo "commands:"
			echo "-v	the file with cryptographic volume"
			echo "-m	mount point, default set to /mnt/defCon"
			echo "-p	file with passwords, passwords should be each on a new line"
			echo "-u    unmounts all mounted volumes"
			echo "-h	this help..."
			exit 1;;
	esac
done

prefix="Round"

if [ $u -gt 0 ]; then
	echo "Unmounting all mounted volumes"
	truecrypt -d	
	exit
fi

#solve the problem with file names with whitespaces
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ -f $p ]; then
	readarray a < $p
	counter=1

	for item in "${a[@]}"; do
		#echo $item

		# Test whether moutn point exists
		if ! [ -d "${m}/Round${counter}" ]; then
				sudo mkdir -p "${m}/Round${counter}"
				echo "Creating mountpoint ${m}/Round${counter}"
		fi

		# Mount parent folder
		if [ -f $v ];  then
			truecrypt --password=$item $v "${m}/Round${counter}"
			echo "Mounting volume $v at ${m}/Round${counter}"
			v="${m}/Round1/Contest/"			
		fi
		# Mount consecutive rounds
		if [ -d $v ] && [ $counter -gt 1 ] ; then
			truecrypt --password=$item "${v}/Round${counter}.tc" "${m}/Round${counter}"
			echo "Mounting volume ${v}${counter}.tc at ${m}/Round${counter}"	
		fi

		let counter=counter+1
	done
else
	echo "No file with passwords found. Program will exit"
fi

IFS=$SAVEIFS
exit




