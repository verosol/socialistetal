#!/usr/bin/bash
 #bash programme_tableau.sh Dossier_URL FICHIER_HTML

echo "<html>" > $2 ;
echo "<head><title>PREMIERE PAGE</title>
<meta charset=\"UTF-8\"></head>" >>  $2 ;
echo "<body>" >> $2 ;
#_________________________________________
compteurtableau=1;
for fichier in $(ls $1)
    do 
    echo "<table border=\"1\">" >> $2 ;
     #__________________________________________
      compteur=1;
      for ligne in $(cat $1/$fichier)
      do 
     ENCODAGE=$(curl -I "$ligne" | egrep -i "charset" | cut -f2 -d"=");
      curl -o "./PAGES-ASPIREES/$compteurtableau-$compteur.html" $ligne ;
      echo "<tr> <td>$compteur</td><td><a target=\"_blank\" href=\"$ligne\"> $ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">page aspirée № $compteur</a></td><td>$ENCODAGE</td></tr>" >> $2 ;
 	  compteur=$((compteur + 1)) ;
      done;
      echo "</table>" >>$2 ;
      echo "<hr color=\"red\"  />" >> $2 ;
      compteurtableau=$((compteurtableau + 1));
done;
echo "</body>" >> $2 ;
echo "</html>" >> $2 ;
exit;