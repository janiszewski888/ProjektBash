#!/bin/bash

menuZadanie1(){

echo "==================================="
while true; do
	echo "Program do administrowania systemem"
	echo "==================================="
	echo "1) Dodawanie x ilosci uzytkownikow"
	echo "-----------------------------------"
	echo "2) Wyswietl konta, grupy i zawartosc uzytkownikow"
	echo "-----------------------------------"
	echo "0) Wyjście do menu"
	echo "-----------------------------------"
	echo ""
	read -p "Wybierz opcje: " opcja


case $opcja in 
	1)
	clear
	dodajXIloscUzytkownikow ;; #dziala
	2)
	clear
	wyswietlInfoUzytGrup ;; #dziala
	0)
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

dodajXIloscUzytkownikow(){
echo "Tworzenie x ilości użytkowników o nazwie user[1-x] o haśle password[1-x]"
sudo groupadd -f studenci_informatyki
sudo groupadd -f studenci_etyki
while true; do
	read -p "Ile użytkowników chciałbyś stworzyć?: " ilosc

if [[ "$ilosc" =~ ^-?[0-9]+$ ]]; then
    if (( ilosc >= 1 )); then
	polowa=$((ilosc/2))
	
 								#tworzenie uzytkownikow w petli for
		for ((i = 1; i <= ilosc; i++)); do
			nazwa="user$i"
			haslo="password$i"
			sprawdzCzyIstnieje=$(cat /etc/passwd | grep -w "^$nazwa" | cut -d: -f1)
				if [[ -z "$sprawdzCzyIstnieje" ]] ; then # -z sprawdza czy zmienna jest pusta
					sudo useradd "$nazwa"
					echo "$nazwa:$haslo" | sudo chpasswd
					echo "utworzono uzytkownika $nazwa"
						if((i <= polowa)); then
							grupa="studenci_informatyki"
							sudo usermod -aG "$grupa" "$nazwa"
							echo "Dodano uzytkownika $nazwa do grupy $grupa"
						else
							grupa="studenci_etyki"
							sudo usermod -aG "$grupa" "$nazwa"
							echo "Dodano uzytkownika $nazwa do grupy $grupa"
						fi
				else
				echo "uzytkownik $nazwa istnieje"
				fi
	
		done	
		break

    else
	echo "Błąd: liczba musi być większa niż 1"
	fi
else
echo "Błąd: to nie jest liczba calkowita"
fi
done


}


menuZadanie2(){

while true; do
	echo "==================================="
	echo "Zarzadzanie karta sieciowa"
	echo "==================================="
	echo "1) Zmien adres karty sieciowej"
	echo "-----------------------------------"
	echo "2) Wyswietl informacje o ustawieniach sieciowych"
	echo "-----------------------------------"
	echo "3) Wlacz UFW"
	echo "-----------------------------------"
	echo "4) Wylacz UFW"
	echo "-----------------------------------"
	echo "5) Zarzadzaj portami przez UFW"
	echo "-----------------------------------"
	echo "0) Wyjście do menu"
	echo "-----------------------------------"
	echo ""
	read -p "Wybierz opcje: " opcja


	case $opcja in 
		1) clear 
		zmianaAdresuIP ;; #dziala
		2) clear
		wyswietlInfo ;; #dziala
		3) clear 
		wlaczUFW ;; #dziala
		4) clear
		wylaczUFW ;; #dziala
		5) clear
		zarzadzaniePortami ;;

		#todo: otwieranie/zamykanie portow z UFW 
		0)
		clear
		return
		;;
		*)
	 	echo "Wybrano nieprawidłową opcje"
		clear
		;;
	esac
done


}


