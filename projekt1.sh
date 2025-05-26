#!/bin/bash

#grupa1

#utworzy X kont użytkowników o nazwach user1..…userX o haśle : passwordX. Po utworzeniu każdego konta ma pojawić się informacja np. user1 utworzono, user2 utworzono... Po dodaniu do grup, program ma wyświetlić info: user1 dodano do grupy mazwagrupy itd. Pierwszą połowę userów (od 1 do X/2) przypisz do grupy studenci_informatyki, a drugą (X/2+1 - X) do studenci_etyki. Skrypt ponadto wyświetla [na życzenie a nie z automatu] konta, grupy i ich zawartość.

#grupa 2
#a.przypisze dla karty sieciowej przewodowej i bezprzewodowej :
#i.IP, maskę , bramę, dns – według potrzeb administratora
#ii. IP, maskę , bramę, dns - automatycznie
#iii. Jeżeli, któryś z powyższych interfejsów sieciowych nie istnieje w urządzeniu program ma wygenerować stosowany komunikat.
#b.Wykorzysta programy sieciowe [ip a, ping, traceroute, ipconfig, ufw, netstat …]
#c.Wyświetla informacje o ustawieniach sieciowych w systemie
#Program może zapisywać konfigurację sieci w pliku, aby w przyszłości można było ją łatwo przywrócić.

#grupa 3
# Zliczy i wyświetli: konta i grupy użytkowników. Program ma również menu, w którym wybieramy czynność do wykonania. Przykładowe czynności to :
#Dodawanie, usuwanie i modyfikowanie użytkowników.
#Dodawanie, usuwanie i modyfikowanie grup.
#Wyświetlanie wszystkich użytkowników i grup oraz ich zawartości.
#Modyfikowanie nazw użytkowników i grup.
menuZadanie1(){

while true; do
echo "Program do administrowania systemem"
echo ""
echo "1) Dodawanie x ilosci uzytkownikow"
echo "2) Wyswietl konta, grupy i zawartosc uzytkownikow"
echo "3) Wyjście do menu"
read -p "Wybierz opcje [1-3]: " opcja


	case $opcja in 
		1)
		
		zadanie11
		;;
		2)
		clear
		zadanie12
		;;
		3)
		clear
		return
		;;
		*)
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	echo ""
done
}

zadanie11(){
echo "Tworzenie x ilości użytkowników o nazwie user[1-x] o haśle password[1-x]"
sudo groupadd -f studenci_informatyki
sudo groupadd -f studenci_etyki
while true; do
read -p "ile użytkowników chciałbyś stworzyć? :" ilosc

if [[ "$ilosc" =~ ^-?[0-9]+$ ]]; then
    if (( ilosc >= 1 )); then
	polowa=$((ilosc/2))
	
	#tworzenie uzytkownikow w petli for
	for ((i = 1; i <= ilosc; i++)); do
	
	nazwa="user$i"
	haslo="password$i"
	sprawdzCzyIstnieje=$(cat /etc/passwd | grep -w "^$nazwa" | cut -d: -f1)
	if [[ -z "$sprawdzCzyIstnieje" ]] ; then
	sudo useradd "$nazwa"
	echo "$nazwa:$haslo" | sudo chpasswd
	echo "utworzono uzytkownika $nazwa"
	if((i <= polowa)); then
	
	grupa="studenci_informatyki"
	sudo usermod -a -G "$grupa" "$nazwa"
	echo "Dodano uzytkownika $nazwa do grupy $grupa"
	
	else
	
	grupa="studenci_etyki"
	sudo usermod -a -G "$grupa" "$nazwa"
	echo "Dodano uzytkownika $nazwa do grupy $grupa"
	fi
	
	else
	echo "uzytkownik $nazwa istnieje"
	fi
	
	done	
break

#cut -d: -f1 /etc/passwd | grep "$szukanaOsoba" - sprawdzanie czy użytkownik istnieje

    else
        echo "Błąd: liczba musi być większa niż 1"
    fi
else
    echo "Błąd: to nie jest liczba całkowita"
fi
done


}

