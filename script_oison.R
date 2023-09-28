# VERSION FINALISEE AU 20230919
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
source(file = "R/lire_renommer_openobs.R")

## Import données espèces ONPENOBS et communes au 20230622 ----

fichiers_a_importer <- list.files(path = "data", 
                                  pattern = ".csv$", 
                                  full.names = T)

liste_especes <- map_df(.x = fichiers_a_importer, 
                          .f = lire_renommer_openobs)

#d'ici ----

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
#A là ----

communes <- 
  sf::read_sf(dsn = "data/COMMUNE.shp")

mailles_5km <- 
  sf::read_sf(dsn = "data/maille_bzh_5km.shp")

## Création d'une couche géographique especes en L93 ----

especes <- dplyr::bind_rows(amphibiens, insectes, chiropteres, mammiferes, mollusque, oiseaux, reptiles) 

#A là bis ----

especes_geom <- especes %>% 
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), remove = FALSE, crs = 4326) %>%
  st_transform(especes_geom, crs = 2154) %>%
  mutate(nomVernaculaire=str_replace(nomVernaculaire, " \\s*\\([^\\)]+\\)", ""))

names(especes_geom)[87] <-  "typeRegroupement2"

sf::write_sf(obj = especes_geom, dsn = "data/outputs/sp_openobs_20230913.gpkg")

## Ajout du code INSEE de la commune la plus proche de l'observation (hors pas de XY) pour les codeINSEE non renseignés

cd_manquant_especes <- especes_geom %>%
  select(idSINPOccTax, codeInseeCommune, precisionLocalisation) %>%
  filter((codeInseeCommune == '' | is.na(codeInseeCommune)) &
              precisionLocalisation %in% c('XY centroïde commune','XY centroïde ligne/polygone','XY point',  'XY centroïde maille' ))

plus_proche_commune <- sf::st_nearest_feature(x = cd_manquant_especes,
                                           y = communes)

view(plus_proche_commune)

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

# Très long (env. 2h)
especes_geom <- especes_geom  %>%
  left_join(cd_insee_especes, by = c("idSINPOccTax" = "idSINPOccTax")) %>%  
  mutate(codeInseeCommune = ifelse(
    codeInseeCommune == '',
    com_la_plus_proche,
    codeInseeCommune)) %>%
  distinct() %>%
  select(-com_la_plus_proche, -distance_km)

nb_esp_geom_sans_INSEE <- especes_geom %>%
  filter(codeInseeCommune == '')

## Jointure du code maille aux observations ----

cd_mailles <-
  mailles_5km %>%
  mutate(CD_join = CD_SIG)

# Très long (env. 2h)
especes_geom_cd_mailles <- especes_geom %>%
  st_join(cd_mailles, 
          largest = T) %>% 
  distinct()

especes_geom_cd_mailles <- especes_geom_cd %>%
  select(- distance_maille_km)

## Ajout du code de la maille la plus proche de l'observation (hors pas de XY) pour les codes mailles non-renseignés ----

cd_maille_manquant_especes <- especes_geom_cd_mailles %>%
  select(idSINPOccTax, CD_join, precisionLocalisation) %>%
  filter((CD_join == '' | is.na(CD_join)) &
           precisionLocalisation %in% c('XY centroïde commune','XY centroïde ligne/polygone','XY point',  'XY centroïde maille' ))

plus_proche_maille <- sf::st_nearest_feature(x = cd_maille_manquant_especes,
                                             y = mailles_5km)

dist_maille <- st_distance(cd_maille_manquant_especes, mailles_5km[plus_proche_maille,], by_element = TRUE)

view(plus_proche_maille)

cd_maille_especes <- cd_maille_manquant_especes %>% 
  cbind(dist_maille) %>% 
  cbind(mailles_5km[plus_proche_maille,]) %>% 
  select(idSINPOccTax,
         maille_la_plus_proche = CD_SIG,
         distance_maille_km = dist_maille) %>% 
  sf::st_drop_geometry() %>% 
  mutate(distance_maille_km = round(distance_maille_km/1000,3))

## Mise à jour du code maille de la couche especes_geom

#Très long
especes_geom_cd <- especes_geom_cd_mailles  %>%
  left_join(cd_maille_especes, by = c("idSINPOccTax" = "idSINPOccTax")) %>%  
  mutate(CD_SIG = ifelse(
    (CD_SIG == '' | is.na(CD_SIG)),
    maille_la_plus_proche,
    CD_SIG)) %>%
  distinct() %>%
  select(-maille_la_plus_proche, -CD_join)

nb_esp_geom_sans_code_maille <- especes_geom_cd %>%
  filter(CD_SIG == '')

# Fusion des observations INPN et OISON ----

## Preparation couche INPN ----

obs_inpn_cd_insee <- especes_geom_cd %>%
  filter(libelleCadreAcquisition != c( 'Rapportage 2001-2006 au titre de la directive Habitats-Faune-Flore' ,  
                                       'Rapportage 2007-2012 au titre de la directive Habitats-Faune-Flore' ,  
                                       'Rapportage 2013-2018 au titre de la directive Habitats-Faune-Flore' )) %>%
  mutate(nom_vernaculaire = nomVernaculaire,
         INSEE_COM = codeInseeCommune) %>%
  select(nom_vernaculaire, INSEE_COM, classe, ordre) %>%
  sf::st_drop_geometry()

## Fusion des couches ----

obs_totales_cd_insee <- 
  dplyr::bind_rows(obs_oison_cd_insee, obs_inpn_cd_insee)

## Creation de la table de synthèse ----

## Création pour chaque groupe d'une liste d'espèce par code INSEE_commune ----

