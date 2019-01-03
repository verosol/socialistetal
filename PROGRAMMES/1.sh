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
echo "<h1>Tableau HTML</h1>" >> $2;
echo "<h2 align="center">Mot choisi: 'socialiste|socialista|cоціал'</h2>" >> $2;
echo "<h4 align="center">Veronika SOLOPOVA & Lucía ORMAECHEA </h4>" >> $2;

#echo "<meta name="author" content="Veronika SOLOPOVA" >> $2;
#echo "<meta name="author" content="Lucía ORMAECHEA GRIJALBA" >> $2;
#echo "<meta name="description" content="Voici le tableau HTML concernant le mot 'socialiste'" >> $2;

echo "<head>" >> $2 ;
echo    "<title>TABLEAUX URL</title>" >> $2 ;
echo    "<meta charset=\"UTF-8\">" >> $2 ;
echo    "<style>" >> $2 ;
echo    "body" >> $2 ;
echo    "{" >> $2 ;
echo    "background-color:#e6ffff;" >> $2 ;
echo    "}" >> $2 ;
echo    "h1" >> $2 ;
echo    "{" >> $2 ;
echo    "color: black;" >> $2 ;
echo    "text-align: center;" >> $2 ;
echo    "font-family: "Times New Roman", Times, serif" >> $2 ;
echo    "}" >> $2 ;
echo    "td" >> $2 ;
echo    "{" >> $2 ;
echo    "text-align: center;" >> $2 ;
echo    "font-family: "Times New Roman", Times, serif" >> $2 ;
echo    "}" >> $2 ;
echo    "</style>" >> $2 ;
echo "</head>" >> $2 ;
echo "<body>" >> $2 ;


########################################
#-------------------------------------------------------------------------------
compteurtableau=1;
# Phase 2 : traitement de chacun fichier d'URLs
for fichier in $(ls $1)
    do
        echo "<table align=\"center\" border=\"1\">" >> $2 ;
        echo "<tr bgcolor=\"#0099cc\"><td><b>N°</b></td><td><b>Code HTTP</b></td><td><b>Statut Curl</b></td><td><b>URL</b></td><td><b>Page Aspirée</b></td><td><b>Encodage</b></td><td><b>Dump</b></td><td><b>Contexte</b></td><td><b>Contexte HTML</b></td><td><b>Fq Motif</b></td><td><b>Index</b></td><td><b>Bigramme</b></td></tr>" >> $2 ;
        # Phase 3 : traitement de chaque ligne du fichier d'URL en cours
        # ==> ECRITURE d'une ligne dans le tableau HTML
        compteur=1;
        for ligne in $(cat $1/$fichier)
        do
		code_sortie=$(curl -s -L -o tmp.txt -w "%{http_code}" $ligne | tail -1) ;

        # 2. RECUPERATION DU CODE RETOUR HTTP ET DE LA PAGE
        ##statut=$(curl --silent --output ./PAGES-ASPIREES/$compteurtableau-$compteur.html --write-out "%{http_code}" $ligne);
        statut=$(curl -sI $ligne | head -n 1);
        # code_sortie contient le code retour de la connexion HTTP

		if [[ $code_sortie == 200 ]]
			then # URL OK
				# recherche de l'encodage du l'URL en cours
				ENCODAGE=$(curl -sIL "$ligne" | egrep -i "charset" | cut -f2 -d"=" |  tr "[a-z]" "[A-Z]" |  tr -d "\n" |  tr -d "\r") ;
