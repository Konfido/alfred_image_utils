#!/bin/bash
# --------------------------------------
# Created by carlosnz on 2015-10-06
# Modified by Konfido
# --------------------------------------

#Put incoming into proper tab-delimited variable (for the Finder Selection string)
array=$(echo -e "$1")

#Storage directory for API key
PREFS="$alfred_workflow_data"

#Enable aliases for this script
shopt -s expand_aliases
#Define aliases
alias notify='osascript -e "tell application \"Alfred\" to run trigger \"notify\" in workflow \"$alfred_workflow_bundleid\" with argument \"$message\""'

#Get API key from storage file
if [ ! -e "$PREFS/api_key" ]; then
	API_KEY=ouf63mgbMv_SPTllE5AvolergIQwCgl1 #default API key if it doesn't yet exist
else
	API_KEY=$(cat "$PREFS/api_key")
fi

#Create output folder
mkdir -p "$HOME/Desktop/TinyPNG"

#Setup counters
success=0
fail=0

#Split input query into array
IFS=$'\t'
images=($array)

#Process each element in array
for file in ${images[@]}; do

filename=$(basename "$file")
newfilename=${filename/.png/_shrink.png}
newfilename=${newfilename/.jpg/_shrink.jpg}
newfilename=${newfilename/.PNG/_shrink.PNG}
newfilename=${newfilename/.JPG/_shrink.JPG}

message="Processing $filename..."
notify
echo "FILE: $file" >> "$HOME/Desktop/TinyPNG/~Report~.txt"

#Submit API query
api_result=$(curl -s --user api:$API_KEY --data-binary @"$file" https://api.tinypng.com/shrink)
#If failure
if [[ $api_result = *'error'* ]]; then
	error=$(php parsejson_error.php "$api_result")
	spliterror=($error)
	#Various errors stop immediately
	if [ ${spliterror[0]} = "TooManyRequests" ]; then
		echo "Upload FAILED" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "Code: ${spliterror[0]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "Message: ${spliterror[1]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "ERROR: Monthly limit exceeded."
		exit
	fi
	if [ ${spliterror[0]} = "Unauthorized" ]; then
		echo "Upload FAILED" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "Code: ${spliterror[0]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "Message: ${spliterror[1]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "ERROR: Credentials are invalid."
		exit
	fi
	echo "Upload FAILED" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
	echo "Code: ${spliterror[0]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
	echo "Message: ${spliterror[1]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
	notify "Processing FAILED: $filename"$'\n'"See ~Report.txt for details."
	let fail++
else
	#If successful
	data="$(php parsejson.php "$api_result")"
	splitdata=($data)
	#Download shrunk file
	curl -o "$HOME/Desktop/TinyPNG/$newfilename" "${splitdata[3]}"
	if [ ! $? = 0 ]; then
		echo "Problem downloading $newfilename" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		notify "Processing FAILED: $filename"$'\n'"See ~Report.txt for details."
		let fail++
	else
		#Output report
		echo "Original size: ${splitdata[0]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "Shrunk size: ${splitdata[1]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		echo "Ratio: ${splitdata[2]}" >> "$HOME/Desktop/TinyPNG/~Report~.txt"
		notify "Processing completed successfully:"$'\n'" $filename"
		let success++
	fi
fi
echo >> "$HOME/Desktop/TinyPNG/~Report~.txt"  #Blank line between files

done

#Notify completion
if [ ! $success = 0 ]; then
	if [ $success = 1 ]; then
		suc_files=file
	else
		suc_files=files
	fi
	message="$success $suc_files downloaded to /Desktop/TinyPNG. "
	notify
fi

if [ ! $fail = 0 ]; then
	if [ $fail = 1 ]; then
		fail_files=file
	else
		fail_files=files
	fi
	message="$fail $fail_files had problems."
	notify
fi

message="See ~Report~.txt for details."
notify