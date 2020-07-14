#!/bin/bash
# Usage: ./trkcrk.sh [FILE or FOLDER]

# PROSEDÜR (X stands for digit)
# 1- wordlists
# 2- XXXXXXXX         ->  8 haneli rakam kombinasyon
# 3- $TELXXXXXXX      ->  telefon numaraları kombinasyon
# 4- kitapXX          ->  tdk kelime rakam kombinasyon
# 5- mehmetX          ->  isim rakam kombinasyon
# 6- mehmetXX         ->  isim 2 rakam kombinasyon
# 7- mehmetXXXX       ->  isim 4 rakam kombinasyon
# 8- mehmetayse20XX   ->  2 isim ve 2000-2020 kombinasyon
# 9- mehmetayse19XX   ->  2 isim ve 1900-1999 kombinasyon
# 0- mehmetayseXX     ->  2 isim ve 2 rakam kombinasyon


wordlists=<WORDLIST KLASÖRÜ>

## Yapılacak sözlük saldırıları
dicts=(
 "$wordlists/isimisim.txt"
 "$wordlists/isim.txt"
 "$wordlists/tdk.txt"
#"$wordlists/rockyou.txt"
#"$wordlists/7M_TR.txt"
)

check(){
 if [ $1 == 0 ];then
   exit
 else
   echo $2 failed >> ${fname}\_${rondo}.log
 fi
}

main(){
rondo=$RANDOM
fname=`echo $1 | awk -F '/' '{ print $NF }' | awk -F '.' '{ print $1 }'`
printf "[\t\t $1 \t\t]\n" > ${fname}\_${rondo}.log
printf  "[\t `date` \t]\n" >>${fname}\_${rondo}.log

## Sözlük saldırıları
for i in ${dicts[*]}
do
 hashcat -m 2500 -a 0 $1 $i
 check $? "$i"
done

## 8 haneli rakam permütasyonu
hashcat -m 2500 -a 3 $1 ?d?d?d?d?d?d?d?d
check $? "8 digit"

for i in `cat $wordlists/telkod.txt`
do
  hashcat -m 2500 -a 3 $1 $i?d?d?d?d?d?d?d
  check $? "${i}XXXXXXX"
done

## Hibrid kelime/rakam kombinasyonları (tdk/isim/isimisim)
hashcat -m 2500 -a 6 $1 $wordlists/tdk.txt ?d?d
check $? "kelimeXX"

hashcat -m 2500 -a 6 $1 $wordlists/isim.txt ?d
check $? "isimX"

hashcat -m 2500 -a 6 $1 $wordlists/isim.txt ?d?d
check $? "isimXX"

hashcat -m 2500 -a 6 $1 $wordlists/isim.txt ?d?d?d
check $? "isimXXX"

hashcat -m 2500 -a 6 $1 $wordlists/isim.txt ?d?d?d?d
check $? "isimXXXX"

hashcat -m 2500 -a 6 $1 $wordlists/isimisim.txt -1 01 20?1?d
check $? "isimisim20XX"

hashcat -m 2500 -a 6 $1 $wordlists/isimisim.txt 19?d?d
check $? "isimisim19XX"

hashcat -m 2500 -a 6 $1 $wordlists/isimisim.txt ?d?d
check $? "isimisimXX"

printf "[\t\t\tFAIL  \t\t\t]\n" >> ${fname}\_${rondo}.log
printf "[\t `date` \t]\n"       >> ${fname}\_${rondo}.log
}

if [ -v $1 ]; then
	echo "Usage: ./trkcrk.sh [FILE or FOLDER]"; exit 1
fi

if [ -d $1 ]
then
	for i in `find $1 -mindepth 1 -name "*.hccapx"`
	do
		main $i
	done
else
	main $1
fi
