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
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	
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
while true; do
read -n1 -p "Nacisnij 'q' aby wyjsc: " klawisz
echo ""
if [[ "$klawisz" == "q" ]]; then
clear
return
fi
done
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



menuZadanie3(){
while true; do
liczbaUzytkownikow=$(wc -l /etc/passwd | awk '{print $1}')
echo "Liczba uzytkownikow wynosi $liczbaUzytkownikow" 
echo "Zarzadzanie uzytkownikami i grupami"
echo "1) Dodawanie, usuwanie i modyfikowanie uzytkownikow"
echo "2) Dodawanie, usuwanie i modyfikowanie grup"
echo "3) Wyswietlanie wszystkich uzytkownikow i grup oraz ich zawartosci"
echo "4) Wyjście"
read -p "Wybierz opcje [1-4]: " opcja
	case $opcja in 
		1)
		clear
		zadanie31
		;;
		2)
		clear
		zadanie32
		;;
		3)
		clear
		zadanie33
		;;
		4)
		clear
		return
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	
done	
}


zadanie31(){

dodajUzytkownika(){
while true; do
read -p "Podaj nazwe uzytkownika ktorego chcialbys/chcialabys dodac: " nazwaUzytkownika
read -p "Czy chcialbys / chcialabys dac mu haslo [t/n]: " odpowiedz
odpowiedz=$(echo "$odpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male

case $odpowiedz in
t)
clear
read -p "Prosze podac haslo" haslo
useradd -m -p "$(openssl passwd -6 $haslo)" $nazwaUzytkownika
clear
echo "Stworzono uzytkownika $nazwaUzytkownika z haslem $haslo"
return
;;
n)
clear
useradd $nazwaUzytkownika
clear
echo "Stworzono uzytkownika $nazwaUzytkownika"
return

;;
*)
clear
echo "Podano nieprawidlowa opcje"
;;
esac

done
}

usunUzytkownika(){
while true; do
read -p "Podaj nazwe uzytkownika ktorego chcialbys/chcialabys usunac: " nazwaUzytkownika
if id "$nazwaUzytkownika" &>/dev/null; then
userdel -r "$nazwaUzytkownika"
clear
echo "Uzytkownik $nazwaUzytkownika zostal usuniety."
return
else
clear
echo "Uzytkownik nie istnieje. Sprobuj jeszcze raz"
return
fi

done
}

modyfikujUzytkownika(){
echo "Modyfikacja uzytkownika"
while true; do
echo "1) Zmien nazwe uzytkownika"
echo "2) Zmien haslo uzytkownika"
echo "3) Dodaj uzytkownika do grupy"
echo "4) Wyjscie"
read -p "Wybierz opcje [1-4]: " opcja

	case $opcja in 
		1)
		clear
	 	echo "Zmienianie nazwy uzytkownika"
	 	read -p "Podaj nazwe uzytkownika ktoremu chcialbys zmienic nazwe: " nazwaUzytkownika
		if id "$nazwaUzytkownika" &>/dev/null; then
		read -p "Podaj nowa nazwe uzytkownika: " nowanazwaUzytkownika
		usermod -l $nowanazwaUzytkownika $nazwaUzytkownika
		clear	
		echo "Nazwa uzytkownika $nazwaUzytkownika zostala zmieniona na $nowanazwaUzytkownika"
		return
		else
		clear
		echo "Uzytkownik nie istnieje. Sprobuj jeszcze raz"
		return
		fi
		;;
		
		
		2)
		clear
		echo "Zmiana hasla uzytkownika"
	 	read -p "Podaj nazwe uzytkownika ktoremu chcialbys zmienic haslo: " nazwaUzytkownika
		if id "$nazwaUzytkownika" &>/dev/null; then
		read -p "Podaj nowe haslo uzytkownika $nazwaUzytkownika: " nowehasloUzytkownika
		echo "$nazwaUzytkownika:$nowehasloUzytkownika" | chpasswd
		clear	
		echo "Haslo uzytkownika $nazwaUzytkownika zostala zmieniona na $nowehasloUzytkownika"
		return
		else
		clear
		echo "Uzytkownik nie istnieje. Sprobuj jeszcze raz"
		fi
		echo ""
		return
		;;
		3)
		clear
		echo "Dodaj uzytkownika do grupy"
	 	read -p "Podaj nazwe uzytkownika ktoremu chcialbys nadac grupe: " nazwaUzytkownika
	 	read -p "Podaj nazwe grupy do ktorej chcialbys przypisac uzytkownika: " nazwaGrupy
		if id "$nazwaUzytkownika" &>/dev/null && getent group "$nazwaGrupy" &>/dev/null; then
		usermod -aG $nazwaGrupy $nazwaUzytkownika
		clear	
		echo "Uzytkownik $nazwaUzytkownika zostal dodany do grupy $nazwaGrupy"
		return
		else
		clear
		echo "Uzytkownik lub grupa nie istnieja. Sprobuj jeszcze raz"
		return
		fi
		return
		;;
		4)
		clear
		return
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	
	
