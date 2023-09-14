# Oison

Ce projet vise, à partir d'extractions issues de OpenObs et de OISON, à compiler, par commune et par groupe, les espèces concernées par la liste identifiée comme prioritaire en Bretagne, dans le cadre des "Inventaires bocage".

Ces préidentifications d'espèces pourront servir aux agents chargés de la réalisation des inventaires, à saisir ensuite sous OISON.

## Import des données

### Openobs :

Les données sont téléchargées librement depuis le site <https://openobs.mnhn.fr/> à partir de la liste d'espèces régionale, retenue dans le cadre du projet Bocage - Bretagne.

### OISON :

Une couche géopackage est régulièrement mise à disposition par Caroline PENIL et Benoît Richard, à partir d'un dump de la base OISON.

## Ajout du code INSEE commune

Certaines observations ne disposent pas de l'information code INSEE commune. L'outil permet de rattacher le code INSEE de la commune la plus proche.

## Synthèse des listes d'espèce par groupe et par commune

Obtention d'une table regroupant par commune (ligne) et par groupe d'espèces (colonne : Amphibiens, Insectes, Chiroptères, Mammifères (hors chiroptères), Oiseaux, Mollusques et Reptiles) les espèces ayant fait l'objet d'une observation dans OpenObs et dans OISON.

## Export d'une couche géographique commune contenant, par groupe et par type de donnée, la liste des epsèces

Jointure de la précédente table à la couche commune et export au format géopackage.

## Traitement propres aux données OISON :

Cette base étant dédiée à nos saisies d'observations en interne, elle permet de suivre la dynamique de saisie, selon les territoire et dans le temps.

-   Nombre de saisie par département en fonction des groupes INPN
-   Nombre de saisie par département en fonction du type de recherche effectué (recherché ou fortuit)
-   Nombre de saisie au fil du temps
-   Nombre de saisies par agent
