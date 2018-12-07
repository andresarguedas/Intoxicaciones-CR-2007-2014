###############################################################################
############################## Limpieza de datos ##############################
###############################################################################

# Cargamos los paquetes necesarios para poder hacer la limpieza de los datos

library(foreign)
library(dplyr)
library(readxl)
library(raster)
library(rgdal)

base <- read.spss("datos/crudos/base-descriptivo.sav")
base <- as.data.frame(base)

#mezclo: si mezclo mas de una sustancia o no 
#causarec: hace regerencia a la causa de la intoxicacion como tentativa suicida, accidental,ocupacional, mal uso(por ejemplo cuando no usan la debida proteccion en ropa o lentes)
#rutarec: el medio por el que se dio la intoxicacion, ingestion, inhalacion, etc

#dejar solo variables de interes
base <- base[,c(1:4, 6, 7, 14, 19, 20)]
colnames(base) <- c("ID", "anio", "provinciarec", "cantonrec", "grupo_edad", "sexo", "mezclo", "causarec", "rutarec")

#Pasa a otra variable el canton ya que esta codificada como factores
base_temp <- base %>% mutate(Canton = as.character(cantonrec))
base_temp <- base_temp %>% dplyr::select(-cantonrec)
base_temp <- base_temp %>% mutate(Canton = ifelse(Canton == "León Cortés Castro", "Leon Cortes",
                                                  ifelse(Canton == "Vázquez de Coronado", "Vazquez De Coronado",
                                                         ifelse(Canton == "Montes de Oro", "Montes De Oro",
                                                                ifelse(Canton == "Montes de Oca","Montes De Oca",
                                                                       Canton)))))


#quitar tildes en variable provincia
base_temp <- base_temp %>% mutate(Provincia = chartr('áéíóúñ', 'aeioun', provinciarec))
base_temp <- base_temp %>% dplyr::select(-provinciarec)
#quitar tildes en variable canton
base_temp <- base_temp %>% mutate(Canton = chartr('áéíóúñ', 'aeioun', Canton))
base_temp <- base_temp %>% filter(!(Canton == "99" | Canton == "Extranjero"))

#agregar la poblacion segun el censo 2011 por canton
#leer datos del censo
censo <- read.csv("datos/crudos/censo_inec_2011.csv", stringsAsFactors = F, encoding = "UTF-8")

#selecciona las variables provincia, canton, distritos y poblacion
censo <- censo %>% dplyr::select(Provincia, Canton, Distrito, Poblacion_Total)
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
  dplyr::select(Provincia, Canton, poblacion) %>% 
  distinct(Provincia, Canton, .keep_all=T)
#ordena por provincia y canton
censo2 <- censo2 %>% arrange(Provincia, Canton)

#unir casos con censo
base2 <- merge(base_temp, censo2, by = c("Provincia", "Canton"), all.x = F)
base2 <- base2 %>% mutate(Canton = ifelse(Canton == "Canas", "Cañas", Canton))

#cantidad de intoxicaciones por canton
base_temp <- base2 %>% 
  group_by(Canton) %>%
  mutate(intoxicaciones = n())

#selecciona variables de interes y elimina duplicados
base_temp <- base_temp %>% 
  dplyr::select(Provincia, Canton, intoxicaciones, poblacion) %>% 
  distinct(Canton, .keep_all = T)

#calcula la cantidad por cada diezmil habitantes
base_temp <- base_temp %>% mutate(llamadas_10mil = round((intoxicaciones / poblacion) * 10000, 4))

# Cargamos los indices cantonales del 2011
ind_cantonales <- read_excel("datos/crudos/ind_cantonales.xlsx")
ind_cantonales <- ind_cantonales %>% mutate(Canton = chartr('áéíóú', 'aeiou', Nombre)) %>% 
  dplyr::select(-Nombre, -`Población total`)
ind_cantonales$Canton[c(11, 15, 20, 68)] <- c("Vazquez De Coronado", "Montes De Oca", "Leon Cortes", "Montes De Oro")
names(ind_cantonales) <- c("cod_dist", "victima", "superficie", "densidad_pob",
                           "por_pob_urb", "rel_homb_muj", "rel_depe_demo",
                           "viv_ocup", "promedio_ocup_viv", "por_viv_buen",
                           "por_viv_hacin", "por_alfab", "alf_10_24", "alf_25",
                           "prom_escol", "esc_25_49", "esc_50", "por_edu_reg",
                           "asis_menor5", "asis_5_17", "asis_18_24", "asis_25",
                           "fuera_trab", "tasa_partic", "hombres", "mujeres",
                           "por_ocup_aseg", "por_pob_ext", "por_pob_discp",
                           "por_pob_no_aseg", "por_hog_fem", "por_hog_comp",
                           "fincas_agro", "extension_agro", "Canton")

ind_cantonales <- ind_cantonales %>% 
  mutate(por_agro = extension_agro * 0.01 / superficie * 100)

data <- inner_join(base_temp, ind_cantonales, by = "Canton")

# Guardamos los datos como un archivo .csv

write.csv2(data, "datos/procesados/indicadores.csv", row.names = FALSE)

# Cambiar shapefile para eliminar Isla del Coco
s <- shapefile("datos/crudos/CRI_adm2.shp")
sub <- crop(s, extent(-88, -82, 7, 12))
#plot(sub, axes = T, border = 'gray')
shapefile(sub, 'datos/procesados/cantones.shp', overwrite=TRUE)

### Load a shape file and merge it with a csv
### Author: Jose Gonzalez 
### www.jose-gonzalez.org

# This script shows how to load a shapefile, merge it with a csv and save it with the proper encoding
### Load rgdal
#require(rgdal)
# Load shapefile using "UTF-8". Notice the "." is the directory and the shapefile name 
# has no extention
shp  <- readOGR("datos/procesados", "cantones", stringsAsFactors=FALSE, encoding="UTF-8")
# Explore with a quick plot
#plot(shp, axes=TRUE, border="gray")

# Cambio de nombres de los cantones
shp$NAME_2[shp$NAME_2 %in% setdiff(unique(shp$NAME_2), unique(data$Canton))] <- c("Zarcero", "Poas", "San Ramon", "Jimenez", "La Union", "Paraiso", "Tilaran", "Belen", "Santa Barbara", "Sarapiqui", "Guacimo", "Limon", "Pococi", "Montes De Oro", "Aserri", "Escazu", "Leon Cortes","Montes De Oca", "Perez Zeledon", "San Jose", "Tarrazu", "Tibas","Vazquez De Coronado")

# Verifiquemos que se cambi?
#setdiff(unique(shp$NAME_2), unique(base_temp$Canton))

# Merge shapefile and csv
temp  <- merge(shp, data, by.x="NAME_2", by.y="Canton") 

# De nuevo, guardamos el shape file con los datos para poder usarlo
shapefile(temp, 'datos/procesados/cantones_data.shp', overwrite=TRUE)

