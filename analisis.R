library(dplyr)
library(tidyr)
library(forcats)
library(ggplot2)
library(lubridate)
library(ggcr)
library(ggrepel)
library(foreign)
library(plotly)

base <- read.spss("datos/base-descriptivo.sav")
base <- as.data.frame(base)

#mezclo: si mezclo mas de una sustancia o no 
#causarec: hace regerencia a la causa de la intoxicacion como tentativa suicida, accidental,ocupacional, mal uso(por ejemplo cuando no usan la debida proteccion en ropa o lentes)
#rutarec: el medio por el que se dio la intoxicacion, ingestion, inhalacion, etc

#dejar solo variables de interés
base <- base[,c(1:4, 6, 7, 14, 19, 20)]
colnames(base) <- c("ID", "anio", "provinciarec", "cantonrec", "grupo_edad", "sexo", "mezclo", "causarec", "rutarec")

base_temp <- base
#Pasa a otra variable el canton ya que esta codificada como factores
base_temp <- base_temp %>% 
  mutate(Canton = as.character(cantonrec))
base_temp <- base_temp %>% 
  select(-cantonrec)
#Modifica el nombre de algunos cantones para poder unirlo con las otras bases del paquete ggcr(este da el mapa de Costa Rica para poder graficarlo)

base_temp <- base_temp %>% 
  mutate(Canton = ifelse(Canton == "León Cortés Castro", "Leon Cortes",
                         ifelse(Canton == "Vázquez de Coronado", "Vazquez De Coronado",
                                ifelse(Canton == "Montes de Oro", "Montes De Oro",
                                       ifelse(Canton == "Montes de Oca","Montes De Oca",
                                              Canton)))))

#quitar tildes en variable provincia
base_temp <- base_temp %>% mutate(Provincia = chartr('áéíóúñ', 'aeioun', provinciarec))
base_temp <- base_temp %>% select(-provinciarec)
#quitar tildes en variable canton
base_temp <- base_temp %>% mutate(Canton = chartr('áéíóúñ', 'aeioun', Canton))
base_temp <- base_temp %>% filter(!(Canton == "99" | Canton == "Extranjero"))

#agregar la poblacion segun el censo 2011 por canton
#leer datos del censo
censo <- read.csv("datos/censo_inec_2011.csv", stringsAsFactors = F, encoding = "UTF-8")

#selecciona las variables provincia, canton, distritos y poblacion
censo <- censo %>% select(Provincia, Canton, Distrito, Poblacion_Total)
#quitar tildes en variable provincia
censo <- censo %>% mutate(Provincia = chartr('áéíóúñ', 'aeioun', Provincia))
#quitar tildes en variable canton
censo <- censo %>% mutate(Canton = chartr('áéíóúñ', 'aeioun', Canton))

#Cambia algunos nombres para luego unir con otras bases del paquete ggcr
censo2 <- censo %>% mutate(Canton = ifelse(Canton == "Ca~nas", "Canas",
                                           ifelse(Canton == "Leon Cort'es Castro","Leon Cortes",
                                                  ifelse(Canton == "Perez Zeled'on", "Perez Zeledon",
                                                         ifelse(Canton == "Vazquez de Coronado", "Vazquez De Coronado",
                                                                ifelse(Canton == "Montes de Oro", "Montes De Oro",
                                                                       ifelse(Canton == "Montes de Oca", "Montes De Oca",
                                                                              Canton)))))))


#poblacion por canton
censo2 <- censo2 %>% 
  group_by(Provincia, Canton) %>%
  mutate(poblacion = sum(Poblacion_Total))
#selecciona variables de interes y elimina duplicados
censo2 <- censo2 %>% 
  select(Provincia, Canton, poblacion) %>% 
  distinct(Provincia, Canton, .keep_all=T)
#ordena por provincia y canton
censo2 <- censo2 %>% arrange(Provincia, Canton)


#unir casos con censo
base2 <- merge(base_temp, censo2, by = c("Provincia", "Canton"), all.x = F)
base2 <- base2 %>% 
  mutate(Canton = ifelse(Canton == "Canas", "Cañas", Canton))

