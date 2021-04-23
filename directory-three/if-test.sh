#! /bin/bash

# if [ ! -z $(grep "Ted" file) ]

if test $(grep "Ted" file)
then
  echo "I expect Ted!"
else
  echo "I do not expect Ted"
fi
