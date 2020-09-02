#!/bin/bash
# --------------------------------------
# Created by carlosnz on 2014-03-18
# Modified by Konfido
# --------------------------------------

#Enable aliases for this script
shopt -s expand_aliases
#define aliases
alias notify='osascript -e "tell application \"Alfred\" to run trigger \"notify\" in workflow \"$alfred_workflow_bundleid\" with argument \"$message\""'

# Get Finder selection
selected=$(osascript <<EOF
tell application "Finder"
	set finderSelList to selection as alias list
end tell

if finderSelList ≠ {} then
	repeat with i in finderSelList
		set contents of i to POSIX path of (contents of i)
	end repeat

	set text item delimiters of AppleScript to linefeed
	finderSelList as text
end if
EOF
)

if [ -z "$selected" ]; then
	message="Nothing selected."
	notify
	exit
else
	message="testing..."
	notify
fi

# Replace \n with \t
output="$(echo "$selected" |tr '\n' '\t')"

#Send array string to main script
./tinypng.sh "$output"