base_temp <- base2

#cantidad de intoxicaciones por canton
base_temp <- base_temp %>% 
  group_by(Canton) %>%
  mutate(intoxicaciones = n())

#selecciona variables de interes y elimina duplicados
base_temp <- base_temp %>% 
  select(Provincia, Canton, intoxicaciones, poblacion) %>% 
  distinct(Canton, .keep_all = T)

#calcula la cantidad por cada diezmil habitantes
base_temp <- base_temp %>% 
  mutate(llamadas_10mil = round((intoxicaciones / poblacion) * 10000, 0))


# Cambiar shapefile para eliminar Isla del Coco

s <- shapefile("CRI_adm/CRI_adm2.shp")

sub <- crop(s, extent(-88, -82, 7, 12))
plot(sub, axes = T, border = 'gray')

shapefile(sub, 'datos/cantones.shp')

### Load a shape file and merge it with a csv
### Author: Jose Gonzalez 
### www.jose-gonzalez.org

# This script shows how to load a shapefile, merge it with a csv and save it with the proper
# encoding

### Load rgdal

require(rgdal)

# Load shapefile using "UTF-8". Notice the "." is the directory and the shapefile name 
# has no extention
shp  <- readOGR("datos", "cantones", stringsAsFactors=FALSE, encoding="UTF-8")
# Explore with a quick plot
plot(shp, axes=TRUE, border="gray")

# Cambio de nombres de los cantones

shp$NAME_2[shp$NAME_2 %in% setdiff(unique(shp$NAME_2), unique(base_temp$Canton))] <- c("Zarcero", "Poas", "San Ramon", "Jimenez", "La Union", "Paraiso",
                                                                                       "Cañas", "Tilaran", "Belen", "Santa Barbara", "Sarapiqui", "Guacimo",
                                                                                       "Limon", "Pococi", "Montes De Oro", "Aserri", "Escazu", "Leon Cortes",
                                                                                       "Montes De Oca", "Perez Zeledon", "San Jose", "Tarrazu", "Tibas",
                                                                                       "Vazquez De Coronado")

# Verifiquemos que se cambió
setdiff(unique(shp$NAME_2), unique(base_temp$Canton))

# Merge shapefile and csv
temp  <- merge(shp, base_temp, by.x="NAME_2", by.y="Canton") 

# The shapefile behaves as a data.frame. Explore a bit
head(temp)

#
spplot(temp, "intoxicaciones")

library(spdep)

#
coords <- coordinates(temp)
IDs <- row.names(temp)

# Reina
temp1_nb <- poly2nb(temp)
plot(shp, axes=TRUE, border="gray")
plot(temp1_nb, coordinates(temp), pch = 19, cex = 0.6, add = T)

# Torre
temp2_nb <- poly2nb(temp, queen = F)
plot(shp, axes=TRUE, border="gray")
plot(temp2_nb, coordinates(temp), pch = 19, cex = 0.6, add = T)

# kNN con 1 vecino
temp8_nb <- knn2nb(knearneigh(coords, k=1), row.names=IDs)
plot(shp, axes=TRUE, border="gray")
plot(temp8_nb, coordinates(temp), pch=19, cex=0.6, add = T)

# kNN con 2 vecinos
temp9_nb <- knn2nb(knearneigh(coords, k=2), row.names=IDs)
plot(shp, axes=TRUE, border="gray")
plot(temp9_nb, coordinates(temp), pch=19, cex=0.6, add = T)

# kNN con 4 vecinos
temp10_nb <- knn2nb(knearneigh(coords, k=4), row.names=IDs)
plot(shp, axes=TRUE, border="gray")
plot(temp10_nb, coordinates(temp), pch=19, cex=0.6, add = T)

dsts <- unlist(nbdists(temp8_nb, coords))
temp11_nb <- dnearneigh(coords, d1=0, d2=0.75*max(dsts), row.names=IDs)
plot(shp, axes=TRUE, border="gray")
plot(temp11_nb, coordinates(temp), pch=19, cex=0.6, add = T)
