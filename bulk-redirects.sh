#!/bin/bash
########################################################################
# bulk-redirects.sh
#
# DESCRIPTION
# The purpose of this script is to make bulk redirect changes easier and more accurate.
# When you want to move an entire directory to somewhere else in the taxonomy,
# you can use this script as part of a two step process:
#   1. Before you move any directories, run this script to add the current redirects.
#   2. After you run the script, manually move the directories to wherever you want them.
#
# INSTRUCTIONS
# To use this script:
#   1. Copy this script into the top-level directory containing the files to change.
#      For example, to create redirects for all the files in and under the "agents" 
#      directory, insert this script in the "agents" directory.
#   2. Open a command-line session and go to the directory where you copied this script.
#   3. Execute the script: bash bulk-redirects
#   4. At the prefix prompt, enter /docs/ followed by all the directories to reach your current directory.
#      For example, if you put the script in "agents" you would enter the prefix "/docs/agents/"
#      WARNING: Don't forget to include the leading and training forward slashes!
#   5. At the confirmation prompt, enter "y" to continue.
#      NOTE: If you no longer want to run the script, click CTRL+C to quit.
#   6. When the script completes, copy the file "redirects-to-test.txt" to a safe place.
#   7. Move the directories, rebuild the site, and test each of the redirects in "redirects-to-test.txt." 
# 
# HISTORY: 
# Version  Who                When          What
# -------  -----------------  ------------  -----------------------------------------
#    1     Rob Siebens        04/28/2021    Created script
########################################################################

echo "Starting with /docs, type the path up to and including the directory you are in."
echo "For example, if you are running this script in the agent directory to "
echo "change all the agent's child mdx files, type this: /docs/agents/"
echo

while read -p 'Enter directory prefix: ' userDirectoryPrefix && [[ ! $userDirectoryPrefix =~ (^/.*/$)  ]] 
do
  echo "Oops! It looks like you're missing a forward slash somewhere in your path."
  echo 
done

echo "Do you want to change redirects for all the files"
echo "below $userDirectoryPrefix [y/n]? "
read yesNo
    case $yesNo in
      [Yy]* )
        echo "OK, give me a moment to insert those redirects!"
        echo
        ;;
      [Nn]* )
        echo "OK, we bailed out of the script and didn't do anything!"
        exit;;
    esac
   
directoryPrefix="  - $userDirectoryPrefix" # create a redirect prefix that can be used by printf.
directoryPrefixSED="  - \/$userDirectoryPrefix\\" #create a parallel redirect prefix that can be used by SED.

IFS=$'\t\n' #Set internal field separator so it ignores spaces in directory names.

# Use shell find command to locate files and paths, but chop off the dot and forward slash at beginning:
directoryArray=($(find . -type f -name "*.mdx" | sed -e "s/^.\///" ))
directoryArrayLength=${#directoryArray[@]}

# Use the same find command to create a paralled array that you can use with SED:
# directoryArraySED=($(find . -type f -name "*.mdx" | sed -e "s/^.\///" ))

for (( h=0; h<${directoryArrayLength}; h++ ));

do
    # Create a redirect array that can be used by printf:
    initialRedirect=$(echo "${directoryArray[$h]}" | sed -e "s/.mdx$//")
    finalRedirect="${directoryPrefix}${initialRedirect}" # Removed forward slash as test.

    # Create a parallel redirect array that can be processed by SED (escaped forward slashes):
    initialRedirectSED=$(echo "${directoryArray[$h]}" | sed -e "s/\//\\\\\//g" -e "s/.mdx$//")
    finalRedirectSED="${directoryPrefixSED}/${initialRedirectSED}"

    existingRedirect="redirects:"

    if [[ $(grep "^redirects:$" "${directoryArray[$h]}") ]]  # Is there an exisitng redirects entry?
    then  
      # Insert the new redirect at the top of the list of existing redirects: 
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
      fi 

    fi

done

echo "You can find a list of redirects in this file: redirects-to-test.txt"
echo "After you move the directory, test the redirects in your build."