zmianaAdresuIP(){
while true ; do
	read -p "Do jakiej karty sieciowej chcesz zmienic adres?: " kartaSieciowa
		if ip link show "$kartaSieciowa" > /dev/null 2>&1 ; then 
		clear
		echo "Interfejs $kartaSieciowa istnieje"

		while true; do
			echo "==================================="
			echo "Wybierz konfiguracje dla $kartaSieciowa: "
			echo "==================================="
			echo "1) Statycznie - wedlug swoich potrzeb"
			echo "-----------------------------------" 
			echo "2) Automatycznie - DHCP"
			echo "-----------------------------------" 
			echo "0) Wyjście do menu"
			echo "-----------------------------------" 
			echo 
			read -p "Wybierz opcje: " opcja

			case $opcja in
			1) clear 
			ustawStatycznie "$kartaSieciowa" ;;
			2) clear
			ustawDHCP "$kartaSieciowa" ;;
			0)
			clear
			return
			;;
			*) 
			echo "Wybrano nieprawidlowa opcje" 
			clear
			;;
			
			esac
		done
		else
			echo "Interfejs $kartaSieciowa nie istnieje"

		fi 
done
}



ustawStatycznie(){
kartaSieciowa1=$1
dhclient -r $kartaSieciowa1 &> /dev/null
read -p "Podaj adres IP dla $kartaSieciowa1: " ip
read -p "Podaj maske dla $kartaSieciowa1 (np. 24 dla 255.255.255.0): " maska
read -p "Podaj brame dla $kartaSieciowa1: " brama
read -p "Podaj DNS (np. 8.8.8.8): " dns
clear

aktualneIP=$(ip a | grep -w "$kartaSieciowa1" | grep "inet" | awk '{print $2}')
ip addr del $aktualneIP dev $kartaSieciowa1 &> /dev/null
ip addr add ${ip}/${maska} dev $kartaSieciowa1 &> /dev/null
ip route add default via $brama dev $kartaSieciowa1 &> /dev/null
echo "nameserver $dns" | tee /etc/resolv.conf &> /dev/null

echo "Dokonano konfiguracji dla $kartaSieciowa1"
}



ustawDHCP(){
kartaSieciowa1=$1
aktualneIP=$(ip a | grep -w "$kartaSieciowa1" | grep "inet" | awk '{print $2}')
ip addr del $aktualneIP dev $kartaSieciowa1 &> /dev/null
read -p "Czy chcesz ustawic adres DHCP na stale(1), czy na jedno uruchomienie(2): " wybor
clear
cfg="/etc/sysconfig/network-scripts/ifcfg-$kartaSieciowa1"
if [[ $wybor = "1" ]]; then
	dhclient -r $kartaSieciowa1 &> /dev/null
	dhclient $kartaSieciowa1 &> /dev/null
	touch "$cfg"
	echo "BOOTPROTO=dhcp" > $cfg
	echo "ONBOOT=yes" >> $cfg  
	echo "Dokonano konfiguracji DHCP na stale"
elif [[ $wybor = "2" ]]; then
	dhclient -r $kartaSieciowa1 &> /dev/null
	dhclient $kartaSieciowa1 &> /dev/null
	touch "$cfg"
	echo "" > "$cfg" &> /dev/null
	echo "Dokonano konfiguracji DHCP dla $kartaSieciowa1,"
	echo "pamietaj ze po restarcie karta powroci do"
	echo "adresu statycznego"
else
	echo "Zly przycisk"
fi

#touch /etc/sysconfig/network-scripts/ifcfg-$kartaSieciowa 
#dhclient $kartaSieciowa1

#echo "Dokonano konfiguracji dla $kartaSieciowa1, pamietaj ze po restarcie systemu karta powroci do poprzedniego adresu"
}

wyswietlInfo(){
# swoje adresy
# polaczenie z internetem
# informacje o portach
#
#
echo "Informacje o ustawieniach sieciowych:
$(ifconfig | grep 'inet ' | awk '{print "Adres IP:", $2, 
"Maska:", $4}' | head -1) $(ip route | awk '/default/ {print "Brama:", $3}' | tail -1)"
echo ""
echo "Sprawdzenie polaczenia: "

if ping -c 1 8.8.8.8 | grep -q -w "1 received"; then
	echo "Polaczony z internetem"
else
	echo "Brak polaczenia z internetem" 
fi
echo ""
echo "Informacje o firewallu i portach"
ufw status
echo 
echo "-----------------------------------"

while true; do
	read -n1 -p "Nacisnij 'q' aby wyjsc: " klawisz
	echo ""
if [[ "$klawisz" == "q" ]]; then
	clear
	return
fi
done


}

