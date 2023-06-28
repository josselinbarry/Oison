# Oison

Ce projet vise, à partir d'extractions issues d'OpenObs, à compiler, par commune et par groupe, les espèces concernées par la liste identifiée comme prioritaire en Bretagne.

Ces préidentifications d'espèces pourront servir aux agents chargés de la réalisation des inventaires à saisir sous OISON.

## Import des données

Les données sont téléchargées depuis le site https://openobs.mnhn.fr/ à partir de la liste d'espèces régionale retenue dans le cadre du projet Bocage - Bretagne.

## Ajout du code INSEE commune

Certaines observations ne disposent pas de l'information code INSEE commune.
L'outil permet de rattacher le code INSEE de la commune la plus proche. 

## Synthèse des listes d'espèce par groupe et par commune

Obtention d'une table regroupant par commune (ligne) et par groupe d'espèces (colonne : Amphibiens, Insectes, Chiroptères, Mammifères (hors chiroptères), Oiseaux, Mollusques et Reptiles) les espèces ayant fait l'objet d'une observation dans OpenObs.

## Export d'une couche géographique commune contenant par groupe la liste des epsèces

Jointure de la précédente table à la couche commune et export au format géopackage.



