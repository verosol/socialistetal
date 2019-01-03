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
      code_sortie=$(curl -0  tmp.txt -w "%{http_code}" $ligne | -1) ;
      if [[ $code_sortie == 200 ]]
      then
     ENCODAGE=$(curl -I "$ligne" | egrep -i "charset" | cut -d"=" -f2 | tr "[a-z]" "[A-Z]");
    if [[ $ENCODAGE == "UTF-8" ]]
     then
      curl -o "./PAGES-ASPIREES/$compteurtableau-$compteur.html" $ligne ;
      lynx -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
      echo  "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">page aspirée n° $compteur</a></td><td>$ENCODAGE</td></tr>" >> $2 ;
    else
    fi
      else
            echo "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td></td><td></td></tr>" >> $2 ;
       fi
 	  compteur=$((compteur + 1)) ;
      done;
      echo "</table>" >>$2 ;
      echo "<hr color=\"red\"  />" >> $2 ;
      compteurtableau=$((compteurtableau + 1));
done;
echo "</body>" >> $2 ;
echo "</html>" >> $2 ;
exit;