wlaczUFW(){
	clear
	ufw enable &> /dev/null
	echo "Wlaczono Firewall"
}
wylaczUFW(){
	clear
	ufw disable &> /dev/null
	echo "Wylaczono Firewall"
}

zarzadzaniePortami(){
while true; do 
	read -p "Co chcesz zrobic z portem [allow / deny]: " wybor

	if [[ "$wybor" == "allow" ]]; then
		clear
		read -p "Jakiego portu ma to dotyczyc: " numerPortu
		clear
		read -p "Dla ktorego protokolu pozwolic na otwarcie portu? [tcp / udp / oba]: " protokol
		case $protokol in
			tcp)
				ufw "$wybor" "$numerPortu/$protokol" &> /dev/null
				clear
				echo "Otwarto port $numerPortu dla protokolu $protokol"
				return
			;;
			udp)
				ufw "$wybor" "$numerPortu/$protokol" &> /dev/null
				clear
				echo "Otwarto port $numerPortu dla protokolu $protokol"
				return
			;;
			oba)
				ufw "$wybor" "$numerPortu" &> /dev/null
				clear
				echo "Otwarto port $numerPortu dla obu protokolow"
				return
				;;
			*)
				echo "Nieprawidlowa opcja protokolu"
				
		esac

	elif [[ "$wybor" == "deny" ]]; then
		clear
		read -p "Jakiego portu ma to dotyczyc: " numerPortu
		clear
		read -p "Dla ktorego protokolu pozwolic na zamkniecie portu? [tcp / udp / oba]: " protokol
		case $protokol in
			tcp)
				ufw "$wybor" "$numerPortu/$protokol" &> /dev/null
				clear
				echo "Zamknieto port $numerPortu dla protokolu $protokol"
				return
			;;
			udp)
				ufw "$wybor" "$numerPortu/$protokol" &> /dev/null
				clear
				echo "Zamknieto port $numerPortu dla protokolu $protokol"
				return
			;;
			oba)
				ufw "$wybor" "$numerPortu" &> /dev/null
				clear
				echo "Zamknieto port $numerPortu dla obu protokolow"
				return
			;;
			*)
				echo "Nieprawidlowa opcja protokolu"
				
		esac
	else
	clear
	echo "Nieprawidlowa opcja wpisz allow lub deny"

	fi
done 
}

menuZadanie3(){
while true; do
	liczbaUzytkownikow=$(wc -l /etc/passwd | awk '{print $1}')
	echo "==================================="
	echo "Zarzadzanie uzytkownikami i grupami"
	echo "==================================="
	echo "Liczba uzytkownikow wynosi: $liczbaUzytkownikow"
	echo "===================================" 
	echo "1) Dodawanie, usuwanie i modyfikowanie uzytkownikow"
	echo "-----------------------------------" 
	echo "2) Dodawanie, usuwanie i modyfikowanie grup"
	echo "-----------------------------------" 
	echo "3) Wyswietlanie wszystkich uzytkownikow i grup oraz ich zawartosci"
	echo "-----------------------------------" 
	echo "0) Wyjście"
	echo "-----------------------------------" 
	echo ""
	read -p "Wybierz opcje: " opcja
		case $opcja in 
			1)
			clear
			zarzadzanieUzytkownikami ;; #dziala
			2)
			clear
			zarzadzanieGrupami ;;
			3)
			clear
			wyswietlInfoUzytGrup ;; #dziala
			0)
			clear
			return ;;
			*)
			clear
			echo "Wybrano nieprawidłową opcje" ;;
		esac
	
done


}

