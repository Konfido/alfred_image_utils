#!/bin/bash
# --------------------------------------
# Created by carlosnz on 2015-10-06
# Modified by Konfido
# --------------------------------------


# Create output folder
mkdir -p "$HOME/Desktop/TinyPNG"

# Enable aliases for this script
shopt -s expand_aliases
# Define aliases
alias notify='osascript -e "tell application \"Alfred\" to run trigger \"notify\" in workflow \"$alfred_workflow_bundleid\" with argument \"$message\""'
# Local log
report="$HOME/Desktop/TinyPNG/~Report~.txt"
# Storage directory for API key
PREFS="$alfred_workflow_data"
# Get API key from storage file
if [ ! -e "$PREFS/api_key" ]; then
	API_KEY=ouf63mgbMv_SPTllE5AvolergIQwCgl1 #default API key if it doesn't yet exist
else
	API_KEY=$(cat "$PREFS/api_key")
fi

# Setup counters for multi-images processing
success=0
fail=0

# Get configs interactively
if [ "$option" = "resize" ]; then
method=$(osascript <<EOF
choose from list {"scale", "fit", "cover", "thumb"} with title "Names" with prompt "Please select an option:" default items {"Compress"}
EOF
)
imgWidth=$(osascript <<EOF
text returned of (display dialog "Please input width of the image" default answer "600")
EOF
)
imgWidth=$(echo "$imgWidth" | bc) # Change to int
printf "method: %s" "\n$method" 1>&2
echo "imgWidth: $imgWidth" 1>&2
if [ -z "$imgWidth" ]; then
	osascript -e 'display notification with title "Quit for no valid input." '
	exit 1
fi
fi

# Function used to parse error message
parse_error(){
    error=$(php parsejson_error.php "$1")
	spliterror=("$error")
	# Various errors stop immediately
	if [ ${spliterror[0]} = "TooManyRequests" ]; then
		echo "Upload FAILED" >> "$report"
		echo "Code: ${spliterror[0]}" >> "$report"
		echo "Message: ${spliterror[1]}" >> "$report"
		echo "ERROR: Monthly limit exceeded."
		exit
	fi
	if [ ${spliterror[0]} = "Unauthorized" ]; then
		echo "Upload FAILED" >> "$report"
		echo "Code: ${spliterror[0]}" >> "$report"
		echo "Message: ${spliterror[1]}" >> "$report"
		echo "ERROR: Credentials are invalid."
		exit
	fi
	echo "Upload FAILED" >> "$report"
	echo "Code: ${spliterror[0]}" >> "$report"
	echo "Message: ${spliterror[1]}" >> "$report"
	message="Processing FAILED: $filename"$'\n'"See ~Report.txt for details."
	notify
}

# From Finder selection string to tab-delimited variables
array=$(echo -e "$1")
# Split input query into array
IFS=$'\t'
images=($array)

# --------------------------------------
# Start processing each image in array
# --------------------------------------
for file in ${images[@]}; do
	filename=$(basename "$file")
	name_shrunk=${filename/.png/_shrink.png}
	name_shrunk=${name_shrunk/.jpg/_shrink.jpg}
	name_resized=${filename/.png/_resize.png}
	name_resized=${name_resized/.jpg/_resize.jpg}

	message="Processing $filename..."; notify
	echo "FILE: $file" >> "$report"

	# Submit API query
	compress_result=$(curl https://api.tinypng.com/shrink \
		--user api:$API_KEY \
		--data-binary @"$file" -s)
	echo "$compress_result" 1>&2
	# Compressing failed
	if [[ $compress_result = *'error'* ]]; then
		parse_error "$compress_result"
		let fail++

	# Compressing succeed
	else
		echo "$compress_result" 1>&2
		data="$(php parsejson.php "$compress_result")"
		splitdata=($data)
		url_shrunk=${splitdata[3]}
		echo "URL: $url_shrunk" >> "$report"

		# ------------------------------
		# Compress images
		# ------------------------------

		# Download shrunk file
		curl "$url_shrunk" -o "$HOME/Desktop/TinyPNG/$name_shrunk"
		if [ ! $? = 0 ]; then
			echo "Problem downloading $name_shrunk" >> "$report"
			message="Processing FAILED: $filename"$'\n'"See ~Report.txt for details."; notify
			let fail++
		else
			# Output report
			echo "Original size: ${splitdata[0]}" >> "$report"
			echo "Shrunk size: ${splitdata[1]}" >> "$report"
			echo "Ratio: ${splitdata[2]}" >> "$report"
			message="Compressing completed:"$'\n'"$filename"; notify
			let success++
		fi

		# ------------------------------
		# Resize images
		# ------------------------------
		if [ "$option" = 'resize' ]; then
			resize_result=$(curl "$url_shrunk" \
    			--user api:$API_KEY --header "Content-Type: application/json" \
    			--data "{\"resize\":{\"method\": \"$method\", \"width\":$imgWidth, \"height\":$imgWidth }}" \
    			--dump-header /dev/stdout --silent \
    			--output "$HOME/Desktop/TinyPNG/$name_resized")
			echo "resize_result: $resize_result" 1>&2
			# Resizing failed
			if [[ $resize_result = *'error'* ]]; then
				parse_error "$resize_result"
			# Resizing succeed
			else
				printf "%s (%s) imgWidth: %s" "$option" "$method" "$imgWidth" >> "$report"
				message="Resizing completed:"$'\n'"$filename"; notify
			fi
		fi
	fi

	# Blank line between files
	echo >> "$report"
	echo >> "$report"
done

# Notify completion
if [ ! $success = 0 ]; then
	if [ $success = 1 ]; then
		suc_files=file
	else
		suc_files=files
	fi
	message="$success $suc_files downloaded to /Desktop/TinyPNG. "; notify
fi

if [ ! $fail = 0 ]; then
	if [ $fail = 1 ]; then
		fail_files=file
	else
		fail_files=files
	fi
	message="$fail $fail_files had problems."; notify
fi

message="See ~Report~.txt for details."; notify