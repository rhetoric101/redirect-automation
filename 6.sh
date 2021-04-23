#!/bin/bash

echo "Please enter the directory just above the ones you want to change(with no preceding or trailing slashes):"
read userDirectoryPrefix
directoryPrefix="  - /$userDirectoryPrefix" # create a redirect prefix that can be used by printf.
directoryPrefixSED="  - \/$userDirectoryPrefix\\" #create a parallel redirect prefix that can be used by SED.
echo "Here is prefix: " $directoryPrefix
echo "===================="

IFS=$'\t\n' #Set internal field separator so it ignores spaces in directory names.

# Use shell find command to locate files and paths, but chop off the dot and forward slash at beginning:
directoryArray=($(find . -type f -name "*.mdx" | sed -e "s/^.\///" ))
directoryArrayLength=${#directoryArray[@]}

# Use the same find command to create a paralled array that you can use with SED:
# directoryArraySED=($(find . -type f -name "*.mdx" | sed -e "s/^.\///" ))


echo "Here is directory array length: " $directoryArrayLength
echo "Here is postion 6 before the loop: " ${directoryArray[6]}

echo ""
echo "Are these the files you want to change and redirects to insert?"
echo ""

for (( h=0; h<${directoryArrayLength}; h++ ));

do
    # Create a redirect array that can be used by printf:
    initialRedirect=$(echo "${directoryArray[$h]}" | sed -e "s/.mdx$//")
    finalRedirect="${directoryPrefix}/${initialRedirect}"

    # Create a parallel redirect array that can be processed by SED (escaped forward slashes):
    initialRedirectSED=$(echo "${directoryArray[$h]}" | sed -e "s/\//\\\\\//g" -e "s/.mdx$//")
    finalRedirectSED="${directoryPrefixSED}/${initialRedirectSED}"

    echo "here is the sed initial redirect: " $initialRedirectSED 
    echo "here is the final sed redirect: " $finalRedirectSED
    echo "File to change:  " ${directoryArray[$h]} 
    echo "Redirect to add: " $finalRedirect
    echo ""

    existingRedirect="redirects:"

    if test $(grep "redirects:" "${directoryArray[$h]}")
    then  
      echo "Here is directory array: " ${directoryArray[$h]}
      echo "Here is redirect final: " $finalRedirect
      printf '%s\n' /^redirects:/a $finalRedirect . w q | ex -s ${directoryArray[$h]}
    else
      n=$( sed -n '/^---$/=' ${directoryArray[$h]} | sed -n 2p )
      echo "Here is the value of n:" 
      echo "Hi there! What are you doing here?"
      if test "$n"
      then   
        sed -i -e"" "$n i\\
redirects:\\
$finalRedirect
        " ${directoryArray[$h]}

      else
       echo "n has no value!"
      fi 

    fi

done