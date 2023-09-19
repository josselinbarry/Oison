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

oison <- 
  sf::read_sf(dsn = "data/oison_table_taxons_2023-06-06.gpkg")


communes <- 
  sf::read_sf(dsn = "data/COMMUNE.shp")

## Ajout du code INSEE commune ----

cd_communes <-
  communes %>%
  select(INSEE_COM, INSEE_DEP)

oison_cd_communes <- oison %>%
  st_join(cd_communes, 
          largest = T) %>% 
  distinct()

## Filtrer les données concernées par la région et la liste bocage bretagne ----

oison_bzh <-
  oison_cd_communes %>%
  filter(!is.na(INSEE_COM)) 

oison_bzh_bocage <-
  oison_bzh %>%
  dplyr::filter(nom_scientifique %in% c(
    'Alytes obstetricans', 
    'Alytes obstetricans obstetricans', 
    'Anguis fragilis', 
    'Anthus pratensis', 
    'Arvicola sapidus', 
    'Arvicola sapidus tenebricus', 
    'Barbastella barbastellus', 
    'Bufo spinosus', 
    'Carduelis carduelis', 
    'Cerambyx cerdo', 
    'Cerambyx cerdo cerdo', 
    'Cettia cetti', 
    'Chloris chloris', 
    'Cisticola juncidis', 
    'Columba oenas', 
    'Coronella austriaca', 
    'Coronella austriaca austriaca', 
    'Dendrocopos major', 
    'Dendrocopos medius', 
    'Dendrocopos minor', 
    'Dryocopus martius', 
    'Elona quimperiana', 
    'Emberiza citrinella', 
    'Epidalea calamita', 
    'Eptesicus serotinus', 
    'Erinaceus europaeus', 
    'Hierophis viridiflavus', 
    'Hyla arborea', 
    'Hyla arborea arborea', 
    'Ichthyosaura alpestris', 
    'Ichthyosaura alpestris alpestris', 
    'Lacerta bilineata', 
    'Lacerta bilineata bilineata', 
    'Linaria cannabina', 
    'Lissotriton helveticus', 
    'Lissotriton helveticus helveticus', 
    'Lissotriton vulgaris', 
    'Lissotriton vulgaris vulgaris', 
    'Lucanus cervus', 
    'Lucanus cervus cervus', 
    'Lullula arborea', 
    'Lutra lutra', 
    'Muscardinus avellanarius', 
    'Muscicapa striata', 
    'Myotis alcathoe', 
    'Myotis bechsteinii', 
    'Myotis brandtii', 
    'Myotis daubentonii', 
    'Myotis emarginatus', 
    'Myotis myotis', 
    'Myotis mystacinus', 
    'Myotis nattereri', 
    'Natrix helvetica', 
    'Natrix helvetica helvetica', 
    'Natrix maura', 
    'Nyctalus leisleri', 
    'Nyctalus leisleri leisleri', 
    'Nyctalus noctula', 
    'Osmoderma eremita', 
    'Pelodytes punctatus', 
    'Pelophylax kl. esculentus', 
    'Pelophylax lessonae', 
    'Pelophylax lessonae lessonae', 
    'Pelophylax ridibundus', 
    'Phylloscopus collybita', 
    'Phylloscopus collybita abietinus', 
    'Phylloscopus collybita collyba', 
    'Phylloscopus collybita tristis', 
    'Phylloscopus trochilus', 
    'Phylloscopus trochilus acredula', 
    'Phylloscopus trochilus trochilus', 
    'Picus viridis', 
    'Picus viridis viridis', 
    'Pipistrellus kuhlii', 
    'Pipistrellus nathusii', 
    'Pipistrellus pipistrellus', 
    'Pipistrellus pygmaeus',
    'Plecotus auritus', 
    'Plecotus auritus auritus', 
    'Plecotus austriacus', 
    'Podarcis muralis', 
    'Poecile palustris', 
    'Pyrrhula pyrrhula', 
    'Pyrrhula pyrrhula europaea', 
    'Pyrrhula pyrrhula pyrrhula', 
    'Rana dalmatina', 
    'Rana temporaria', 
    'Rana temporaria temporaria', 
    'Rhinolophus ferrumequinum', 
    'Rhinolophus ferrumequinum ferrumequinum', 
    'Rhinolophus hipposideros', 
    'Rosalia alpina', 
    'Salamandra salamandra', 
    'Salamandra salamandra terrestris', 
    'Saxicola rubicola', 
    'Sciurus vulgaris', 
    'Serinus serinus', 
    'Streptopelia turtur', 
    'Sylvia borin', 
    'Sylvia undata dartfordiensis', 
    'Triturus cristatus', 
    'Triturus marmoratus', 
    'Vipera berus', 
    'Vipera berus berus', 
    'Zamenis longissimus', 
    'Zootoca vivipara', 
    'Zootoca vivipara vivipara'
    )) 

## Analyse des données OISON-BOCAGE ----

### Préparation des données par groupby ----

