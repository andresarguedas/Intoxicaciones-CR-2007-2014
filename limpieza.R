###############################################################################
############################## Limpieza de datos ##############################
###############################################################################

# Cargamos los paquetes necesarios para poder hacer la limpieza de los datos

library(foreign)
library(dplyr)
library(readxl)
library(raster)
library(rgdal)

# Cargamos el conjunto de datos con todos los casos de intoxicaciones en el
# periodo de interes

base <- read.spss("datos/crudos/base-descriptivo.sav")
base <- as.data.frame(base)

# El conjunto de datos `base` contiene las siguientes variables:
# 
# • ID: identificador de la llama
# • Año: año en el cual se hizo la llamada
# • provinciarec: provincia en la cual se dio la intoxicacion
# • cantonrec: canton en el cual se dio la intoxicacion
# • zona: recodificacion de la zona en urbano, semiurbano, rural y extranjero
# • Grupo_edad: recodificacion de la edad de la persona en 0 a 11, 12 a 19,
#               20 a 64 y 64 y más, o desconocido
# • Sexo: sexo de la persona, puede ser hombre, mujer o no anotado
# • Toxico1 - Toxico6: nombre de las sustancias toxicas ingeridas
# • Mezclo: si la persona mezclo mas de una sustancia o no 
# • Agente1 - Toxico6: tipo de sustancias toxicas ingeridas
# • Causarec: hace referencia a la causa de la intoxicacion como tentativa 
#             suicida, accidental,ocupacional, mal uso (por ejemplo, cuando no 
#             se usa la debida proteccion en ropa o lentes)
# • Rutarec: el medio por el que se dio la intoxicacion: ingestion, inhalacion,
#            etc
#
# Aun así, solamente es de interés para los análisis tomar las variables del
# ID, año, provincia, canton, edad, sexo, si mezcló sustancias o no, la causa
# de la intoxación y la reuta por la que se dio la intoxicación. Por lo tanto,
# se procede a seleccionar estas variables en un nuevo conjunto de datos:

base <- base[, c(1:4, 6, 7, 14, 19, 20)]

# Cambiamos el nombre de las variables para que no contengan caracteres 
# especiales:

colnames(base) <- c("ID", "anio", "provinciarec", "cantonrec", "grupo_edad", "sexo", "mezclo", "causarec", "rutarec")

# Pasamos a otra variable el canton ya que esta codificada como factores

base_temp <- base %>% mutate(Canton = as.character(cantonrec))

# Eliminamos la variable antigua

base_temp <- base_temp %>% 
  dplyr::select(-cantonrec)

# Cambiamos el nombre de algunos cantones para que sea compatible con los otros
# conjuntos de datos

base_temp <- base_temp %>% 
  mutate(Canton = ifelse(Canton == "León Cortés Castro", 
                         "Leon Cortes",
                         ifelse(Canton == "Vázquez de Coronado", 
                                "Vazquez De Coronado",
                                ifelse(Canton == "Montes de Oro", 
                                       "Montes De Oro",
                                       ifelse(Canton == "Montes de Oca",
                                              "Montes De Oca",
                                              Canton)))))

# Quitamos las tildes en las variables de provincia y canton y eliminamos las
# codificaciones incorrectas
 
base_temp <- base_temp %>%
  mutate(Provincia = chartr('áéíóúñ', 'aeioun', provinciarec))
base_temp <- base_temp %>% 
  dplyr::select(-provinciarec)
base_temp <- base_temp %>% 
  mutate(Canton = chartr('áéíóúñ', 'aeioun', Canton))
base_temp <- base_temp %>% 
  filter(!(Canton == "99" | Canton == "Extranjero"))

# Dado que tenemos el conjunto de datos con las intoxicaciones arreglado, es
# necesario agregar la población por cantón para poder crear algunas variables
# posteriormente para el análisis. Empezamos por cargar el archivo de datos
# `censo_inec_2011.csv` que contiene la poblacion por canton al 2011, segun el
# censo.

censo <- read.csv("datos/crudos/censo_inec_2011.csv", stringsAsFactors = F, encoding = "UTF-8")

# En este caso, el conjunto de datos `censo` contiene las siguientes variables:
# • Provincia: provincia respectiva
# • Canton: canton respectivo
# • Distrito: distrito respectivo
# • Poblacion_Total: población total
# • Poblacion_Hombres: población de hombres
# • Poblacion_Mujeres: población de mujeres
# 
# Por ahora, solo necesitamos seleccionar las variables de la provincia, 
# canton, distrito y poblacion total

censo <- censo %>% dplyr::select(Provincia, Canton, Distrito, Poblacion_Total)

# Quitamos tildes en variable provincia

censo <- censo %>% mutate(Provincia = chartr('áéíóúñ', 'aeioun', Provincia))

# Quitamos tildes en variable canton

censo <- censo %>% mutate(Canton = chartr('áéíóúñ', 'aeioun', Canton))

# Cambiamos el nombre de algunos cantones para que sea compatible con los otros
# conjuntos de datos

censo2 <- censo %>% mutate(Canton = ifelse(Canton == "Ca~nas", "Canas",
                                           ifelse(Canton == "Leon Cort'es Castro","Leon Cortes",
                                                  ifelse(Canton == "Perez Zeled'on", "Perez Zeledon",
                                                         ifelse(Canton == "Vazquez de Coronado", "Vazquez De Coronado",
                                                                ifelse(Canton == "Montes de Oro", "Montes De Oro",
                                                                       ifelse(Canton == "Montes de Oca", "Montes De Oca",
                                                                              Canton)))))))

# Ahora, calculamos la población total para cada canton

censo2 <- censo2 %>% 
  group_by(Provincia, Canton) %>%
  mutate(poblacion = sum(Poblacion_Total))

