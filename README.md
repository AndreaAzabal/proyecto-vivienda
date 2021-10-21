# Efectos geoespaciales en la modelización del precio de la vivienda en la ciudad de Madrid


## Descripción

Este proyecto desarrollado en R busca recopilar los pasos seguidos a la hora de realizar un análisis exhaustivo del precio de la vivienda en la ciudad de Madrid. El principal objetivo es obtener una herramienta fidedigna de predicción del precio del metro cuadrado de la vivienda que sea capaz de romper los efectos espaciales y se trate, por tanto, de una herramienta de tasación fiable.

El desarrollo se ha llevado a cabo en tres fases:

- Fase 1: obtención de la base de datos.
- Fase 2: limpieza y preparación de la base de datos.
- Fase 3: análisis y resultados.

# Fase 1

La extracción se realiza a partir del portal inmobiliario [Idealista](https://www.idealista.com/). Con esta finalidad se ha generado un script de web scraping en lenguaje R, en el cual se recorren cada uno de los distritos de la ciudad de Madrid en busca de viviendas. Además, se lleva a cabo un registro de los identificadores de cada inmueble para no almacenar duplicados. Los filtros pueden ser modificados con la finalidad de adaptar la zona geográfica de interés, así como filtrar viviendas por tipo, número de habitaciones, ascensor, etc.

El resultado es un fichero HTML del cual se pueden extraer las principales características de cada inmueble que posteriormente serán utilizadas en las distintas modelizaciones gracias a un script en Python. Además, también se extraen y se almacenan las coordenadas geoespaciales.

## Fase 2

Se eliminan tanto duplicados que han escapado al filtrado inicial como viviendas con datos erróneos. Se generan variables calculadas a partir de las características de cada inmueble.

Una vez la base de datos está limpia y lista para ser utilizada, se descarga información sobre puntos geográficos de interés desde la plataforma [OpenStreetMap](https://www.openstreetmap.org/). Esta información se utiliza para calcular las distancias de cada vivienda a los puntos relevantes, con el fin de incorporar la variable espacial al análisis.

## Fase 3

En la última fase del proyecto, se entrenan y validan los distintos algoritmos de predicción:

- Modelo de regresión lineal múltiple
- Multiadaptative regression splines
- Modelo de retardo espacial
- Modelo de error espacial
- Modelo geográficamente ponderado
- Gradient Boost

## Requerimientos

En este repositorio encontrará:

- procesoExtraccionIdealista/Idealista.R: script en R que extrae viviendas de Idealista en formato HTML.
- procesoExtraccionIdealista/Control/control_descarga.csv: se generará un fichero de este tipo durante la recopilación de HTLM para evitar almacenar duplicados. 
- procesoParseadoIdealista/main.py: script en Python que se encarga de extraer las principales características de los HTML y crear la base de datos en formato CSV.
- procesoParseadoIdealista/count.py: script auxiliar para llevar un registro del número de viviendas por distrito.
- install.R: Archivo de requerimientos de R
- Functions_TFM.R: script con funciones auxiliares customizadas.
- analisis/1 Variables.Rmd: análisis y limpieza de la base de datos.
- analisis/2 GLM.Rmd: regresión lineal múltiple.
- analisis/3 EspacialSAR.Rmd: modelo de retardo espacial.
- analisis/4 EspacialSEM.Rmd: modelo de error espacial.
- analisis/5 EspacialGWR.Rmd: modelo geográficamente ponderado.
- analisis/6 Gboost.Rmd: Gradient Boost.