done
# modyfikuj nazwe uzytkownika,
# modyfikuj haslo uzytkownika,
# dodaj uzytkownika do grupy 
}


while true; do
echo "'Dodawanie, usuwanie i modyfikowanie uzytkownikow'"
echo "1) Dodaj uzytkownika"
echo "2) Usuwanie uzytkownika"
echo "3) Modyfikowanie uzytkownikow"
echo "4) Wyjscie"
read -p "Wybierz opcje [1-4]: " opcja

	case $opcja in 
		1)
		clear
	 	dodajUzytkownika
		;;
		2)
		clear
		usunUzytkownika
		;;
		3)
		clear
		modyfikujUzytkownika
		;;
		4)
		clear
		return
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac


done
}


zadanie32(){

dodajGrupe(){
echo "Dodawanie grupy"
read -p "Podaj nazwe nowej grupy: " nazwaGrupy

if getent group "$nazwaGrupy" &>/dev/null; then
echo "Grupa $nazwaGrupy juz istnieje"
return
else
groupadd $nazwaGrupy
echo "Stworzono grupe $nazwaGrupy"
return
fi

}



usunGrupe(){
echo "Usuwanie grupy"
read -p "Podaj nazwe grupy ktora chcesz usunac: " nazwaGrupy

if getent group "$nazwaGrupy" &>/dev/null; then
groupdel $nazwaGrupy
echo "Grupa $nazwaGrupy zostala usunieta"
return
else
echo "Grupa $nazwaGrupy nie istnieje"
return
fi
}

zmiennazweGrupy(){
echo "Zmiana nazwy grupy"
read -p "Podaj grupe ktorej chcesz zmienic nazwe: " nazwaGrupy
read -p "Podaj nowa nazwe grupy" nowanazwaGrupy
if getent group "$nazwaGrupy" &>/dev/null; then
groupmod -n $nowanazwaGrupy $nazwaGrupy
echo "Nazwa grupy $nazwaGrupy zostala zmieniona na $nowanazwaGrupy"
return
else
echo "Grupa $nazwaGrupy nie istnieje"
return
fi
}





while true; do
echo "'Dodawanie, usuwanie i modyfikowanie grup'"
echo "1) Dodaj grupe"
echo "2) Usun grupe"
echo "3) Zmien nazwe grupy"
echo "4) Wyjscie"
read -p "Wybierz opcje [1-4]: " opcja

	case $opcja in 
		1)
		clear
	 	dodajGrupe
		;;
		2)
		clear
		usunGrupe
		;;
		3)
		clear
		zmiennazweGrupy
		;;
		4)
		clear
		return
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac


done
}

zadanie33(){
clear
echo "WYSWIETLANIE KONT, GRUP I INFORMACJI O NICH"
echo ""
echo "LISTA UZYTKOWNIKOW"
cut -d: -f1 /etc/passwd
echo "LISTA GRUP I JEJ CZLONKOW"
getent group | awk -F: '{print "Nazwa grupy: " $1 " - Czlonkowie: " $4}'
while true; do
read -n1 -p "Nacisnij 'q' aby wyjsc: " klawisz
echo ""
if [[ "$klawisz" == "q" ]]; then
clear
return
fi
done
}


