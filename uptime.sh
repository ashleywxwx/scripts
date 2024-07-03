#!/bin/sh
# Displays uptime in a nice format for wtfutil

uptime | awk '{print "up: " $3 " days, " $5 "\nload averages: " $10 " " $11 " " $12}'