zarzadzanieUzytkownikami(){

dodajUzytkownika(){
while true; do
	read -p "Podaj nazwe uzytkownika ktorego chcialbys dodac: " nazwaUzytkownika
	read -p "Czy chcialbys / chcialabys dac mu haslo [t/n]: " odpowiedz
	odpowiedz=$(echo "$odpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male

	case $odpowiedz in
		t)
		clear
		read -p "Prosze podac haslo: " haslo
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
while true; do

	echo "==================================="
	echo "Modyfikacja uzytkownika" 
	echo "===================================" 
	echo "1) Zmien nazwe uzytkownika" 
	echo "-----------------------------------" 
	echo "2) Zmien haslo uzytkownika"
	echo "-----------------------------------" 
	echo "3) Dodaj uzytkownika do grupy"
	echo "-----------------------------------" 
	echo "4) Usun uzytkownika z grupy"
	echo "-----------------------------------"
	echo "0) Wyjscie"
	echo "-----------------------------------" 
	echo ""
	read -p "Wybierz opcje: " opcja

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
			return ;;
		4)
		clear
		echo "Usun uzytkownika z grupy"
	 	read -p "Podaj nazwe uzytkownika ktorego chcialbys usunac z grupy: " nazwaUzytkownika
	 	read -p "Podaj nazwe grupy ktora ma byc odebrana uzytkownikowi: " nazwaGrupy
			if id "$nazwaUzytkownika" &>/dev/null && getent group "$nazwaGrupy" &>/dev/null; then
				gpasswd -d "$nazwaUzytkownika" "$nazwaGrupy"
				clear	
				echo "Uzytkownik $nazwaUzytkownika zostal usuniety z grupy $nazwaGrupy"
				return
			else
				clear
				echo "Uzytkownik lub grupa nie istnieja. Sprobuj jeszcze raz"
			return
			fi
			return ;;
	
		0)
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


while true; do
	echo "===================================" 
	echo "Dodawanie, usuwanie i modyfikowanie uzytkownikow"
	echo "===================================" 
	echo "1) Dodaj uzytkownika"
	echo "-----------------------------------" 
	echo "2) Usuwanie uzytkownika"
	echo "-----------------------------------"
	echo "3) Modyfikowanie uzytkownikow"
	echo "-----------------------------------"
	echo "0) Wyjscie"
	echo "-----------------------------------"
	echo ""
	read -p "Wybierz opcje: " opcja

	case $opcja in 
		1)
		clear
	 	dodajUzytkownika #dziala z haslem i bez
		;;
		2)
		clear
		usunUzytkownika #dziala
		;;
		3)
		clear
		modyfikujUzytkownika #dziala
		;;
		0)
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


zarzadzanieGrupami(){

dodajGrupe(){
echo "Dodawanie grupy"
read -p "Podaj nazwe nowej grupy: " nazwaGrupy

if getent group "$nazwaGrupy" &>/dev/null; then
	clear
	echo "Grupa $nazwaGrupy juz istnieje"
		return
else
	groupadd $nazwaGrupy
	clear
	echo "Stworzono grupe $nazwaGrupy"
	return
fi

}



usunGrupe(){
echo "Usuwanie grupy"
read -p "Podaj nazwe grupy ktora chcesz usunac: " nazwaGrupy

if getent group "$nazwaGrupy" &>/dev/null; then
	groupdel $nazwaGrupy
	clear
	echo "Grupa $nazwaGrupy zostala usunieta"
	return
else
	clear
	echo "Grupa $nazwaGrupy nie istnieje"
	return
fi
}

zmiennazweGrupy(){
echo "Zmiana nazwy grupy"
read -p "Podaj grupe ktorej chcesz zmienic nazwe: " nazwaGrupy
read -p "Podaj nowa nazwe grupy: " nowanazwaGrupy

if getent group "$nazwaGrupy" &>/dev/null; then
	groupmod -n $nowanazwaGrupy $nazwaGrupy
	clear
	echo "Nazwa grupy $nazwaGrupy zostala zmieniona na $nowanazwaGrupy"
else
	clear
	echo "Grupa $nazwaGrupy nie istnieje"
	return
fi
}





while true; do
	echo "===================================" 
	echo "Dodawanie, usuwanie i modyfikowanie grup"
	echo "===================================" 
	echo "1) Dodaj grupe"
	echo "-----------------------------------" 
	echo "2) Usun grupe"
	echo "-----------------------------------"
	echo "3) Zmien nazwe grupy"
	echo "-----------------------------------"
	echo "0) Wyjscie"
	echo "-----------------------------------"
	echo ""
	read -p "Wybierz opcje: " opcja

	case $opcja in 
		1)
		clear
	 	dodajGrupe #dziala
		;;
		2)
		clear
		usunGrupe #dziala
		;;
		3)
		clear
		zmiennazweGrupy #dziala
		;;
		0)
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