sp_amphibiens_commune <- obs_totales_cd_insee %>%
  filter(classe == 'Amphibia') %>%
  group_by(INSEE_COM) %>%
  summarise(amphibiens = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_insectes_commune <- obs_totales_cd_insee %>%
  filter(classe == 'Insecta') %>%
  group_by(INSEE_COM) %>%
  summarise(insectes = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_chiropteres_commune <- obs_totales_cd_insee %>%
  filter(ordre == 'Chiroptera') %>%
  group_by(INSEE_COM) %>%
  summarise(chiropteres = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_mammiferes_commune <- obs_totales_cd_insee %>%
  filter(classe == 'Mammalia' & ordre != 'Chiroptera') %>%
  group_by(INSEE_COM) %>%
  summarise(mammiferes = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_mollusque_commune <- obs_totales_cd_insee %>%
  filter(classe == 'Gastropoda') %>%
  group_by(INSEE_COM) %>%
  summarise(mollusque = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_oiseaux_commune <- obs_totales_cd_insee %>%
  filter(classe == 'Aves') %>%
  group_by(INSEE_COM) %>%
  summarise(oiseaux = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_reptiles_commune <- obs_totales_cd_insee%>%
  filter(ordre == 'Squamata') %>%
  group_by(INSEE_COM) %>%
  summarise(reptiles = paste(unique(nom_vernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

## Jointure à la couche commune ----

sp_communes <- communes %>% 
  dplyr::left_join(sp_amphibiens_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>%
  dplyr::left_join(sp_insectes_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>% 
  dplyr::left_join(sp_chiropteres_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>% 
  dplyr::left_join(sp_mammiferes_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>% 
  dplyr::left_join(sp_mollusque_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>% 
  dplyr::left_join(sp_oiseaux_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>% 
  dplyr::left_join(sp_reptiles_commune, 
                   by = c("INSEE_COM" = "INSEE_COM")) %>% 
  mutate(amphibiens = recoder_manquantes_en_zero(amphibiens),
         insectes = recoder_manquantes_en_zero(insectes),
         chiropteres = recoder_manquantes_en_zero(chiropteres),
         mammiferes = recoder_manquantes_en_zero(mammiferes),
         mollusque = recoder_manquantes_en_zero(mollusque),
         oiseaux = recoder_manquantes_en_zero(oiseaux),
         reptiles = recoder_manquantes_en_zero(reptiles))

## Création pour chaque groupe d'une liste d'espèce par code maille ----

sp_amphibiens_maille <- especes_geom_cd %>%
  filter(classe == 'Amphibia') %>%
  group_by(CD_SIG) %>%
  summarise(amphibiens = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_insectes_maille <- especes_geom_cd %>%
  filter(classe == 'Insecta') %>%
  group_by(CD_SIG) %>%
  summarise(insectes = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_chiropteres_maille <- especes_geom_cd %>%
  filter(ordre == 'Chiroptera') %>%
  group_by(CD_SIG) %>%
  summarise(chiropteres = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_mammiferes_maille <- especes_geom_cd %>%
  filter(classe == 'Mammalia' & ordre != 'Chiroptera') %>%
  group_by(CD_SIG) %>%
  summarise(mammiferes = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_mollusque_maille <- especes_geom_cd %>%
  filter(classe == 'Gastropoda') %>%
  group_by(CD_SIG) %>%
  summarise(mollusque = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_oiseaux_maille <- especes_geom_cd %>%
  filter(classe == 'Aves') %>%
  group_by(CD_SIG) %>%
  summarise(oiseaux = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_reptiles_maille <- especes_geom_cd %>%
  filter(ordre == 'Squamata') %>%
  group_by(CD_SIG) %>%
  summarise(reptiles = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

## Ajout du nombre d'observations par maille ----

intersections <- 
  st_intersects(mailles_5km, especes_geom_cd, sparse = TRUE)

mailles_5km$nb_observations <- sapply(X = intersections, FUN = length)

## Jointure à la couche maille ----

sp_mailles <- mailles_5km %>% 
  dplyr::left_join(sp_amphibiens_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>%
  dplyr::left_join(sp_insectes_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>% 
  dplyr::left_join(sp_chiropteres_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>% 
  dplyr::left_join(sp_mammiferes_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>% 
  dplyr::left_join(sp_mollusque_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>% 
  dplyr::left_join(sp_oiseaux_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>% 
  dplyr::left_join(sp_reptiles_maille, 
                   by = c("CD_SIG" = "CD_SIG")) %>% 
  mutate(amphibiens = recoder_manquantes_en_zero(amphibiens),
         insectes = recoder_manquantes_en_zero(insectes),
         chiropteres = recoder_manquantes_en_zero(chiropteres),
         mammiferes = recoder_manquantes_en_zero(mammiferes),
         mollusque = recoder_manquantes_en_zero(mollusque),
         oiseaux = recoder_manquantes_en_zero(oiseaux),
         reptiles = recoder_manquantes_en_zero(reptiles))

## Export des couches commune et maille ----

sf::write_sf(obj = mailles_5km, dsn = "data/outputs/test__occurences_maille_20230622.gpkg")

sf::write_sf(obj = sp_communes, dsn = "data/outputs/sp_openobs_communes_20230928.gpkg")

sf::write_sf(obj = sp_mailles, dsn = "data/outputs/sp_openobs_mailles_5km_20230622.gpkg")

# Sauvegarde des résultats

save(especes_geom,
     especes_geom_cd,
     sp_mailles,
     sp_communes,
     file = "outputs/oison_openobs.RData")

# chargement des résultats

load(file = "outputs/oison_openobs.RData")
