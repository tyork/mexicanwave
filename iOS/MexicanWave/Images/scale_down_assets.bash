#!/bin/bash

if [ "$#" == "0" ]; then

  echo 'Take in specified double-res images and scale them to standard res, creating new files in the process (not for production use)'
  echo './scale_down_assets *@2x.png'
  $(exit 1)

else

  for input_image in "$@"; do   
	output_image=${input_image/@2x/}
	echo "Creating $output_image from $input_image"
	convert $input_image -scale 50% $output_image
  done

fi
