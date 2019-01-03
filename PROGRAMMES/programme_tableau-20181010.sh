#!/usr/bin/bash
# MODE D'EMPLOI DU PROGRAMME :
#               bash programme_tableau.sh FICHIER_URL FICHIER_HTML
# le programme prend 2 arguments : 
# - le premier est le fichier d'URLs, i.e l'INPUT : $1 par la suite
# - le second est le fichier TABLEAU au format HTML : $2 par la suite
# les 2 sont fournis dans la ligne de commande via un chemin relatif par exemple
#-------------------------------------------------------------------------------
# Phase 1 : ECRITURE ENTETE FICHIER HTML
echo "<html>" > $2 ;
echo "<head><title>PREMIERE PAGE</title>
<meta charset=\"UTF-8\" /></head>" >> $2 ;
echo "<body>" >> $2 ;
echo "<table border=\"1\">" >> $2 ;
#-------------------------------------------------------------------------------
# Phase 2 : traitement de chaque ligne du fichier d'URL
# ==> ECRITURE d'une ligne dans le tableau HTML
compteur=1;
for ligne in $(cat $1)
    do
    curl -o toto.txt $ligne ; #### A REPRENDRE
    echo "<tr><td>$compteur</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td>ICI</td></tr>" >> $2 ;#### A REPRENDRE
    compteur=$((compteur + 1));
    done;
#-------------------------------------------------------------------------------
# Phase 3 : ECRITURE FIN DE FICHIER HTML
echo "</table>" >> $2 ;
echo "</body>" >> $2 ;
echo "</html>" >> $2 ;
#-------------------------------------------------------------------------------
# c'est fini
exit;