echo -e "<$ENCODAGE>\n";
echo "curl -sIL \"$ligne\" | egrep -i \"charset\" | cut -f2 -d\"=\" |  tr \"[a-z]\" \"[A-Z]\" |  tr -d \"\n\" |  tr -d \"\r\"";
				echo -e "$compteurtableau::$compteur::$code_sortie::$ENCODAGE::$ligne\n";

				if [[ $ENCODAGE == "UTF-8" ]]
					then
						echo -e "ENCODAGE initial <$ENCODAGE> OK : on passe au traitement \n";
						# aspiration de l'URL
						curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
						# dump de l'URL
						lynx -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
						#---------------------------------------------------------------------------
						# 1. contexte
						egrep -i "$3" ./DUMP-TEXT/$compteurtableau-$compteur.txt > ./CONTEXTES/$compteurtableau-$compteur.txt;
						# 2. Fq motif
						nbmotif=$(egrep -coi "$3" ./DUMP-TEXT/$compteurtableau-$compteur.txt);
						# 3. contexte html
						./minigrepmultilingue-v2/minigrepmultilingue-macosx "UTF-8" ./DUMP-TEXT/$compteurtableau-$compteur.txt ./minigrepmultilingue-v2/motif-regexp.txt
						mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteur.html ;
						# 4. index hierarchique
						egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt | sort | uniq -c | sort -r > ./DUMP-TEXT/index-$compteurtableau-$compteur.txt ;
						# 5. bigramme
						egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt > bi1.txt;
						tail -n +2 bi1.txt > bi2.txt ;
						paste bi1.txt bi2.txt > bi3.txt ;
						cat bi3.txt | sort | uniq -c | sort -r >  ./DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt ;
						#---------------------------------------------------------------------------
						echo "<tr><tr bgcolor=\"#b3e6ff\"><td><b>$compteur</b></td><td><b>$code_sortie</b></td><td>$statut</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">P.A.  $compteurtableau-$compteur</a></td><td><b>$ENCODAGE</b></td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">Dump $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.txt\">CT $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.html\">CTh $compteurtableau-$compteur</a></td><td><b>$nbmotif</b></td><td><a href=\"../DUMP-TEXT/index-$compteurtableau-$compteur.txt\">Ind $compteurtableau-$compteur</a></td><td><a href=\"../DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt\">Bigr $compteurtableau-$compteur</a></td></tr bgcolor=\"#b3e6ff\"></tr>" >> $2 ;
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
								# LA SUITE : est-ce que ENCODAGEFILE vaut UTF8 ou non ??? à vous de jouer...
                                    if [[ $ENCODAGEFILE == "UTF-8" ]]
                                            then
                                            # on refait le même traitement que ci-dessus !! en l'adaptant si nécessairethen
                                                echo -e "ENCODAGE initial <$ENCODAGEFILE> OK : on passe au traitement \n";
                                                #  aspiration de l'URL
                                                curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
                                                # dump de l'URL
                                                lynx -assume_charset="$ENCODAGEFILE" -display_charset="$ENCODAGEFILE" -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
                                                # 1. contexte
                                                    egrep -i "$3" ./DUMP-TEXT/$compteurtableau-$compteur.txt > ./CONTEXTES/$compteurtableau-$compteur.txt;
                                                        # 2. Fq motif
                                                    nbmotif=$(egrep -coi "$3" ./DUMP-TEXT/$compteurtableau-$compteur.txt);
                                                    # 3. contexte html
                                                    ./minigrepmultilingue-v2/minigrepmultilingue-macosx "UTF-8" ./DUMP-TEXT/$compteurtableau-$compteur.txt ./minigrepmultilingue-v2/motif-regexp.txt
                                                    mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteur.html ;
                                                        # 4. index hierarchique
                                                    egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt | sort | uniq -c | sort -r > ./DUMP-TEXT/index-$compteurtableau-$compteur.txt ;
                                                    # 5. bigramme
                                                    egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt > bi1.txt;
                                                    tail -n +2 bi1.txt > bi2.txt ;
                                                    paste bi1.txt bi2.txt > bi3.txt ;
                                                    cat bi3.txt | sort | uniq -c | sort -r >  ./DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt ;
                                                    #---------------------------------------------------------------------------
                                                    echo "<tr><tr bgcolor=\"#b3e6ff\"><td><b>$compteur</b></td><td><b>$code_sortie</b></td><td>$statut</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">P.A.  $compteurtableau-$compteur</a></td><td><b>$ENCODAGEFILE</b></td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">Dump $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.txt\">CT $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.html\">CTh $compteurtableau-$compteur</a></td><td><b>$nbmotif</b></td><td><a href=\"../DUMP-TEXT/index-$compteurtableau-$compteur.txt\">Ind $compteurtableau-$compteur</a></td><td><a href=\"../DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt\">Bigr $compteurtableau-$compteur</a></td></tr bgcolor=\"#b3e6ff\"></tr>" >> $2 ;
                                    else
                                                   # on est dans la cas ou ENCODAGE n est pas UTF et n est pas vide pour continuer il faut s assurer aue ENCODAGE est connu de iconv et de lynx


                                                    curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
                                                    # dump de l'URL
                                                    lynx -assume_charset="$ENCODAGE" -display_charset="$ENCODAGE" -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
                                                    iconv -f $ENCODAGE -t UTF-8 ./DUMP-TEXT/$compteurtableau-$compteur.txt  > ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt  ;
                                                    egrep -i "$3" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt > ./CONTEXTES/$compteurtableau-$compteur.txt;
                                                    # 2. Fq motif
                                                    nbmotif=$(egrep -coi "$3" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt);
                                                    # 3. contexte html
                                                    ./minigrepmultilingue-v2/minigrepmultilingue-macosx "UTF-8" ./DUMP-TEXT/$compteurtableau-$compteur.txt ./minigrepmultilingue-v2/motif-regexp.txt
                                                    mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteur.html ;
                                                    # 4. index hierarchique
                                                    egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt | sort | uniq -c | sort -r > ./DUMP-TEXT/index-$compteurtableau-$compteur.txt ;
                                                    # 5. bigramme
                                                    egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt > bi1.txt;
                                                    tail -n +2 bi1.txt > bi2.txt ;
                                                    paste bi1.txt bi2.txt > bi3.txt ;
                                                    cat bi3.txt | sort | uniq -c | sort -r >  ./DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt ;
                                                   echo "<tr><tr bgcolor=\"#b3e6ff\"><td><b>$compteur</b></td><td><b>$code_sortie</b></td><td>$statut</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">P.A.  $compteurtableau-$compteur</a></td><td><b>$ENCODAGE</b></td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">Dump $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.txt\">CT $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.html\">CTh $compteurtableau-$compteur</a></td><td><b>$nbmotif</b></td><td><a href=\"../DUMP-TEXT/index-$compteurtableau-$compteur.txt\">Ind $compteurtableau-$compteur</a></td><td><a href=\"../DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt\">Bigr $compteurtableau-$compteur</a></td></tr bgcolor=\"#b3e6ff\"></tr>" >> $2 ;
                                fi
                        else
								#ici curl a renvoyé un truc non vide, mais c'est pas UTF8
								reponse=$(iconv -l | egrep "$ENCODAGE") ;
								if  [[ $reponse != "" ]]
									then
										echo -e "ENCODAGE initial <$ENCODAGE> OK, connu de iconv : on passe au traitement \n";
										curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
										# dump de l'URL
										lynx -assume_charset="$ENCODAGE" -display_charset="$ENCODAGE" -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
										iconv -f $ENCODAGE -t UTF-8 ./DUMP-TEXT/$compteurtableau-$compteur.txt  > ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt  ;
                                        egrep -i "$3" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt > ./CONTEXTES/$compteurtableau-$compteur.txt;
                                        # 2. Fq motif
                                        nbmotif=$(egrep -coi "$3" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt);
                                        # 3. contexte html
                                       ./minigrepmultilingue-v2/minigrepmultilingue-macosx "UTF-8" ./DUMP-TEXT/$compteurtableau-$compteur.txt ./minigrepmultilingue-v2/motif-regexp.txt
                                        mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteur.html ;
                                        # 4. index hierarchique
                                        egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt | sort | uniq -c | sort -r > ./DUMP-TEXT/index-$compteurtableau-$compteur.txt ;
                                        # 5. bigramme
                                        egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur-utf8.txt > bi1.txt;
                                        tail -n +2 bi1.txt > bi2.txt ;
                                        paste bi1.txt bi2.txt > bi3.txt ;
                                        cat bi3.txt | sort | uniq -c | sort -r >  ./DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt ;
                                        echo "<tr><tr bgcolor=\"#b3e6ff\"><td><b>$compteur</b></td><td><b>$code_sortie</b></td><td>$statut</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">P.A.  $compteurtableau-$compteur</a></td><td><b>$ENCODAGE</b></td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">Dump $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.txt\">CT $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.html\">CTh $compteurtableau-$compteur</a></td><td><b>$nbmotif</b></td><td><a href=\"../DUMP-TEXT/index-$compteurtableau-$compteur.txt\">Ind $compteurtableau-$compteur</a></td><td><a href=\"../DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt\">Bigr $compteurtableau-$compteur</a></td></tr bgcolor=\"#b3e6ff\"></tr>" >> $2 ;

									else
										echo -e "L'encodage initial n'est pas un encodage pertinent, il faut essayer autre chose...\n";
										echo -e "Par exemple en allant essayer d'utiliser file ou d'extraire le charset dans la page aspirée...\n";
										# code déjà écrit plus haut (++++++) : à réutiliser et à adapter.... à vous de jouer
                                        ENCODAGEFILE=$(file -i ./PAGES-ASPIREES/$compteurtableau-$compteur.html | cut -d"=" -f2);
                                        echo -e "ENCODAGE initial vide. ENCODAGE extrait via file : $ENCODAGEFILE \n";
                                        echo -e "Il faut désormais s'assurer que cet encodage peut être OK ou pas... \n";
                                        # LA SUITE : est-ce que ENCODAGEFILE vaut UTF8 ou non ??? à vous de jouer...
                                        # on refait le même traitement que ci-dessus !! en l'adaptant si nécessairethen
                                        echo -e "ENCODAGE initial <$ENCODAGEFILE> OK : on passe au traitement \n";
                                        #  aspiration de l'URL
                                        curl -sL -o  ./PAGES-ASPIREES/$compteurtableau-$compteur.html $ligne ;
                                        # dump de l'URL
                                        lynx -assume_charset="$ENCODAGEFILE" -display_charset="$ENCODAGEFILE" -dump -nolist $ligne > ./DUMP-TEXT/$compteurtableau-$compteur.txt ;
                                        # 1. contexte
                                        egrep -i "$3" ./DUMP-TEXT/$compteurtableau-$compteur.txt > ./CONTEXTES/$compteurtableau-$compteur.txt;
                                        # 2. Fq motif
                                        nbmotif=$(egrep -coi "$3" ./DUMP-TEXT/$compteurtableau-$compteur.txt);
                                        # 3. contexte html
                                       ./minigrepmultilingue-v2/minigrepmultilingue-macosx "UTF-8" ./DUMP-TEXT/$compteurtableau-$compteur.txt ./minigrepmultilingue-v2/motif-regexp.txt
                                        mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteur.html ;
                                        # 4. index hierarchique
                                        egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt | sort | uniq -c | sort -r > ./DUMP-TEXT/index-$compteurtableau-$compteur.txt ;
                                        # 5. bigramme
                                        egrep -o "\w+" ./DUMP-TEXT/$compteurtableau-$compteur.txt > bi1.txt;
                                        tail -n +2 bi1.txt > bi2.txt ;
                                        paste bi1.txt bi2.txt > bi3.txt ;
                                        cat bi3.txt | sort | uniq -c | sort -r >  ./DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt ;
										echo "<tr><tr bgcolor=\"#b3e6ff\"><td><b>$compteur</b></td><td><b>$code_sortie</b></td><td>$statut</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td><a target=\"_blank\" href=\"../PAGES-ASPIREES/$compteurtableau-$compteur.html\">P.A.  $compteurtableau-$compteur</a></td><td>$ENCODAGEFILE</td><td><a target=\"_blank\" href=\"../DUMP-TEXT/$compteurtableau-$compteur.txt\">Dump $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.txt\">CT $compteurtableau-$compteur</a></td><td><a href=\"../CONTEXTES/$compteurtableau-$compteur.html\">CTh $compteurtableau-$compteur</a></td><td>$nbmotif</td><td><a href=\"../DUMP-TEXT/index-$compteurtableau-$compteur.txt\">Ind $compteurtableau-$compteur</a></td><td><a href=\"../DUMP-TEXT/bigramme-$compteurtableau-$compteur.txt\">Bigr $compteurtableau-$compteur</a></td></tr bgcolor=\"#b3e6ff\"></tr>" >> $2 ;									fi
							fi
					fi
			else # URL "pourrie", pb connexion http, on écrit quasiment rien dans la ligne du tableau !!!!
				echo -e "PB....$compteurtableau::$compteur::$code_sortie::::$ligne\n";
				echo "<tr><tr bgcolor=\"#ff8566\"><td>$compteur</td><td><font color=\"red\"><b>$code_sortie</b></td><td>$statut</td><td><a target=\"_blank\" href=\"$ligne\">$ligne</a></td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><tr bgcolor=\"#ff8566\"></tr>" >> $2 ;
			fi
        compteur=$((compteur + 1));
		echo -e "_____________________________________________________________________\n";
		done;
    echo "</table>" >> $2 ;
    echo "<hr width=600 noshade align="center" size=5 color=\"red\" />" >> $2 ;
    compteurtableau=$((compteurtableau + 1));
    done;
#-------------------------------------------------------------------------------
# Phase 4 : ECRITURE FIN DE FICHIER HTML
echo "</body>" >> $2 ;
echo "</html>" >> $2 ;
#-------------------------------------------------------------------------------
# c'est fini
exit;
