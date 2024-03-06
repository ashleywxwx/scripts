#!/bin/zsh

# This is a simple script to print a message one character at a time,
# with a delay between each character, to simulate a "typing" effect,
# just like in the movies and video games.
#
# Usage:
#
#   zsh welcome.zsh
#   zsh welcome.zsh --delay 0.05 --message "Hello, World!"
#	zsh welcome.zsh -d 0.05 -m "Hello, World!"

MESSAGE="Welcome Back, Commander"
DELAY=0.02

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		-d|--delay)
			DELAY=$2
			shift
			shift
			;;
		-m|--message)
			MESSAGE=$2
			shift
			shift
			;;
		*)
			echo "Unknown option: $1"
			exit 1
			;;
	esac
done

for (( i=0; i<${#MESSAGE}; i++ )); do
    printf "%s" "${MESSAGE:$i:1}"
    sleep $DELAY
done
printf "\n"