zadanie12(){
clear
echo "WYSWIETLANIE KONT, GRUP I INFORMACJI O NICH"
echo ""
echo "LISTA UZYTKOWNIKOW"
cut -d: -f1 /etc/passwd
echo "LISTA GRUP I JEJ CZLONKOW"
getent group | awk -F: '{print "Nazwa grupy: " $1 " - Czlonkowie: " $4}'

}

menuZadanie2(){
while true; do
echo "Zadanie 2"
echo ""
echo "1) Przypisz dane do karty sieciowej"
echo "2) Wyswietl informacje o ustawieniach sieciowych"
echo "3) Wyjście do menu"
read -p "Wybierz opcje [1-3]: " opcja


	case $opcja in 
		1)
		
		zadanie21
		;;
		2)
		clear
		zadanie22
		;;
		3)
		clear
		return
		;;
		*)
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	echo ""
done
}

ustawStatycznie(){
kartaSieciowa1=$1

read -p "Podaj adres IP dla $kartaSieciowa1: " ip
read -p "Podaj maske dla $kartaSieciowa1 (np. 24 dla 255.255.255.0): " maska
read -p "Podaj brame dla $kartaSieciowa1: " brama
read -p "Podaj DNS (np. 8.8.8.8): " dns

aktualneIP=$(ip a | grep -w "$kartaSieciowa1" | grep "inet" | awk '{print $2}')
ip addr del $aktualneIP dev $kartaSieciowa1
ip addr add ${ip}/${maska} dev $kartaSieciowa1
ip link set $kartaSieciowa1 up
ip route add default via $brama dev $kartaSieciowa1
echo "nameserver $dns" | tee /etc/resolv.conf 

echo "Dokonano konfiguracji dla $kartaSieciowa1"
}

ustawDHCP(){
#todo: spytac czy moze byc instalowany program typu dhclient
echo "costam"
}

zadanie21(){

while true ; do
read -p "Do jakiej karty sieciowej chcesz zmienic adres?: " kartaSieciowa
if ip link show "$kartaSieciowa" > /dev/null 2>&1 ; then 
echo "Interfejs $kartaSieciowa istnieje"

while true; do
	echo "Wybierz konfiguracje dla $kartaSieciowa: "
	echo "1) Statycznie - wedlug swoich potrzeb"
	echo "2) Automatycznie - DHCP"
	echo "3) Wyjście do menu"
	read -p "Wybierz opcje [1-3]: " opcja

case $opcja in
	1) ustawStatycznie "$kartaSieciowa" ;;
	2) ustawDHCP "$kartaSieciowa" ;;
	3)
	clear
	return
	;;
	*) echo "Wybrano nieprawidlowa opcje" ;;
	esac
	done
else
	echo "Interfejs $kartaSieciowa nie istnieje"

fi 
done
}


menuDozadania21(){
echo "costam"
}

zadanie22(){
# swoje adresy
# polaczenie z internetem
# informacje o portach
#
#
echo "Informacje o ustawieniach sieciowych:

$(ifconfig | grep 'inet ' | awk '{print "Adres IP:", $2, "Maska:", $4, "Brama:", ($6 ? $6 : "Brak informacji")}')"
echo ""
echo "Sprawdzenie polaczenia: "

if(ping -c 1 8.8.8.8 | grep -w "1 received"); then
echo "Polaczony z internetem"
else
echo "Brak polaczenia z internetem" 
fi
echo ""
echo "Informacje o firewallu i portach"
ufw status

}



zadanie3(){
echo "Wykonanie zadania 3"
}
zadanie4(){
echo "Wykonanie zadania 4"

}

#menu
menu(){
while true; do
echo "Program do administrowania systemem"
echo "MENU"
echo "1) Zadanie 1"
echo "2) Zadanie 2"
echo "3) Zadanie 3"
echo "4) Zadanie 4"
echo "5) Wyjście"
read -p "Wybierz opcje [1-5]: " opcja


	case $opcja in 
		1)
		clear
		menuZadanie1
		;;
		2)
		clear
		menuZadanie2
		;;
		3)
		clear
		zadanie3	
		;;
		4)
		clear
		zadanie4
		;;
		5)
		echo "Do zobaczenia"
		break
		menu
		;;
		*)
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	echo ""
done
}

main(){
menu
}

main

