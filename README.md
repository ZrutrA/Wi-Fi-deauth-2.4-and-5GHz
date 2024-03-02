# Wi-Fi-deauth-2.4-and-5GHz
Wi-Fi deauth attack 2.4 GHz and 5 Ghz

## About this project
This is a bash script for Linux. I provide versions in English and Polish.

Enables a deauthentication attack on a Wi-Fi network. It combines two attack methods: on the network operating at 2.4 GHz and on the 5 GHz network. You can only perform one type of attack at a time.

Tworząc skrypt korzystałem z artykułów:

a) Wi-Fi 2.4GHz: https://sudorealm.com/blog/deauthentication-attack-using-kali-linux

b) Wi-Fi 5Ghz: https://blog.spacehuhn.com/5ghz-deauther 

## Disclaimers

The project is of a testing and educational nature. Only use it legally. I am not responsible for what you do with this program.

The script works fine on my device. Editing and changes to the script may be necessary on your device. You have to face this on your own!

## My hardware and software

1) Raspberry Pi 4B

https://www.raspberrypi.com/products/raspberry-pi-4-model-b/

2) Kali linux

https://www.kali.org/

3) Alpha Network Wi-Fi card model AWUS036AC

https://www.alfa.com.tw/products/awus036ac

Your WiFi card must have the MONITOR MODE function.

## System requirements

You must have aircrack-ng installed (in Kali Linux it is already installed by default):

sudo apt-get install aircrack-ng

## Activation

1) Download the script file deauth5and24ghz-en.sh (English) or deauth5and24ghz-pl.sh (Polish).

2) Open the console and log in as administrator by typing the command

sudo su

3) run the script:

./deauth5and24ghz-en.sh

or

./deauth5and24ghz-pl.sh

## Working with the script

1) Displaying available WiFi interfaces

2) Asking the user to select an interface

2) Starting monitor mode for the selected card. Your Wi-Fi connections will stop.

3) Asking the user what type of network to scan. What network do you want to scan? (1 - 2.4 GHz, 2 - 5 GHz)?

4) It will scan and display available Wi-Fi networks. The BSSID and channel will be visible there. Stop scanning by pressing CTRL + C.

5) Query the user for the network's BSSID

6) User query for network channel

7) Listening to the selected network on the selected channel. You will see how many active devices are connected to the AP. Stop listening by pressing CTRL + C.

8) Specify the deauthentication attack execution time (in seconds).

9) A deauthorization attack is in progress for the selected Wi-Fi network. The attack occurs in series of 10. Stop the attack by pressing the 'K' key. If the attack time specified by the user expires, the attack will be automatically interrupted (without having to press the "K" key).

10) After stopping the attack, monitor mode for the selected card will be automatically stopped and normal operation of the WiFi network will be restored.
