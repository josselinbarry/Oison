## VERSION FINALISEE AU 20230919
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

## Importer les données OISON et communes au 20230606 ----

load(file = "outputs/oison_openobs.RData")

zones_tension_agri <- 
  sf::read_sf(dsn = "data/analyse_otex.gpkg")

zones_tension_urba <- 
  sf::read_sf(dsn = "data/analyse_urbanisation.gpkg")

## Fusion des ZT agri et urbaines ----

zones_tension_agri <- zones_tension_agri %>%
  select(id) %>%
  mutate(type_pression = 'agricole')

zones_tension_urba <- zones_tension_urba %>%
  select(id) %>%
  mutate(type_pression = 'urbanisation')

zt_agri_urba <- 
  dplyr::bind_rows(zones_tension_agri, zones_tension_urba) %>%
  mutate(cd_zone = paste(type_pression, id))

## Jointure du code ZT aux observations et filtre des celles en ZT ----

especes_geom_cd_zt <- especes_geom %>%
  st_join(zt_agri_urba, 
          largest = T) %>% 
  distinct()

especes_geom_cd_zt <- especes_geom_cd_zt %>%
  filter(!is.na(id)) %>%
  mutate(cd_zone = paste(type_pression, id))

save(especes_geom_cd_zt,
     file = "outputs/especes_geom_cd_zt.RData")

## Création pour chaque groupe d'une liste d'espèce par id ZT

sp_amphibiens_zt <- especes_geom_cd_zt %>%
  filter(classe == 'Amphibia') %>%
  group_by(cd_zone) %>%
  summarise(amphibiens = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_insectes_zt <- especes_geom_cd_zt %>%
  filter(classe == 'Insecta') %>%
  group_by(cd_zone) %>%
  summarise(insectes = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_chiropteres_zt <- especes_geom_cd_zt %>%
  filter(ordre == 'Chiroptera') %>%
  group_by(cd_zone) %>%
  summarise(chiropteres = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_mammiferes_zt <- especes_geom_cd_zt %>%
  filter(classe == 'Mammalia' & ordre != 'Chiroptera') %>%
  group_by(cd_zone) %>%
  summarise(mammiferes = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_mollusque_zt <- especes_geom_cd_zt %>%
  filter(classe == 'Gastropoda') %>%
  group_by(cd_zone) %>%
  summarise(mollusque = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_oiseaux_zt <- especes_geom_cd_zt %>%
  filter(classe == 'Aves') %>%
  group_by(cd_zone) %>%
  summarise(oiseaux = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

sp_reptiles_zt <- especes_geom_cd_zt %>%
  filter(ordre == 'Squamata') %>%
  group_by(cd_zone) %>%
  summarise(reptiles = paste(unique(nomVernaculaire), collapse = ', ')) %>% 
  sf::st_drop_geometry()

## Jointure à la couche des zones en tension ----

sp_zones_tension <- zt_agri_urba %>% 
  dplyr::left_join(sp_amphibiens_zt, 
                   by = c("cd_zone" = "cd_zone")) %>%
  dplyr::left_join(sp_insectes_zt, 
                   by = c("cd_zone" = "cd_zone")) %>% 
  dplyr::left_join(sp_chiropteres_zt, 
                   by = c("cd_zone" = "cd_zone")) %>% 
  dplyr::left_join(sp_mammiferes_zt, 
                   by = c("cd_zone" = "cd_zone")) %>% 
  dplyr::left_join(sp_mollusque_zt, 
                   by = c("cd_zone" = "cd_zone")) %>% 
  dplyr::left_join(sp_oiseaux_zt, 
                   by = c("cd_zone" = "cd_zone")) %>% 
  dplyr::left_join(sp_reptiles_zt, 
                   by = c("cd_zone" = "cd_zone")) %>% 
  mutate(amphibiens = recoder_manquantes_en_zero(amphibiens),
         insectes = recoder_manquantes_en_zero(insectes),
         chiropteres = recoder_manquantes_en_zero(chiropteres),
         mammiferes = recoder_manquantes_en_zero(mammiferes),
         mollusque = recoder_manquantes_en_zero(mollusque),
         oiseaux = recoder_manquantes_en_zero(oiseaux),
         reptiles = recoder_manquantes_en_zero(reptiles))

## Export de la couche ----

sf::write_sf(obj = sp_zones_tension, dsn = "data/outputs/sp_openobs_zt_20230622.gpkg")