menuZadanie4(){


plikBaza="baza_danych.txt"
# tworzenie bazy
# wyswietlenie jej
# dodanie nowego rekordu
# edytowanie rekordu
# usuniecie rekordu
# wyjscie z bazy 



stworzBaze(){
read -p "Podaj liczbe kolumn: " liczbaKolumn
echo "Podaj nazwy naglowkow (kazda nazwa kolumny oddzielona spacja): "
read -a nazwyNaglowkow #zapisuje te slowa w tablice

if [[ ${#nazwyNaglowkow[@]} -ne $liczbaKolumn ]]; then
echo "Liczba naglowkow nie zgadza sie z liczba kolumn. Sprobuj ponownie"
return
else
echo "${nazwyNaglowkow[*]}" > "$plikBaza"
echo "Dodano naglowki tabeli"
cat $plikBaza
fi

read -p "Czy chcesz wprowadzic rekord? [t/n]" odpowiedz
odpowiedz=$(echo "$odpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male

if [[ $odpowiedz == "t" ]]; then
while true ; do
cat $plikBaza
echo "Wprowadz $liczbaKolumn wartosci zgodnymi z naglowkami (wiersz na gorze)"
read -a dane
	if [[ ${#dane[@]} -ne $liczbaKolumn ]]; then
		echo "Liczba wartosci nie zgadza sie z iloscia kolumn ("$liczbaKolumn")"
		continue
	fi
		echo "${dane[*]}" >> "$plikBaza"
		read -p "Czy chcesz wprowadzic kolejny rekord? [t/n]" kolejnaOdpowiedz
		kolejnaOdpowiedz=$(echo "$kolejnaOdpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male
		[[ $kolejnaOdpowiedz != "t" ]] && break
		echo "Dodawanie kolejnego rekordu..."  
done 
fi 


}

pokazBaze(){
clear
cat $plikBaza
echo ""
echo ""
echo "----------------------------------"

while true; do
read -n1 -p "Nacisnij 'q' aby wyjsc: " klawisz
echo ""
if [[ "$klawisz" = "q" ]]; then
clear
return
fi
done
}

dodajRekord(){
while true ; do
cat $plikBaza
liczbaKolumn=$(wc -l < $plikBaza)
echo "Wprowadz $liczbaKolumn wartosci zgodnymi z naglowkami (wiersz na gorze)"
read -a dane
	if [[ ${#dane[@]} -ne $liczbaKolumn ]]; then
		echo "Liczba wartosci nie zgadza sie z iloscia kolumn ($liczbaKolumn)"
		continue
	fi
		echo "${dane[*]}" >> "$plikBaza"
		read -p "Czy chcesz wprowadzic kolejny rekord? [t/n]" kolejnaOdpowiedz
		kolejnaOdpowiedz=$(echo "$kolejnaOdpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male
		[[ $kolejnaOdpowiedz != "t" ]] && break
		echo "Dodawanie kolejnego rekordu..."  
done 

}

edytujRekord(){
cat $plikBaza
echo
echo 
echo
echo "------------------------"
read -p "Podaj numer gracza do edycji: " nr_gracza

 

}

usunRekord(){
cat $plikBaza
echo
echo
echo
echo "----------------------"
read -p "Podaj numer gracza (nr_gracza) do usuniecia: " nr_gracza

sed -i "/^$nr_gracza /d" "$plikBaza"

echo "rekord z numerem gracza $nr_gracza zostal usuniety"

}

while true; do
echo "Baza danych"
echo "1) Stworz baze danych"
echo "2) Pokaz baze danych"
echo "3) Dodaj nowy rekord"
echo "4) Edytuj rekord"
echo "5) Usun rekord"
echo "6) Wyjscie"
read -p "Wybierz opcje [1-6]: " opcja

	case $opcja in 
		1)
		clear
	 	stworzBaze
		;;
		2)
		clear
		pokazBaze
		;;
		3)
		clear
		dodajRekord
		;;
		4)
		clear
		edytujRekord
		;;
		5)
		clear
		usunRekord
		;;
		6)
		clear
		return
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac


done




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
		menuZadanie3	
		;;
		4)
		clear
		menuZadanie4
		;;
		5)
		echo "Do zobaczenia"
		break
		menu
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	
done
}

main(){
menu
}

main

