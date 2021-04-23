path=/some/kind/of/directory/path
n=$( sed -n '/^---$/=' file | sed -n 2p )
sed -e "$n i\\
redirects:\\
 - $path
" file
echo "Here is the value of n:" $n
