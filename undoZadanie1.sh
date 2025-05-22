groupdel -f studenci_informatyki
groupdel -f studenci_etyki
read -p "Ile userX usunac?: " X
for((i=1; i<=X; i++)); do
userdel -r user$i
done
