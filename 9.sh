#!/bin/bash

echo "Starting with /docs, type the path up to and including the directory you are in."
echo "For example, if you are running this script in the agent directory to "
echo "change all the agent's child mdx files, type this: /docs/agents/"
read userDirectoryPrefix
echo
echo "Do you want to change redirects for all the files"
echo "below this path [y/n]:? $userDirectoryPrefix"

read yesNo

case $yesNo in
  [Yy]* )
    echo "OK, let's change some redirects!"
    ;;
  [Nn]* )
    echo "OK, we stopped the script!"
    exit;;
esac

directoryPrefix="  - $userDirectoryPrefix" # create a redirect prefix that can be used by printf.
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
    finalRedirect="${directoryPrefix}${initialRedirect}" # Removed forward slash as test.

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
      # Insert the new redirect at the top of the list of existing redirects:
      echo "Here is directory array: " ${directoryArray[$h]}
      echo "Here is redirect final: " $finalRedirect
      printf '%s\n' /^redirects:/a $finalRedirect . w q | ex -s ${directoryArray[$h]}
      echo -e "$finalRedirect\n" >> redirects-to-test.txt
    else
      # Insert a new redirect section and add the new redirect below it.
      n=$( sed -n '/^---$/=' ${directoryArray[$h]} | sed -n 2p )
  
      if test "$n"
      then   
        sed -i '' -e "$n i\\
redirects:\\
$finalRedirect
        " ${directoryArray[$h]}
        echo -e "$finalRedirect\n" >> redirects-to-test.txt 
      else
       echo "n has no value!"
      fi 

    fi

done