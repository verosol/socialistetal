#!/usr/bin/bash
# MODE D'EMPLOI DU PROGRAMME :
#               bash programme_tableau.sh NOM_DOSSIER_URL NOM_FICHIER_HTML
# le programme prend 3 arguments :
# - le premier est le nom du dossier contenant les fichiers d'URLs, i.e l'INPUT : $1 par la suite
# - le second est le fichier TABLEAU au format HTML : $2 par la suite
#le troisieme est le motif dans les langues differants  $3
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
				ENCODAGE=$(curl -sIL "$ligne" | egrep -i "charset" | cut -f2 -d"=" |  tr "[a-z]" "[A-Z]" |  tr -d "\n" |  tr -d "\r") ;
				echo -e "$compteurtableau::$compteur::$code_sortie::$ENCODAGE::$ligne\n";
				if [[ $ENCODAGE == "UTF-8" ]]
					then
						echo -e "ENCODAGE initial <$ENCODAGE> OK : on passe au traitement \n";
						# aspiration de l'URL
						curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
						# dump de l'URL
						lynx -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
                        egrep -C 1 $3 ./DUMP-TEXT/$compteurtableau-$compteur.txt ./CONTEXTES/$compteurtableau-$compteur-contextes.txt;# il faut l'integrer dans les autres boucles
                        egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt > b1 ;
                        tail -n +2 b1 > b2 ;
                        paste b1 b2 | sort -fg | uniq -ic | sort -rn > ./DUMP-TEXT/$compteurtableau-$compteur-bigram.txt ;

						# reste à faire : contexte, bigramme, comptage occurrences dans DUMP
						# ET ajouter les colonnes qui vont avec...
						#---------------------------------------------------------------------------
						echo "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">page aspirée n° $compteur</a></td><td>$ENCODAGE</td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">DUMP  n° $compteur</a></td></tr>" >> $2 ;
					else
						echo -e "==> il faut traiter les URLs OK qui ne sont pas a priori en UTF8\n" ;
						echo -e "ENCODAGE initial : <$ENCODAGE> \n";
						if [[ $ENCODAGE == "" ]]
							then
								# On cherche l'encodage de la page en appliquant la commande file sur la page aspirée (++++++)
								curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
								ENCODAGEFILE=$(file -i ./PAGES-ASPIREES/$compteurtableau-$compteur.html | cut -d"=" -f2);
								echo -e "ENCODAGE initial vide. ENCODAGE extrait via file : $ENCODAGEFILE \n";
								echo -e "Il faut désormais s'assurer que cet encodage peut être OK ou pas... \n";
                                    if [[ $ENCODAGEFILE == "WINDOWS-1251" ]]
									 then
										iconv -f WINDOWS-1251 -t UTF-8 
									#else
										# on refait le même traitement que ci-dessous !! en l'adaptant si nécessaire
									#fi
							else
								#ici curl a renvoyé un truc non vide, mais c'est pas UTF8
								reponse=$(iconv -l | egrep "$ENCODAGE") ;
								if  [[ $reponse != "" ]]
									then
										echo -e "ENCODAGE initial <$ENCODAGE> OK, connu de iconv : on passe au traitement \n";
										curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
										# dump de l'URL
										lynx --assume-charset="$ENCODAGE" --display-charset="$ENCODAGE" -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
										iconv -f $ENCODAGE -t utf-8 ./DUMP-TEXT/$compteurtableau-$compteur.txt  > ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt  ;
										echo "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">page aspirée n° $compteur</a></td><td>$ENCODAGE</td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur-utf8.txt\">DUMP  n° $compteur</a></td></tr>" >> $2 ;
									else
										echo -e "L'encodage initial n'est pas un encodage pertinent, il faut essayer autre chose...\n";
										echo -e "Par exemple en allant essayer d'utiliser file ou d'extraire le charset dans la page aspirée...\n";
										# code déjà écrit plus haut (++++++) : à réutiliser et à adapter.... à vous de jouer
										echo "<tr><td>$compteur</td><td>$code_sortie</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td>A COMPLETER</td><td>A COMPLETER</td><td>A COMPLETER</td></tr>" >> $2 ;
									fi
							fi
					fi
			else # URL "pourrie", pb connexion http, on écrit quasiment rien dans la ligne du tableau !!!!
				echo -e "PB....$compteurtableau::$compteur::$code_sortie::::$ligne\n";
				echo "<tr><td>$compteur</td><td><font color=\"red\"><b>$code_sortie</b></td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td>-</td><td>-</td><td>-</td></tr>" >> $2 ;
			fi
        compteur=$((compteur + 1));
		echo -e "_____________________________________________________________________\n";
		done;
    echo "</table>" >> $2 ;
    echo "<hr color=\"red\" />" >> $2 ;
    compteurtableau=$((compteurtableau + 1));
    done;
#-------------------------------------------------------------------------------
# Phase 4 : ECRITURE FIN DE FICHIER HTML
echo "</body>" >> $2 ;
echo "</html>" >> $2 ;
#-------------------------------------------------------------------------------
# c'est fini
exit;
