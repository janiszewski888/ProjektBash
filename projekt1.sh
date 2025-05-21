#!bin/bash

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

zadanie1(){
echo "Tworzenie x ilości użytkowników o nazwie user[1-x] o haśle password[1-x]"

while true; do
read -p "ile użytkowników chciałbyś stworzyć? :" ilosc

if [[ "$ilosc" =~ ^-?[0-9]+$ ]]; then
    if (( ilosc >= 1 )); then
	polowa=$((ilosc/2))
	drugaPolowa=$((ilosc/2+1))
	

# cut -d: -f1 /etc/passwd | grep "$szukanaOsoba" - sprawdzanie czy użytkownik istnieje

    else
        echo "Błąd: liczba musi być większa niż 1"
    fi
else
    echo "Błąd: to nie jest liczba całkowita"
fi
done


}
zadanie2(){
echo "Wykonanie zadania 2"
} #komentarz nr 1
zadanie3(){
echo "Wykonanie zadania 3"
}
zadanie4(){
echo "Wykonanie zadania 4"

}

#menu
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
		zadanie1
		;;
		2)
		clear
		zadanie2
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
		;;
		*)
	 	echo "Wybrano nieprawidłową opcje"
		;;
	esac
	echo ""
done
		