wyswietlInfoUzytGrup(){
echo "==================================="
echo "WYSWIETLANIE KONT, GRUP I INFORMACJI O NICH"
echo "==================================="
echo 
echo "LISTA UZYTKOWNIKOW"
echo "-----------------------------------"
awk -F: '{printf "%s ", $1; if (++i % 5 == 0) print ""}' /etc/passwd
echo 
echo
echo "LISTA GRUP I JEJ CZLONKOW"
echo "-----------------------------------"
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


while true; do
	echo "Baza danych"
	echo "1) Stworz baze danych"
	echo "2) Pokaz baze danych"
	echo "3) Dodaj nowy rekord"
	echo "4) Edytuj rekord"
	echo "5) Usun rekord"
	echo "0) Wyjscie"
	read -p "Wybierz opcje: " opcja

	case $opcja in 
		1)
		clear
	 	stworzBaze #dziala
		;;
		2)
		clear
		pokazBaze #dziala
		;;
		3)
		clear
		dodajRekord #dziala
		;;
		4)
		clear
		edytujRekord #dziala
		;;
		5)
		clear
		usunRekord #dziala
		;;
		0)
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

stworzBaze(){

if [[ -e $plikBaza ]]; then
	while true; do
		read -p "Plik $plikBaza istnieje czy chcialbys go usunac? [t/n]: " odpowiedz
		odpowiedz=$(echo "$odpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male
			if [[ $odpowiedz == "t" ]]; then
				rm "$plikBaza"
				break
			elif [[ $odpowiedz == "n" ]]; then
				echo "Powrot do menu"
				return
			else 
				echo "Prosze kliknac [t/n]: "
			fi 
	done
fi

read -p "Podaj liczbe kolumn: " liczbaKolumn
clear
echo "Podaj $liczbaKolumn nazwy naglowkow (kazda nazwa kolumny oddzielona spacja): "
read -a nazwyNaglowkow #zapisuje te slowa w tablice

if [[ ${#nazwyNaglowkow[@]} -ne $liczbaKolumn ]]; then
	clear
	echo "Liczba naglowkow nie zgadza sie z liczba kolumn. Sprobuj ponownie"
	return
else
	clear
	echo "${nazwyNaglowkow[*]}" > "$plikBaza"
	echo "Dodano naglowki tabeli"
	cat "$plikBaza"
fi

read -p "Czy chcesz wprowadzic rekord? [t/n]: " odpowiedz
odpowiedz=$(echo "$odpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male

if [[ $odpowiedz == "t" ]]; then
	while true ; do
		cat "$plikBaza"
		echo "Wprowadz $liczbaKolumn wartosci zgodnymi z naglowkami (wiersz na gorze): "
		read -a dane
			if [[ ${#dane[@]} -ne $liczbaKolumn ]]; then
				clear
				echo "Liczba wartosci nie zgadza sie z iloscia kolumn ("$liczbaKolumn")"
				continue
			fi
		echo "${dane[*]}" >> "$plikBaza"
		read -p "Czy chcesz wprowadzic kolejny rekord? [t/n]: " kolejnaOdpowiedz
		clear
		kolejnaOdpowiedz=$(echo "$kolejnaOdpowiedz" | tr '[:upper:]' '[:lower:]') #zamienia duze litery na male
		[[ $kolejnaOdpowiedz != "t" ]] && break
			echo "Dodawanie kolejnego rekordu..."  
			clear
	done 
fi 

}


pokazBaze(){
clear
if [[ -e $plikBaza ]]; then
cat $plikBaza
else
echo "Plik nie istnieje"
fi
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
	liczbaKolumn=$(head -n 1 baza_danych.txt | wc -w)
	echo "Wprowadz $liczbaKolumn wartosci zgodnymi z naglowkami (wiersz na gorze): "
	read -a dane
	if [[ ${#dane[@]} -ne $liczbaKolumn ]]; then
		clear
		echo "Liczba wartosci nie zgadza sie z iloscia kolumn ($liczbaKolumn)"
		continue
	fi
		echo "${dane[*]}" >> "$plikBaza"
		read -p "Czy chcesz wprowadzic kolejny rekord? [t/n]: " kolejnaOdpowiedz
		clear
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
while true; do 
	clear
	cat $plikBaza
	echo "==================================="
	read -p "Podaj numer gracza do edycji: " nr_gracza
	echo "==================================="
	if grep -q "^$nr_gracza" "$plikBaza" ; then
		echo "1) Nr_gracza"
		echo "-----------------------------------"
		echo "2) Imie_i_nazwisko"
		echo "-----------------------------------"
		echo "3) Klub"
		echo "-----------------------------------"
		echo "4) Ilosc_pkt"
		echo "-----------------------------------"
		echo "0) Wyjdz"
		echo "-----------------------------------"
		read -p "Znaleziono gracza nr $nr_gracza, co chcialbys zmienic?" zmiana
case $zmiana in 
	1)
		clear
	 	read -p "Podaj nowy nr_gracza" nowa_wartosc
	 	sed -i "/^$nr_gracza /s/^[^ ]*/$nowa_wartosc/" "$plikBaza"
		echo "Numer gracza zostal zmieniony na $nowa_wartosc"
		return
		;;
	2)
  		clear
  		read -p "Podaj nowe imie i nazwisko: " nowa_wartosc
  		sed -Ei "/^$nr_gracza /s/^([^ ]*) [^ ]*/\1 $nowa_wartosc/" "$plikBaza"
  		echo "Imię i nazwisko zostało zmienione na $nowa_wartosc"
  		return
  		;;

	3)
  		clear
  		read -p "Podaj nowy klub: " nowa_wartosc
  		sed -Ei "/^$nr_gracza /s/^([^ ]* [^ ]* )[^ ]*/\1$nowa_wartosc/" "$plikBaza"
  		echo "Klub został zmieniony na $nowa_wartosc"
  		return
  		;;

	4)
  		clear
  		read -p "Podaj nową ilość punktów: " nowa_wartosc
  		sed -Ei "/^$nr_gracza /s/^([^ ]* [^ ]* [^ ]* )[^ ]*/\1$nowa_wartosc/" "$plikBaza"
  		echo "Ilość punktów została zmieniona na $nowa_wartosc"
  		return
  		;;
	0)
		clear
		return
		;;
		*)
		clear
	 	echo "Wybrano nieprawidłową opcje"
		;;
esac

else
echo "Nie znaleziono gracza nr $nr_gracza, sprobuj ponownie"
fi
done
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

#menu
menu(){
clear
while true; do
	echo "Program do administrowania systemem"
	echo "===========MENU GLOWNE============="
	echo "1) Zadanie 1"
	echo "-----------------------------------"
	echo "2) Zadanie 2"
	echo "-----------------------------------"
	echo "3) Zadanie 3"
	echo "-----------------------------------"
	echo "4) Zadanie 4"
	echo "-----------------------------------"
	echo "0) Wyjście"
	echo "-----------------------------------"
	echo ""
	read -p "Wybierz opcje: " opcja


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
		0)
		clear
		echo "Do zobaczenia"
		break
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

