#!/bin/bash
read rep; read tablo; 
echo "INPUT : Le nom du répertoire contenant les fichiers d'url  : $rep"; 
echo "OUTPUT : Le nom du fichier html en sortie : $tablo"; 
# debut de la page HTML finale
echo -e "<html>\n<head>\n<meta charset=\"utf8\">\n<title>tableau de liens</title>\n</head>\n<body>\n" > $tablo; 
compteurtableau=0;
for fic in  $(ls $rep) 
do
    let "compteurtableau=compteurtableau+1";
    # lecture d'un fichier d'URL
    echo "<table border=\"1\" align=\"center\">" >> $tablo;
	echo "<tr><td>N°</td><td>Encodage</td><td>http_code</td><td>URL</td><td>PAGES-ASPIREES</td><td>DUMP-TEXT</td></tr>" >> $tablo;
    compteur=0;
    for ligne in `cat $rep/$fic` 
    # ou : for nom in $(cat $fic) 
    { # ou : do
        let "compteur=compteur+1";
        encodage=$(curl -sIL $ligne | egrep -i "charset=" | cut -d"=" -f2 | tr "a-z" "A-Z");
		http_code=$(curl -o ./PAGES-ASPIREES/$compteurtableau-$compteur.html -w "%{http_code}"  $ligne);
		if [[ $encodage == "UTF-8" ]]
			then
				lynx -dump -nolist -assume_charset="$encodage" -display_charset="$encodage" $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt;
				echo -e "<tr><td>$compteur</td><td>$encodage</td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES-ASPIREES/$compteurtableau-$compteur.html">Page aspiree $compteurtableau-$compteur</a></td><td><a href="../DUMP-TEXT/$compteurtableau-$compteur.txt">DP $compteurtableau-$compteur</a></td></tr>\n" >> $tablo; 
			else
				if [[ $ENCODAGE ==""
				echo -e "<tr><td>$compteur</td><td>$encodage</td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES-ASPIREES/$compteurtableau-$compteur.html">Page aspiree $compteurtableau-$compteur</a></td><td>-</td></tr>\n" >> $tablo; 
			fi
    } # ou : done
    echo "</table>" >> $tablo;
    echo "<hr bgcolor=\"blue\"/>" >> $tablo;
done
# fin de la page HTML finale
echo -e "\n</body>\n</html>" >> $tablo; 