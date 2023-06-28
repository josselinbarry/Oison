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

## Création d'une couche géographique especes en L93 ----

especes <- dplyr::bind_rows(amphibiens, insectes, chiropteres, mammiferes, mollusque, oiseaux, reptiles) 

especes_geom <- especes %>% 
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), remove = FALSE, crs = 4326) %>%
  st_transform(especes_geom, crs = 2154)

## Ajout du code INSEE de la commune la plus proche de l'observation (hors pas de XY) pour les codeINSEE non renseignés

cd_manquant_especes <- especes_geom %>%
  select(idSINPOccTax, codeInseeCommune, precisionLocalisation) %>%
  filter((codeInseeCommune == '' | is.na(codeInseeCommune)) &
              precisionLocalisation %in% c('XY centroïde commune','XY centroïde ligne/polygone','XY point',  'XY centroïde maille' ))

plus_proche_commune <- sf::st_nearest_feature(x = cd_manquant_especes,
                                           y = communes)

dist <- st_distance(cd_manquant_especes, communes[plus_proche_commune,], by_element = TRUE)

cd_insee_especes <- cd_manquant_especes %>% 
  cbind(dist) %>% 
  cbind(communes[plus_proche_commune,]) %>% 
  select(idSINPOccTax,
         com_la_plus_proche = INSEE_COM,
         distance_km = dist) %>% 
  sf::st_drop_geometry() %>% 
  mutate(distance_km = round(distance_km/1000,3))

## Mise à jour du code INSEE commune de la couche especes_geom

especes_geom_cd2 <- especes_geom  %>%
  left_join(cd_insee_especes, by = c("idSINPOccTax" = "idSINPOccTax")) %>%  
  mutate(codeInseeCommune = ifelse(
    codeInseeCommune == '',
    com_la_plus_proche,
    codeInseeCommune)) %>%
  distinct() %>%
  select(-com_la_plus_proche, -distance_km)

nb_esp_geom_sans_INSEE <- especes_geom_cd %>%
  filter(codeInseeCommune == '')

## Création pour chaque groupe d'une liste d'espèce par code INSEE_commune ----

sp_amphibiens_commune <- especes_geom_cd %>%
  filter(classe == 'Amphibia') %>%
  group_by(codeInseeCommune) %>%
  summarise(amphibiens = paste(unique(nomVernaculaire), collapse = ', '))

sp_insectes_commune <- especes_geom_cd %>%
  filter(classe == 'Insecta') %>%
  group_by(codeInseeCommune) %>%
  summarise(insectes = paste(unique(nomVernaculaire), collapse = ', '))

sp_chiropteres_commune <- especes_geom_cd %>%
  filter(ordre == 'Chiroptera') %>%
  group_by(codeInseeCommune) %>%
  summarise(chiropteres = paste(unique(nomVernaculaire), collapse = ', '))

sp_mammiferes_commune <- especes_geom_cd %>%
  filter(classe == 'Mammalia' & ordre != 'Chiroptera') %>%
  group_by(codeInseeCommune) %>%
  summarise(mammiferes = paste(unique(nomVernaculaire), collapse = ', '))

sp_mollusque_commune <- especes_geom_cd %>%
  filter(classe == 'Gastropoda') %>%
  group_by(codeInseeCommune) %>%
  summarise(mollusque = paste(unique(nomVernaculaire), collapse = ', '))

sp_oiseaux_commune <- especes_geom_cd %>%
  filter(classe == 'Aves') %>%
  group_by(codeInseeCommune) %>%
  summarise(oiseaux = paste(unique(nomVernaculaire), collapse = ', '))

sp_reptiles_commune <- especes_geom_cd %>%
  filter(ordre == 'Squamata') %>%
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



