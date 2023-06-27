## VERSION FINALISEE AU 20230627
## En cours de création

# Library ----
#library(plyr)
library(tidyverse)
# library(lubridate)
# library(RcppRoll)
# library(DT)
# library(readxl)
# library(dbplyr)
# library(RPostgreSQL)
# library(rsdmx)
library(sf)
#library(stringi)

source(file = "R/functions.R")

## Import données espèces ONPENOBS et communes ----

amphibiens <- data.table::fread(file = "data/liste_bocage_amphibiens.csv",
                                encoding = "UTF-8",
                                colClasses = c("codeInseeCommune" = "character",
                                               "codeInseeDepartement" = "character",
                                               "codeInseeRegion" = "character",
                                               "codeInseeEPCI" = "character", 
                                               "idCampanuleProtocole" = "character")) 

insectes <- data.table::fread(file = "data/liste_bocage_insectes.csv",
                              encoding = "UTF-8",
                              colClasses = c("codeInseeCommune" = "character",
                                             "codeInseeDepartement" = "character",
                                             "codeInseeRegion" = "character",
                                             "codeInseeEPCI" = "character", 
                                             "idCampanuleProtocole" = "character"))   

chiropteres <- data.table::fread(file = "data/liste_bocage_chiropteres.csv",
                                encoding = "UTF-8",
                                colClasses = c("codeInseeCommune" = "character",
                                               "codeInseeDepartement" = "character",
                                               "codeInseeRegion" = "character",
                                               "codeInseeEPCI" = "character", 
                                               "idCampanuleProtocole" = "character")) 

mammiferes <- data.table::fread(file = "data/liste_bocage_mammiferes.csv",
                                encoding = "UTF-8",
                                colClasses = c("codeInseeCommune" = "character",
                                               "codeInseeDepartement" = "character",
                                               "codeInseeRegion" = "character",
                                               "codeInseeEPCI" = "character", 
                                               "idCampanuleProtocole" = "character"))    

mollusque <- data.table::fread(file = "data/liste_bocage_mollusque.csv",
                               encoding = "UTF-8",
                               colClasses = c("codeInseeCommune" = "character",
                                              "codeInseeDepartement" = "character",
                                              "codeInseeRegion" = "character",
                                              "codeInseeEPCI" = "character", 
                                              "idCampanuleProtocole" = "character"))   

oiseaux <- data.table::fread(file = "data/liste_bocage_oiseaux.csv",
                             encoding = "UTF-8",
                             colClasses = c("codeInseeCommune" = "character",
                                            "codeInseeDepartement" = "character",
                                            "codeInseeRegion" = "character",
                                            "codeInseeEPCI" = "character", 
                                            "idCampanuleProtocole" = "character")) 

reptiles <- data.table::fread(file = "data/liste_bocage_reptiles.csv",
                              encoding = "UTF-8",
                              colClasses = c("codeInseeCommune" = "character",
                                             "codeInseeDepartement" = "character",
                                             "codeInseeRegion" = "character",
                                             "codeInseeEPCI" = "character", 
                                             "idCampanuleProtocole" = "character"))    



## Création d'une seule table especes ----

especes <- dplyr::bind_rows(amphibiens, insectes, chiropteres, mammiferes, mollusque, oiseaux, reptiles) 

## Création pour chaque groupe d'une liste d'espèce par code INSEE_commune ----

sp_amphibiens_commune <- amphibiens%>%
  group_by(codeInseeCommune) %>%
  summarise(amphibiens = paste(nomVernaculaire, collapse = ', '))

sp_insectes_commune <- insectes%>%
  group_by(codeInseeCommune) %>%
  summarise(insectes = paste(nomVernaculaire, collapse = ', '))

sp_chiropteres_commune <- chiropteres%>%
  group_by(codeInseeCommune) %>%
  summarise(chiropteres = paste(nomVernaculaire, collapse = ', '))

sp_mammiferes_commune <- mammiferes%>%
  group_by(codeInseeCommune) %>%
  summarise(mammiferes = paste(nomVernaculaire, collapse = ', '))

sp_mollusque_commune <- mollusque%>%
  group_by(codeInseeCommune) %>%
  summarise(mollusque = paste(nomVernaculaire, collapse = ', '))

sp_oiseaux_commune <- oiseaux%>%
  group_by(codeInseeCommune) %>%
  summarise(oiseaux = paste(nomVernaculaire, collapse = ', '))

sp_reptiles_commune <- reptiles%>%
  group_by(codeInseeCommune) %>%
  summarise(reptiles = paste(nomVernaculaire, collapse = ', '))

## Jointure à la couche commune ----
