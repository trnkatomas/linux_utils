#!/usr/bin/env bash
#*****************************************************************#
#*  Shell thumbnailing the images
#*  author: Tomas Trnka         email:trnkato2@fel.cvut.cz       
#*****************************************************************#

if [ $# -lt 1 ]; then
	echo "${0} : you must specify at least one parameter" >&2
	echo "Try ${0} --help, -h for more informations" >&2
	exit 1
fi

#initializing flags
f=0
d=0
s=300

#processing input agruments using getopts
while getopts "hf:d:s:qwn:" opt; do
  case $opt in
	f)
			f="$OPTARG";;
	n)
			n="$OPTARG";;
	s)
			s="$OPTARG";;
	q)
			q=true;;	
	w)
			w=true;;
	d)
			d="$OPTARG";;
  	h) 
			echo "Usage: ${0} [-f tar file] [optional command]"
			echo "commands:"
			echo "-s	set the bigger size of thumbnail"
			echo "-d	set the folder you would like to thumbnail"
			echo "-f	set the file to thumbnail"
			echo "-q	set the thumbnail to square"
			echo "-w	compress quality to web (75%)"
			exit 1;;
	esac
done

#solve the problem with file names with whitespaces
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ -f $f ]; then
	echo "Thumbnailing file $i ...."
	if [ $n ]; then
		filename=$(basename "$f")
		extension="${filename##*.}"
		filename="${filename%.*}"
		new_name=$n.$extension
	else
		new_name="thumb_${f}"
	fi
	convert -thumbnail $s $f $new_name #thumb_${f}
fi

if [ -d $d ];  then
	cd $d
	out=$(echo Today is $(date))
	echo $out
	files="""$(ls * | egrep -i ".jp(e?)g$|.png$|.gif$")"""
	#echo $files
	for i in $files; do
		echo "Thumbnailing file $i ...."
		#filename="${i%.*}"
		#extension="${i##*.}"
		#echo $filename $extension
		#convert -thumbnail $s $i thumb_$i
		if [ $q ]; then
			convert $i -thumbnail ${s}x${s}^ -gravity center -extent ${s}x${s} thumb_${i}
		else
			convert -thumbnail $s $i thumb_${i}
			if [ `identify -format '%[exif:orientation]' $i` -eq 6 ]; then
				convert -rotate 90 thumb_${i} thumb_${i}
			fi
            if [ `identify -format '%[exif:orientation]' $i` -eq 8 ]; then
				convert -rotate -90 thumb_${i} thumb_${i}
			fi
			if [ $w ]; then
				imgWeb -f thumb_${i} -q 75
			fi
		fi
	done
fi

echo "##########################################################"
IFS=$SAVEIFS



