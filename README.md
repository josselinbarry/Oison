# Inventaire Bocage : OpenObs et OISON

Ce projet vise, à partir d'extractions issues des bases de données OpenObs et OISON, à compiler, par commune, par maille et par groupe, les observations d'espèces concernées par la liste identifiée comme prioritaire en Bretagne, dans le cadre des "Inventaires bocage".

Ces préidentifications d'espèces pourront servir aux agents chargés de la réalisation des inventaires, à saisir ensuite sous OISON.

Parallèlement, l'outil permet d'analyser rapidement les données OISON produites régionalement, lors de la diffusion des données en interne.

## Import des données

### Openobs :

Les données sont téléchargées librement depuis le site <https://openobs.mnhn.fr/> à partir de la liste d'espèces régionale, retenue dans le cadre du projet Bocage - Bretagne.

### OISON :

Une couche géopackage est régulièrement mise à disposition par Caroline PENIL et Benoît Richard, à partir d'un dump de la base OISON.

## Visualisation des données OpenObs

### Ajout des codes manquants

#### Ajout du code INSEE commune

Certaines observations OpenObs ne disposent pas de l'information code INSEE commune. L'outil permet de rattacher le code INSEE de la commune la plus proche.

#### Ajout du code maille 5km (INPN)

Appariement du code maille 5km de l'INPN par jointure spatiale, aux observations OpenObs. L'outil permet également de rattacher le code INPN de la maille la plus proche.

### Synthèse des listes d'espèce par groupe ...

#### ... et par communes

Obtention d'une table regroupant par commune (ligne) et par groupe d'espèces (colonne : Amphibiens, Insectes, Chiroptères, Mammifères (hors chiroptères), Oiseaux, Mollusques et Reptiles) les espèces ayant fait l'objet d'une observation dans OpenObs.

![](images/coronelle_lisse_point_commune-01.png){width="400"}

*Exemple de la visualisation des données d'observations ponctuelles de la Coronelle lisse et de la couche de synthèse par commune de la présence de l'espèce.*

#### ... et par mailles 5km

Obtention, de la même manière, d'une table regroupant par maille (ligne) et par groupe (colonne), les espèces observées dans OpenObs.

*INSERT PICTURE*
*Exemple de la visualisation de la même donnée avec la couche de synthèse par maille.*

### Export des couches géographiques commune et maille, contenant, par groupe, la liste des epsèces observées dans OpenObs

Jointure des précédentes tables respectivement aux couche commune et maille 5 km, puis export au format géopackage.

## Analyses régionale et départementale des données OISON liées aux "Inventaires Bocage" :

Cette base est dédiée à nos saisies d'observations en interne. Elle permet de suivre la dynamique de saisie, selon les territoires et dans le temps.

-   \
    *![](images/graph_dprt_grpe.PNG){width="400"}*

-   Nombre de saisie par département en fonction du type de recherche effectué (cherché ou fortuit)

    ![](observations_recherche_dept.png){width="439"}

-   Nombre de saisie au fil du temps

    ![](observations_date.png){width="400" height="180"}

-   Nombre de saisies par agent

    *CREATE AND INSERT GRAPH*
