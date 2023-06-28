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

## Import données espèces ONPENOBS et communes au 20230622 ----

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

communes <- sf::read_sf(dsn = "data/COMMUNE.shp")

## Création d'une couche géographique especes ----

especes <- dplyr::bind_rows(amphibiens, insectes, chiropteres, mammiferes, mollusque, oiseaux, reptiles) 

especes_geom <- especes %>% 
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), remove = FALSE, crs = 4326) %>%
  st_transform(especes_geom, crs = 2154)

## Ajout des code INSEE commune pour les observations ponctuelles et centroïde commune qui ne sont pas renseignées

cd_ajoute_especes <- especes_geom %>%
  select(idSINPOccTax, codeInseeCommune, precisionLocalisation) %>%
  filter((codeInseeCommune == '' | is.na(codeInseeCommune)) &
              precisionLocalisation %in% c('XY centroïde commune','XY centroïde ligne/polygone','XY point',  'XY centroïde maille' )) %>%
  st_join(communes) %>% 
  mutate(codeInseeCommune = INSEE_COM) %>%
  distinct() %>%
  select(idSINPOccTax, codeInseeCommune, precisionLocalisation)

## Création pour chaque groupe d'une liste d'espèce par code INSEE_commune ----

sp_amphibiens_commune <- amphibiens%>%
  group_by(codeInseeCommune) %>%
  summarise(amphibiens = paste(unique(nomVernaculaire), collapse = ', '))

sp_insectes_commune <- insectes%>%
  group_by(codeInseeCommune) %>%
  summarise(insectes = paste(unique(nomVernaculaire), collapse = ', '))

sp_chiropteres_commune <- chiropteres%>%
  group_by(codeInseeCommune) %>%
  summarise(chiropteres = paste(unique(nomVernaculaire), collapse = ', '))

sp_mammiferes_commune <- mammiferes%>%
  group_by(codeInseeCommune) %>%
  summarise(mammiferes = paste(unique(nomVernaculaire), collapse = ', '))

sp_mollusque_commune <- mollusque%>%
  group_by(codeInseeCommune) %>%
  summarise(mollusque = paste(unique(nomVernaculaire), collapse = ', '))

sp_oiseaux_commune <- oiseaux%>%
  group_by(codeInseeCommune) %>%
  summarise(oiseaux = paste(unique(nomVernaculaire), collapse = ', '))

sp_reptiles_commune <- reptiles%>%
  group_by(codeInseeCommune) %>%
  summarise(reptiles = paste(unique(nomVernaculaire), collapse = ', '))

## Jointure à la couche commune ----

sp_communes <- communes %>% 
  dplyr::left_join(sp_amphibiens_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>%
  dplyr::left_join(sp_insectes_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>% 
  dplyr::left_join(sp_chiropteres_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>% 
  dplyr::left_join(sp_mammiferes_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>% 
  dplyr::left_join(sp_mollusque_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>% 
  dplyr::left_join(sp_oiseaux_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>% 
  dplyr::left_join(sp_reptiles_commune, 
                   by = c("INSEE_COM" = "codeInseeCommune")) %>% 
  mutate(amphibiens = recoder_manquantes_en_zero(amphibiens),
         insectes = recoder_manquantes_en_zero(insectes),
         chiropteres = recoder_manquantes_en_zero(chiropteres),
         mammiferes = recoder_manquantes_en_zero(mammiferes),
         mollusque = recoder_manquantes_en_zero(mollusque),
         oiseaux = recoder_manquantes_en_zero(oiseaux),
         reptiles = recoder_manquantes_en_zero(reptiles))

## Export de la couche commune ----

sf::write_sf(obj = sp_communes, dsn = "data/outputs/sp_openobs_communes_20230622.gpkg")



