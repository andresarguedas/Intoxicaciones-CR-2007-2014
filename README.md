# Intoxicaciones por pesticidas en Costa Rica 2007-2014

![Tamaño](https://github-size-badge.herokuapp.com/andresarguedas/proyecto-final-espacial.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![License: CC BY 4.0](https://licensebuttons.net/l/by/4.0/80x15.png)](https://creativecommons.org/licenses/by/4.0/deed.es)

## Resumen

Este repositorio contiene el código, datos y video de la presentación sobre el proyecto final del curso SP-1649 Tópicos de Estadística Espacial Aplicada: **Intoxicaciones por pesticidas, a nivel cantonal, en Costa Rica durante el periodo 2007 al 2014**, desarrollado por Andrés Arguedas y Natalia Díaz, como parte de la Maestría en Estadística de la Universidad de Costa Rica. El documento del informe final está disponible de forma abierta en Overleaf en el siguiente enlace: https://www.overleaf.com/read/wsbdrvgymtbz

- [Intoxicaciones por pesticidas en Costa Rica 2007-2014](#intoxicaciones-por-pesticidas-en-costa-rica-2007-2014)
  - [Resumen](#resumen)
  - [Estructura del repositorio](#estructura-del-repositorio)
  - [Datos](#datos)
    - [Fuentes de información](#fuentes-de-informaci%C3%B3n)
    - [Descripción de los conjuntos de datos](#descripci%C3%B3n-de-los-conjuntos-de-datos)
      - [Crudos](#crudos)
      - [Procesados](#procesados)
    - [Variables en cada conjunto de datos](#variables-en-cada-conjunto-de-datos)
  - [Procesamiento y análisis de los datos](#procesamiento-y-an%C3%A1lisis-de-los-datos)
    - [Limpieza](#limpieza)
    - [Análisis](#an%C3%A1lisis)
  - [Gráficos](#gr%C3%A1ficos)
  - [Preguntas](#preguntas)
  - [Licencia](#licencia)

## Estructura del repositorio

El repositorio está compuesto por dos archivos de R, usados para la limpieza y análisis de los datos, y dos carpetas que contienen los datos y los gráficos producidos y usados en el artículo final:

- Los archivos de R, disponibles en formato `.R`, contienen los procedimientos usados para la limpieza de los datos (`limpieza.R`) y otro para replicar los resultados y el análisis presentados en el informe final y la presentación (`analisis.R`).
- La carpeta `datos` contiene los datos usados y producidos por los scripts mencionados anteriormente, mientras que la carpeta `plots` contiene los gráficos producidos y usados en el artículo. Dentro de la carpeta `datos` hay otras dos carpetas, `crudos` y `procesados`, que contienen los datos crudos, recopilados de distintas fuentes, y los datos *"limpios"* procesados mediante el script de limpieza.

## Datos

### Fuentes de información

Los datos usados en el análisis y contenidos en la carpeta `datos/crudos` provienen de tres fuentes distintas:

- [Centro Nacional de Control de Intoxicaciones](https://www.redciatox.org/centro-nacional-de-control-de-intoxicaciones-de-costa-rica)
- [Instituto Nacional de Estadística y Censos (INEC)](http://www.inec.go.cr)
- [GADM](https://gadm.org/index.html)

### Descripción de los conjuntos de datos

Los archivos crudos se obtuvieron de las fuentes de información descritas anteriormente y son los archivos necesarios para poder ejecutar el script `limpieza.R`, que crean los conjuntos de datos procesados, que posteriormente son usados para el análisis por el script `analisis.R`.

#### Crudos

La información sobre las llamadas por casos de intoxicaciones recibidas por el Centro Nacional de Intoxicaciones están en el archivo `base-descriptivo.sav`. Este archivo contiene información general, anonimizada, sobre la intoxicación, además de variables sociodemográficas sobre la persona intoxicada.

El archivo `censo_inec_2011.csv` contiene la población de cada distrito obtenida con base en el Censo del 2011, de forma total y separada según sexo. Además contiene la información sobre el cantón y provincia a la cual pertenece cada distrito.

El último archivo con datos es `ind_cantonales.xlsx`, que contiene diversos indicadores a nivel cantonal, obtenidos con base en el Censo del 2011, además del nombre y la provincia a la cual pertenece cada cantón.

Por último, los archivos `CRI_adm2.*` son usados para poder hacer el mapa por cantones de Costa Rica y guardar información relacionada con estos cantones.

#### Procesados

Los archivos `cantones.*` y `cantones_data.*` contienen los polígonos a nivel cantonal de Costa Rica, sin tomar en cuenta la Isla del Coco. La diferencia entre ambos conjuntos de datos es que `cantones_data.*` contiene la información y las variables de interés para cada cantón, mientras que `cantones.*` solo contiene los polígonos.

El archivo `indicadores.csv` contiene la información de los cantones, agrupada mediante el script de limpieza junto con las variables creadas en ese mismo script, que está incluido como parte de los datos disponibles en `cantones_data.*`.

### Variables en cada conjunto de datos

1) `base-descriptivo.sav`:

   - **ID:** Identificador de la llamada
   - **Año:** Año en el cual se hizo la llamada
   - **provinciarec:** Provincia en la cual se dio la intoxicación
   - **cantonrec:** Cantón en el cual se dio la intoxicación
   - **zona:** Recodificación de la zona en urbano, semiurbano, rural y extranjero
   - **Grupo_edad:** Recodificación de la edad de la persona en grupos de edad de 0 a 11, 12 a 19, 20 a 64 y 64 y más, o desconocido
   - **Sexo:** Sexo de la persona; puede ser hombre, mujer o no anotado
   - **Toxico1** - **Toxico6:** Nombre de las sustancias toxicas ingeridas
   - **Mezclo:** Indica si la persona mezcló mas de una sustancia o no 
   - **Agente1** - **Agente6:** Tipo de sustancias tóxicas ingeridas
   - **Causarec:** Clasificación de la causa de la intoxicacion como tentativa suicida, accidental, ocupacional, mal uso (por ejemplo, cuando no se usa la debida proteccion en ropa o lentes)
   - **Rutarec:** El medio por el que se dio la intoxicacion: ingestión, inhalación, etc.

2) `ind_cantonales.xls`:

   - **cod_dist:** Código del distrito en tres números, donde el primero es la provincia y los otros dos son el número del cantón dentro de esa provincia
   - **Nombre:** Nombre del cantón
   - **VICTIMA_2018:** Índice de victimización del 2018
   - **Población total:** Población total en el cantón
   - **Superficie (km2):** Superficie total del cantón en km<sup>2</sup>
   - **Densidad_población_Personas por km2:** Población total dividido entre la superficie del cantón
   - **Porcentaje de población urbana_Personas que viven en zona urbana por cada 100:** Porcentaje de la población del cantón que vive en sectores urbanos
   - **Rel_homb_muj:** Relación hombres-mujeres; cantidad de hombres por cada 100 mujeres
   - **Rel_depe_demo:** Relación de dependencia demográfica; personas dependientes (menores de 15 años o de 65 y más) por cada 100 personas en edad productiva (15 a 64 años)
   - **Viviendas_ind_ocup:** Viviendas individuales ocupadas
   - **Promedio_ocup_viv:**	Promedio de personas por vivienda individual ocupada
   - **Porcentaje_viv_buen_ estado:** Porcentaje de viviendas en buen estado
   - **Porc_viv_hacinadas:** Porcentaje de viviendas hacinadas
   - **Porc_alfab:** Porcentaje de alfabetismo total
   - **alfb_10_24:** Porcentaje de alfabetismo en personas de 10 a 24 años
   - **alfa_25ymás:** Porcentaje de alfabetismo en personas mayores de 25 años
   - **Escolaridad_prom:** Escolaridad promedio total
   - **esc_25a49:** Escolaridad promedio de personas entre 25 y 49 años
   - **esc_50omás:** Escolaridad promedio de personas mayores de 50 años
   - **Porc_asist_edu_reg:** Porcentaje de la población que ha asistido a educación regular
   - **asist_eduMenor5:** Porcentaje de la población menor de 5 años que ha asistido a educación regular
   - **asist_edu5a17:** Porcentaje de la población entre 5 y 17 años que ha asistido a educación regular
   - **asist_edu18a24:** Porcentaje de la población entre 18 y 24 años que ha asistido a educación regular
   - **asist_edu25ymás:** Porcentaje de la población mayor de 25 años que ha asistido a educación regular
   - **Pers_fuera_fuerza_trab:** Cantidad de personas mayores de 15 años fuera de la fuerza de trabajo
   - **Tasa_neta_particip:** Tasa neta de participación total
   - **Hombres:** Tasa neta de participación en hombres
   - **Mujeres:** Tasa neta de participación en mujeres
   - **Porc_pob_ocupada_aseg:** Porcentaje de la población ocupada no asegurada
   - **Porc_pob_nacida_ext:** Porcentaje de la población nacida en el extranjero
   - **Porc_pob_discp:** Porcentaje de la población con discapacidad
   - **Porc_pob_no_aseg:** Porcentaje de la población no asegurada
   - **Porc_hog_jef_fem:** Porcentaje de hogares con jefatura femenina
   - **Porc_hog_jef_comp:** Porcentaje de hogares con jefatura compartida
   - **Fincas_agro:** Cantidad de fincas dedicadas a labores agrícolas
   - **Extension_agro:** Extensión (en hectáreas) de las fincas dedicadas a labores agrícolas
   - **Por_agro:** Porcentaje de los hombres ocupados mayores de 15 años que se dedican a labores agrícolas
   - **Por_menor_15:** Porcentaje de la población menor de 15 años

3) `censo_inec_2011.csv`:

   - **Provincia:** Provincia respectiva
   - **Canton:** Cantón respectivo
   - **Distrito:** Distrito respectivo
   - **Poblacion_Total:** Población total en el distrito
   - **Poblacion_Hombres:** Población de hombres en el distrito
   - **Poblacion_Mujeres:** Población de mujeres en el distrito

El archivo de datos `indicadores.csv` contiene las mismas variables que `cantones_data.dbf` y todas las del archivo `ind_cantonales.xsl`, además de una nueva variable que contiene el porcentaje de la superficie del cantón que se dedica a labores agrícolas (**por_agro**). Aun así, los nombres de las variables fueron abreviados para el archivo `indicadores.csv` y, automáticamente, fueron abreviados de nuevo en el archivo `cantones_data.dbf`. Por lo anterior, el nombre de las variables no es exactamente el mismo en los tres conjuntos de datos, pero la posición de estas variables en los conjuntos de datos si es la misma.

## Procesamiento y análisis de los datos

Los datos fueron procesados usando R, ya que, aunque alguno de los formatos de los datos no son abiertos, existen paquetes abiertos en R que permiten trabajar con estos conjuntos de datos. Primero se hizo una limpieza y unión de los datos, para terminar con un solo shapefile que tuviera incluidas los polígonos de los cantones además de los indicadores cantonales de interés. Teniendo este conjunto de datos limpio, se realizaron distintos análisis de los datos en R, descritos más a profunidad en el script respectivo y el artículo, que producen, entre otros, los gráficos disponibles en la carpeta `plots`.

### Limpieza

Se parte del conjunto de datos `base-descriptivo.sav`, que contiene la información de las intoxicaciones, donde se eliminan algunas variables que no son de interés y se limpian los nombres de los cantones y las provincias para que no contengan caracteres especiales. Posteriormente, se usa el archivo `censo_inec_2011.csv` para obtener la población de cada cantón, para agrupar las intoxicaciones según el cantón y poder calcular, adicionalmente, la tasa de intoxicaciones por 10 mil habitantes en cada cantón. Para este entonces, se tiene un conjunto de datos nuevo, producido como una mezcla de ambos conjuntos descritos anteriormente, que contiene, para cada cantón, la cantidad total y la tasa de intoxicaciones por pesticidas por 10 mil habitantes. Seguidamente, se carga el archivo `ind_cantonales.xls` y se junta la información de estos indicadores cantonales con los datos sobre las intoxicaciones por cantón, produciendo así el archivo `indicadores.csv`, que contiene esta información por cantón.

Con respecto a los archivos de polígonos, se modifican los archivos `CRI_adm2.*` para recortar el polígono de la Isla del Coco, guardando el shapefile resultante en los archivos `cantones.*`. Teniendo este shapefile modificado, se le agrega la información de los indicadores cantonales para terminar con los archivos `cantones_data.*` que contienen tanto los polígonos de los cantones como los indicadores y la información pertinente sobre intoxicaciones para cada cantón, el cual es usado para el análisis de los datos.

### Análisis

El análisis de los datos se describe en el archivo `analisis.R` y el artículo vinculado al repositorio.

De forma resumida, los análisis son técnicas de estadísticas de áreas, mediante los cuales se busca determinar la existencia de aglomeraciones de cantones según las intoxicaciones, además de la influencia de ciertas otras variables a nivel cantonal sobre la tasa de intoxicaciones.

Para empezar, se realizaron una serie de descripciones de los datos, tanto tomando la cantidad total de intoxicaciones como la tasa por 10 mil habitantes. Posterior a esto se define la forma de escoger cantones vecinos y el estilo mediante el cual se calculan los pesos entre esos vecinos. Teniendo esto definido, se calcula la I de Moran para cada una de las variables de interés y se determinan posibles cantones que estén aglomerados o que representan puntos calientes. Por último, tomando solamente la tasa de intoxicaciones por 10 mil habitantes se hacen tres modelos de regresión: una regresión lineal mediante mínimos cuadrados ordinarios, un modelo SAR y un modelo CAR, los tres usando variables sobre el porcentaje de alfabetización, la importancia de la actividad agrícola en el cantón y el porcentaje de población menor de 15 años. Con base en estos modelos se hizo una selección de variables para terminar con tres modelos finales, comparándolos mediante el AIC y los residuales, para determinar si existe autocorrelación espacial en estos.

## Gráficos

Los gráficos presentes en la carpeta `plots` son generados mediante los comandos del script `analisis.R`, con base en los datos del shapefile `cantones_data.*`. Estos gráficos son usados en el artículo y los títulos de estos, como vienen en el artículo, son los siguientes:

- `Fig1.pdf`: Cantidad de intoxicaciones por pesticidas según cantón, en Costa Rica, del 2007 al 2014
- `Fig2.pdf`: Cantidad de intoxicaciones por pesticidas por 10 mil habitantes, según cantón, en Costa Rica, del 2007 al 2014
- `Fig3.pdf`: Comparación de seis métodos distintos para determinar cantones vecinos en Costa Rica. a) Método de la reina b) Método de la torre c) k vecinos más cercanos usando k=1 d) k vecinos más cercanos usando k=2 e) k vecinos más cercanos usando k=4 f) k vecinos más cercanos con distancia máxima igual a la distancia máxima obtenido mediante el método de la reina
- `Fig4.pdf`: Cantones de influencia en tasa de intoxicaciones por 10 mil habitantes. La etiqueta HL significa un cantón una tasa alta rodeado por cantones con tasas menores, LH es cuando se trata de un cantón con tasa baja rodeado por cantones con tasas altas y HH es un cantón rodeado por cantones con tasas altas
- `Fig5.pdf`: Probabilidad de cada supuesto en tasa de intoxicaciones por 10 mil habitantes
- `Fig6-1.pdf`, `Fig6-2.pdf` y `Fig6-3.pdf`: Residuales en las estimaciones de las tasas de intoxicaciones de los modelos de regresión lineal, SAR y CAR, respectivamente

Cabe resaltar que los archivos `Fig6-1.pdf`, `Fig6-2.pdf` y `Fig6-3.pdf` son tres gráficos separados que forman parte de una sola figura, la *Figura 6* en el artículo.

## Preguntas

Cualquier pregunta o puede escribirle a los autores y dueños de este repositorio a las siguientes direcciones de correo electrónico:

- Andrés Arguedas: andres.arguedas.leiva@gmail.com
- Natalia Diaz: natalia.d1411@gmail.com

## Licencia

El código usado y presentado en este repositorio tiene una licencia [MIT](https://opensource.org/licenses/MIT), mientras que los datos y figuras tienen una licencia [CC-BY](https://creativecommons.org/licenses/by/4.0/deed.es), a menos que se especifique explicitamente otra licencia. Las condiciones de las licencias anteriormente mencionadas están descritas en el archivo `LICENSE` de este repositorio.

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Esta obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by/4.0/deed.es">Licencia Creative Commons Atribución 4.0 Internacional</a>.