oison_bzh_data <-
  oison_bzh %>%
  sf::st_drop_geometry() %>% 
  select(observation_id, INSEE_DEP, groupe2_inpn, type_recherche) %>%
  as.data.frame() %>%
  group_by(
    INSEE_DEP,
    groupe2_inpn) %>%
  summarise(nb_tot_obs = n())

oison_bzh_bocage_data <-
  oison_bzh_bocage %>%
  sf::st_drop_geometry() %>% 
  select(observation_id, INSEE_DEP, groupe2_inpn, type_recherche, nom) %>%
  as.data.frame() %>%
  group_by(
    INSEE_DEP,
    groupe2_inpn,
    type_recherche, 
    nom) %>%
  summarise(nb_tot_obs = n())

oison_bzh_bocage_nom <-
  oison_bzh_bocage %>%
  sf::st_drop_geometry() %>% 
  select(observation_id, nom, groupe2_inpn, type_recherche) %>%
  as.data.frame() %>%
  group_by(
    nom,
    groupe2_inpn) %>%
  summarise(nb_tot_obs = n())

### Informations de base

stat_oison <- 
  oison_bzh %>%
  sf::st_drop_geometry() %>% 
  group_by(INSEE_DEP)%>%
  summarise(nb_tot_obs = n()) %>%
  mutate(prct_obs = round(nb_tot_obs*100/sum(nb_tot_obs), 2),
         obs_tot_reg = sum(oison_bzh_data$nb_tot_obs)) 




### Répartition des observations par département, en fonction du groupe INPN ----

histo_obs_dept_grpe <- 
  ggplot(data = oison_bzh_data, 
         aes(x = INSEE_DEP, y = nb_tot_obs)) +
  geom_col(aes(fill = groupe2_inpn), width = 0.7) + 
  scale_fill_manual(values = c("#d9d9d9", "#18d0f0", "#2374ee", "black", "grey", "yellow","#d01c02", "#d1d0d8", "#fb01ff", "cyan", "green", "blue", "#fb99ff"))+
  labs(
    x = "Code départemental",
    y = "Nombre d'observations",
    title = str_wrap("Nombre d'observations par département selon le 'Groupe INPN'", width=50))


histo_obs_dept_grpe

histo_obs_bocage_dept_grpe <- 
  ggplot(data = oison_bzh_bocage_data, 
         aes(x = INSEE_DEP, y = nb_tot_obs)) +
  geom_col(aes(fill = groupe2_inpn), width = 0.7) + 
  scale_fill_manual(values = c("green", "#b1b1b1", "#2374ee", "#d01c02", "yellow","cyan"))+
  labs(
    x = "Code départemental",
    y = "Nombre d'observations",
    title = str_wrap("Nombre d'observations par département selon le 'Groupe INPN'
                     (Entre le 2 Mai 2005 et le 6 Juin 2023)", width=50))

histo_obs_bocage_dept_grpe

### Répartition des observations par département, en fonction du type de recherche ----

histo_obs_bocage_dept_type_recherche <- 
  ggplot(data = oison_bzh_bocage_data, 
         aes(x = INSEE_DEP, y = nb_tot_obs)) +
  geom_col(aes(fill = type_recherche), width = 0.7) + 
  scale_fill_manual(values = c("green", "#b1b1b1", "#2374ee", "#d01c02", "yellow","cyan"))+
  labs(
    x = "Code départemental",
    y = "Nombre d'observations",
    title = str_wrap("Nombre d'observations par département selon le 'Type de recherche'
                     (Entre le 2 Mai 2005 et le 6 Juin 2023)", width=50))

histo_obs_bocage_dept_type_recherche

### Répartition des observations par agent ----

histo_obs_bocage_nom <-
  ggplot(data = oison_bzh_bocage_nom %>%
           filter(nb_tot_obs > 5), 
         aes(x = nom, y = sum(nb_tot_obs))) +
  ylim(0, 5) +
  labs(x = "Nom de l'agent",
       y = "Nombre d'observations",
       title = str_wrap("Nombre d'observations par agent", width=40))

histo_obs_bocage_nom

### Répartition des observations dans le temps ----

histo_obs_date <-
  ggplot(data = oison_bzh, 
       aes(x = lubridate::ymd(date))) +
  geom_histogram(fill = "blue") +
  labs(x = "Date de l'observation",
       y = "Nombre d'observations",
       title = str_wrap("Dynamique de renseignement des observations dans OISON", width=50))   

histo_obs_date

histo_obs_bocage_date <-
  ggplot(data = oison_bzh_bocage, 
         aes(x = lubridate::ymd(date))) +
  geom_histogram(fill = "blue") +
  labs(x = "Date de l'observation",
       y = "Nombre d'observations",
       title = str_wrap("Dynamique de renseignement des observations 'Bocage' dans OISON", width=50))   

histo_obs_bocage_date

# Sauvegarde

save(oison_bzh_data,
     oison_bzh_bocage_data,
     stat_oison,
     histo_obs_dept_grpe,
     histo_obs_bocage_dept_grpe,
     histo_obs_bocage_dept_type_recherche,
     histo_obs_bocage_nom,
     histo_obs_date,
     histo_obs_bocage_date,
     file = "outputs/histo_oison_openobs.RData")

