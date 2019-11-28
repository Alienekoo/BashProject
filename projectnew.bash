#!/bin/bash
#!Take Username or userid and verify if it's in /etc/passwd
#! clearing last run data
touch executable_files.txt
rm executable_files.txt
touch executable_files.txt
#! ====================================================================================
#!Funcrions go here
Directorycheck()
{
if [[ $# -eq 1 ]]
	then
	path=$1
else
	path=$1/$2
fi

ls -al $path > directoryfiles.txt

while read -r perm var username groupname size month date year filename
do

#echo Im inside IFS loop
if [[ "$username" == "$uid" ]]
then
	if [[ "${perm:3:1}" == "x" || "${perm:3:1}" == "s" ]]
	then
		echo "$path/$filename $perm $username $groupname $size $month $date $year $filename:UY">> executable_files.txt
    #userid is matching with username, but does not have execute access
	else
        echo "$directorypath/$filename $perm $username $groupname $size $month $date $year $filename:UN">> executable_files.txt
	fi
else
#the username doesnot match so checking only group name
if [[ "$groupname" == "$gid" ]]
     then
                if [[ "${perm:6:1}" == "x" || "${perm:6:1}" == "s" ]]
                then
                        echo "$path/$filename $perm $username $groupname $size $month $date $year $filename:GY">> executable_files.txt
                else
                        echo "$directorypath/$filename $perm $username $groupname $size $month $date $year $filename:GN">> executable_files.txt
                fi
else
                if [[ "${perm:9:1}" == "x" || "${perm:9:1}" == "t" ]] 
          
   		then
                         echo "$path/$filename $perm $username $groupname $size $month $date $year $filename:OY">> executable_files.txt
                else
                         echo "$path/$filename $perm $username $groupname $size $month $date $year $filename:ON">> executable_files.txt
                fi
    fi
fi

done < directoryfiles.txt

while read -r perm var username groupname size month date year filename
do
if [[ $var -eq 2 && $filename != "." ]]
then
	echo I am in directory perm  of $filename
	
     	Directorycheck $path $filename
fi
done < directoryfiles.txt

}

# ============================================================================================================================================================================================

if [[ $# -eq 0 ]]
then
	echo Enter the username or user id you want to search: 
	read uid
else
	uid=$1
fi

cut -d : -f1,4 /etc/passwd > userpasswd.txt

while [[ true ]]
	do

		if grep -q ^$uid[:] "userpasswd.txt" || grep -q [:]$uid$ "userpasswd.txt" 
			then 
			#! the entered uid is valid
				echo The username or user id is valid.
				break 
	
			else
				echo The entered username or user id is invalid. Please enter again.
				read uid
		fi
	done

#!Take groupname or group id and verify if it's in /etc/passwd
if [[ $# -le 1 ]]
then 

	echo Enter the groupname or group id you want to search: 
	read gid
else 
       gid=$2
fi

cut -d : -f1,3 /etc/group > usergroup.txt

while [[ true ]]
do

	if grep -q ^$gid[:] "usergroup.txt" || grep -q [:]$gid$ "usergroup.txt" 
		then 
			#! the entered uid is valid
			echo The groupname or group id is valid. 
			#! Checking if the user belongs to the group (make a function if time permits)
			#! get the id of the uid and grep for the gid to confirm
			id -Gn "$uid" > idnames.txt
			id -G "$uid" > ids.txt
			if grep -q "$gid" idnames.txt  || grep -q "$gid" ids.txt
				then 
					echo The username belongs to the given group
					break
				else
					echo Please enter the gid that the user belongs to. 
					read gid
					continue
		
			fi
	
		else
			echo The entered groupname or group id is invalid. Please enter again.
			read gid
	fi
done	

#! If the user entered user id or group id, convert it into username or groupname. (make functions if time)

if [[ "$uid" =~ ^[0-9]+$ ]]
	then
		#! if the enetered value are numbers => user id. So converting it into username. 
		grep $uid userpasswd.txt > users.txt
		awk -F: '{print $1}' users.txt > names.txt
		#! the username column(1) is saved into names.txt. Just in case there are multiple usernames for a single user id. 
		uid=$(head -n 1 names.txt)
		rm users.txt
		rm names.txt
	
	fi

if [[ "$gid" =~ ^[0-9]+$ ]]
	then
		grep $gid usergroup.txt > groups.txt
		awk -F: '{print $1}' groups.txt > groupnames.txt
		gid=$(head -n 1 groupnames.txt)
		rm groups.txt
		rm groupnames.txt
	fi


#!Get the directory for which we need to check the permissions of its files/sub-directories
#! Validate the directory (make a function if time permits)
if [[ $# -eq 3 ]]
then 
	directorypath=$3
else
	echo Please enter the absolute path of the directory 
	read directorypath
fi

while [[ true ]]
do 
	if [[ -e $directorypath ]]
		then
				echo The path exists 
				break
		else	
				echo Invalid path. Please enter the correct absolute path: 
				read directorypath
	fi
done

#! Remove any extra / in the end of the path as ls -al will not work otherwise. (another function)

if [[ "${directorypath: -1}" == "/" ]]
	then
		directorypath=${directorypath::-1}
		echo $directorypath
fi

#! ls -al the files in the directory, save in a file and check their permissions and give output as per them. 

#! Trying out IFS method with while loop to read each line of directoryfiles.txt as different variables and checking permisions for each line (= each file)

Directorycheck $directorypath

echo Please check the files and their permisssions in  executable_files.txt  in the folder. 
#! remove all the extra files and trap exit
trap "rm -r userpasswd.txt usergroup.txt idnames.txt ids.txt directoryfiles.txt" EXIT 



