# Seleccionamos variables de interes y eliminamos duplicados

censo2 <- censo2 %>% 
  dplyr::select(Provincia, Canton, poblacion) %>% 
  distinct(Provincia, Canton, .keep_all = T)

# Ordenamos por provincia y canton

censo2 <- censo2 %>% 
  arrange(Provincia, Canton)

# Unimos ambos conjuntos de datos en uno solo segun canton

base2 <- merge(base_temp, censo2, by = c("Provincia", "Canton"), all.x = F)
base2 <- base2 %>% 
  mutate(Canton = ifelse(Canton == "Canas", "Cañas", Canton))

# Calculamos la cantidad de intoxicaciones totales por canton

base_temp <- base2 %>% 
  group_by(Canton) %>%
  mutate(intoxicaciones = n())

# Seleccionamos variables de interes y eliminamos duplicados

base_temp <- base_temp %>% 
  dplyr::select(Provincia, Canton, intoxicaciones, poblacion) %>% 
  distinct(Canton, .keep_all = T)

# Calculamos la tasa de intoxicaciones por 10 mil habitantes

base_temp <- base_temp %>% 
  mutate(llamadas_10mil = round((intoxicaciones / poblacion) * 10000, 4))

# Cargamos los indices cantonales del 2011

ind_cantonales <- read_excel("datos/crudos/ind_cantonales.xlsx")

# La especificación de las variables está en el archivo README.md. Eliminamos
# las tildes y caracteres especiales de los nombres de los cantones

ind_cantonales <- ind_cantonales %>% 
  mutate(Canton = chartr('áéíóú', 'aeiou', Nombre)) %>% 
  dplyr::select(-Nombre, -`Población total`)

# Cambiamos el nombre de algunos cantones para que sea compatible con los otros
# conjuntos de datos

ind_cantonales$Canton[c(11, 15, 20, 68)] <- c("Vazquez De Coronado", 
                                              "Montes De Oca", 
                                              "Leon Cortes", 
                                              "Montes De Oro")

# Cambiamos el nombre de las variables para poder escribirlas mas facilmente

names(ind_cantonales) <- c("cod_dist", "victima", "superficie", "densidad_pob",
                           "por_pob_urb", "rel_homb_muj", "rel_depe_demo",
                           "viv_ocup", "promedio_ocup_viv", "por_viv_buen",
                           "por_viv_hacin", "por_alfab", "alf_10_24", "alf_25",
                           "prom_escol", "esc_25_49", "esc_50", "por_edu_reg",
                           "asis_menor5", "asis_5_17", "asis_18_24", "asis_25",
                           "fuera_trab", "tasa_partic", "hombres", "mujeres",
                           "por_ocup_aseg", "por_pob_ext", "por_pob_discp",
                           "por_pob_no_aseg", "por_hog_fem", "por_hog_comp",
                           "fincas_agro", "extension_agro", "trab_agro",
                           "menor_15", "Canton")

# Creamos la variable del porcentaje de la superficie del canton que se usa
# para actividades agricolas

ind_cantonales <- ind_cantonales %>% 
  mutate(por_agro = extension_agro * 0.01 / superficie * 100)

# Juntamos el conjunto de datos de intoxicaciones con el de los indicadores
# cantonales segun el canton

data <- inner_join(base_temp, ind_cantonales, by = "Canton")

# Guardamos los datos como un archivo .csv

write.csv2(data, "datos/procesados/indicadores.csv", row.names = FALSE)

# Cargamos el shapefile con Costa Rica y eliminamos la Isla del Coco para
# facilitar la visualizacion y analisis

s <- shapefile("datos/crudos/CRI_adm2.shp")
sub <- crop(s, extent(-88, -82, 7, 12))

# Guardamos este shapefile como `cantones.shp` para poder usarlo más adelante

shapefile(sub, 'datos/procesados/cantones.shp', overwrite = TRUE)

# Cargamos el shapefile que acabamos de guardar con codificación UTF-8

shp  <- readOGR("datos/procesados", "cantones", stringsAsFactors = FALSE,
                encoding = "UTF-8")

# Cambiamos el nombre de algunos cantones para que sean iguales entre el
# shapefile y los datos

shp$NAME_2[shp$NAME_2 %in% setdiff(unique(shp$NAME_2), 
                                   unique(data$Canton))] <- c("Zarcero", 
                                                              "Poas", 
                                                              "San Ramon", 
                                                              "Jimenez", 
                                                              "La Union", 
                                                              "Paraiso", 
                                                              "Tilaran", 
                                                              "Belen", 
                                                              "Santa Barbara", 
                                                              "Sarapiqui", 
                                                              "Guacimo", 
                                                              "Limon", 
                                                              "Pococi", 
                                                              "Montes De Oro", 
                                                              "Aserri", 
                                                              "Escazu", 
                                                              "Leon Cortes",
                                                              "Montes De Oca", 
                                                              "Perez Zeledon", 
                                                              "San Jose", 
                                                              "Tarrazu", 
                                                              "Tibas",
                                                              "Vazquez De Coronado")

# Hacemos un merge entre el shapefile y los datos

temp  <- merge(shp, data, by.x="NAME_2", by.y="Canton") 

# De nuevo, guardamos el shapefile con los datos para poder usarlo para el
# analisis posterior

shapefile(temp, 'datos/procesados/cantones_data.shp', overwrite = TRUE)

# Con esto, tenemos un shapefile que contiene los cantones del pais, además de
# la cantidad y la tasa de intoxicaciones por pesticidas en el periodo de
# interes, ademas de varios indicadores cantonales de interes.

###############################################################################
##################################### FIN #####################################
###############################################################################