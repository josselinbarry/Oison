especes %>%
#  pull(nomVernaculaire) %>%
  mutate(nom2=str_replace(nomVernaculaire, " \\s*\\([^\\)]+\\)", "")) %>%
  select(nomVernaculaire, nom2) %>%
  View()

lire_renommer_openobs <- function(fichier)
{
  table_especes <- data.table::fread(
    file = fichier,
    encoding = "UTF-8",
    colClasses = c(
      "codeInseeCommune" = "character",
      "codeInseeDepartement" = "character",
      "codeInseeRegion" = "character",
      "codeInseeEPCI" = "character",
      "idCampanuleProtocole" = "character",
      "sensiDateAttribution" = "character"
    )
  )
  names(table_especes)[87] <-  "typeRegroupement2"
  
  return(table_especes)
}

names(amphibiens)


chiropteres2<- data.table::fread(file = "data/temp/liste_bocage_chiropteres.csv",
                                 encoding = "UTF-8",
                                 colClasses = c("codeInseeCommune" = "character",
                                                "codeInseeDepartement" = "character",
                                                "codeInseeRegion" = "character",
                                                "codeInseeEPCI" = "character", 
                                                "idCampanuleProtocole" = "character")) 

names(especes_geom)[87] <-  "typeRegroupement20"

chiropteres2 %>% 
  select(starts_with("typeR")) %>% 
  
  
  names()
