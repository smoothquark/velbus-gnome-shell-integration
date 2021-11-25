#!/usr/bin/env bash

# Gnome Shell Integration for Velbus

# Requires Argos Gnome Shell Extension
# (https://extensions.gnome.org/extension/1176/argos)
# install in ~/.config/argos/

# Idea from yoshi (https://community.openhab.org/t/control-openhab-via-gnome-shell-linux-macos-menu-bar-argos-bitbar/27585)

# Change as required
OPENHAB_SERVER="dietpi"
ROOM="Office"

# Room Items
ROOM_LIGHTS=p${ROOM// /}_Lights
ROOM_THERM_CURRENT=p${ROOM// /}_CurrentTemperature
ROOM_THERM_MODE=p${ROOM// /}_ThermostatMode

# Icons
ICONS_CACHE=$HOME/.config/argos/.cache-icons			# cache
ICONS_OPENHAB="https://www.openhab.org/iconsets/classic"	# openHAB icons

# REST API
REST_HEADER_ACCEPT="Accept: text/plain"
REST_HEADER_CONTENT="Content-Type: text/plain"
REST_URL="http://$OPENHAB_SERVER:8080/rest"
REST_URL_ITEMS="$REST_URL/items"

get_icon() {
	ICON="$1.png"
	ICON_LOCAL="$ICONS_CACHE/$ICON"
	ICON_REMOTE="$ICONS_OPENHAB/$ICON"
	if [ ! -f "$ICON_LOCAL" ]
	then
		curl -o "$ICON_LOCAL" "$ICON_REMOTE"
	fi
	curl -s "file://$ICON_LOCAL" | base64 -w 0
}

state_get() {
	c_url="$REST_URL_ITEMS/$1/state"
	curl -s -X GET "$c_url" -H "$REST_HEADER_ACCEPT"
}

state_post() {
	c_url="$REST_URL_ITEMS/$1"
	curl -s -X POST "$c_url" -d "$2" -H "$REST_HEADER_ACCEPT" \
						-H "$REST_HEADER_CONTENT"
}

therm_mode() {
	state_post "$ROOM_THERM_MODE" "$1"
}

toggle_lights() {
	state_post "$ROOM_LIGHTS" "TOGGLE"
}

# script can be run as an Argos script or if a parameter is given, run within
# an Argos script
if [ "$1" ]
then
	"$1" "$2"
	exit
fi

# icon cache folder
mkdir -p "$ICONS_CACHE"

# icons
ICON_LIGHT_OFF=$(get_icon "light-off")
ICON_LIGHT_ON=$(get_icon "light-on")

# Get Room Item states
ROOM_STATE_LIGHTS=$(state_get "$ROOM_LIGHTS")
ROOM_STATE_LIGHTS_ICON="ICON_LIGHT_"$ROOM_STATE_LIGHTS
ROOM_STATE_LIGHTS_ICON=${!ROOM_STATE_LIGHTS_ICON}
ROOM_STATE_THERM=$(state_get "$ROOM_THERM_CURRENT")
ROOM_STATE_THERM_MODE=$(state_get "$ROOM_THERM_MODE")
ROOM_STATE_THERM_VALUE=${ROOM_STATE_THERM/ */}
ROOM_STATE_THERM_VALUE=$(printf "%.1f\n" $ROOM_STATE_THERM_VALUE)
ROOM_STATE_THERM_UNITS=${ROOM_STATE_THERM/* /}

if [ "$ROOM_STATE_LIGHTS" == "ON" ]
then
	LIGHTS_TOGGLE="Off"
else
	LIGHTS_TOGGLE="On"
fi

# Set up output text
ROOM_TEXT_OUTPUT=""
ROOM_TEXT_OUTPUT+="$ROOM - Temp: "
ROOM_TEXT_OUTPUT+="$ROOM_STATE_THERM_VALUE $ROOM_STATE_THERM_UNITS "
ROOM_TEXT_OUTPUT+="($ROOM_STATE_THERM_MODE Mode)"

# Script path
SCRIPT=$(readlink -f "$0")
TERM="terminal=false"

# Display output and menu
echo "$ROOM_TEXT_OUTPUT | image='$ROOM_STATE_LIGHTS_ICON' imageWidth=16"
echo "---"
echo "Turn $LIGHTS_TOGGLE Lights | bash='$SCRIPT toggle_lights' $TERM"
echo "Set Thermostat to Comfort Mode | bash='$SCRIPT therm_mode COMFORT' $TERM"
echo "Set Thermostat to Day Mode | bash='$SCRIPT therm_mode DAY' $TERM"
echo "Set Thermostat to Night Mode | bash='$SCRIPT therm_mode NIGHT' $TERM"
echo "Set Thermostat to Safe Mode | bash='$SCRIPT therm_mode SAFE' $TERM"
