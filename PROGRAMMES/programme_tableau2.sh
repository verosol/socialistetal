#!/usr/bin/bash
# MODE D'EMPLOI DU PROGRAMME :
#               bash programme_tableau.sh NOM_DOSSIER_URL NOM_FICHIER_HTML
# le programme prend 2 arguments : 
# - le premier est le nom du dossier contenant les fichiers d'URLs, i.e l'INPUT : $1 par la suite
# - le second est le fichier TABLEAU au format HTML : $2 par la suite
# les 2 sont fournis dans la ligne de commande via un chemin relatif par exemple
#-------------------------------------------------------------------------------
# Phase 1 : ECRITURE ENTETE FICHIER HTML
echo "<html>" > $2 ;
echo "<head><title>TABLEAUX URL</title>
<meta charset=\"UTF-8\" /></head>" >> $2 ;
echo "<body>" >> $2 ;
#-------------------------------------------------------------------------------
compteurtableau=1;
# Phase 2 : traitement de chacun fichier d'URLs
for fichier in $(ls $1)
    do
        echo "<table align=\"center\" border=\"1\">" >> $2 ;
        # Phase 3 : traitement de chaque ligne du fichier d'URL en cours
        # ==> ECRITURE d'une ligne dans le tableau HTML
        compteur=1;
        for ligne in $(cat $1/$fichier)
        do
		code_sortie=$(curl -s -L -o tmp.txt -w "%{http_code}" $ligne | tail -1) ;
		# code_sortie contient le code retour de la connexion HTTP
		if [[ $code_sortie == 200 ]]
			then # URL OK
				# recherche de l'encodage du l'URL en cours
				ENCODAGE=$(curl -sIL "$ligne" | egrep -i "charset" | cut -f2 -d"=" |  tr "[a-z]" "[A-Z]") ;
				echo -e "$compteurtableau::$compteur::$code_sortie::$ENCODAGE::$ligne\n";
				if [[ $ENCODAGE == "UTF-8" ]]
					then
						# aspiration de l'URL
						curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
						# dump de l'URL
						lynx -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
						echo -e "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">page aspirée n° $compteur</a></td><td>$ENCODAGE</td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">DUMP  n° $compteur</a></td></tr>" >> $2 ;
					else
						echo -e "il faut traiter les URLs OK qui ne sont pas a priori en UTF8" ;
						if [[ $ENCODAGE == "" ]]
								then
								#trouver encodage
								curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
								ENCODAGEFILE = $(file -i ./PAGES-ASPIREES/$compteurtableau-$compteur.html | cut -f2 -d"=");
										#if 
										#then
										#else
										#fi
						
						else
						reponse=$(iconv -l | egrep $ENCODAGE) ;
							if [[ $reponse != "" ]]
							then 
							curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
					
						    lynx --assume-charset="$ENCODAGE" --display-charset="$ENCODAGE" -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
							#iconv
							#отправить в таблицу
							else
							fi
						fi
						echo "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td>A COMPLETER</td><td>A COMPLETER</td><td>A COMPLETER</td></tr>" >> $2 ;
					fi
			else # URL "pourrie"
				echo "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td></td><td></td><td></td></tr>" >> $2 ;
			fi
        compteur=$((compteur + 1));
		done;
    echo "</table>" >> $2 ;
    echo "<hr color=\"blue\" />" >> $2 ;
    compteurtableau=$((compteurtableau + 1));
    done;
#-------------------------------------------------------------------------------
# Phase 4 : ECRITURE FIN DE FICHIER HTML
echo "</body>" >> $2 ;
echo "</html>" >> $2 ;
#-------------------------------------------------------------------------------
# c'est fini
exit;