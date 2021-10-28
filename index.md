# Efectos geoespaciales en la modelización del precio de la vivienda en la ciudad de Madrid

El objetivo de este proyecto consiste en realizar una estimación fiable del precio de la vivienda en la ciudad de Madrid conocidos los atributos de cada inmueble. Este tipo de estudios ha sido ampliamente realizado en el ámbito de la econometría, sin embargo, muy poca literatura recoge la influencia de los efectos espaciales en el poder predictivo de las distintas modelizaciones al incorporar información geográfica. 

Así, con el propósito de estudiar más en profundidad estos efectos, se proponen no solo modelos de regresión lineal múltiples, sino también desarrollos que
introducen la posible autocorrelación espacial tanto en la variable dependiente como en los residuos del sistema. De este modo, se busca alcanzar una especificación óptima, cuyas predicciones puedan ser aplicadas en el mercado inmobiliario.

## Antecedentes

Es posible, al trabajar con datos de corte transversal, encontrar los denominados **efectos espaciales** que se manifiestan a través de distintas dependencias entre observaciones con cierta proximidad geográfica. Estos efectos han sido ampliamente ignorados a lo largo de la historia por el hecho de que no pueden ser tratados por la econometría estándar, la cual se fundamenta en el análisis e interpretación de sistemas económicos con el fin de predecir variables tales como, por ejemplo, el precio de bienes y servicios. 

Debido a la necesidad de resolver los problemas de origen geoespacial que la econometría estándar no puede solucionar, nació la *econometría espacial*, término acuñado por Paelinck y Klaassen y que hace referencia a las técnicas que tratan las consecuencias causadas por efectos espaciales en el análisis estadístico de modelos econométricos tradicionales. En las últimas décadas, la importancia y relevancia de este tipo de análisis ha ido en auge, debido, en parte, a las cada vez más accesibles y extensas bases de datos geo-referenciados, así como al incremento de la capacidad de computación de modelos cada vez más complejos.

## Contexto

El mercado inmobiliario en España ha sufrido grandes altibajos durante las últimas décadas. Tras el mayor *parón* inmobiliario de la historia de España, producido en el año 2008, hubo un cambio de ciclo en el que los posibles compradores descendieron significativamente y además se tornaron más selectivos. La situación fue mejorando durante la década de los 2010, aunque a partir de 2020 se observa de nuevo una ralentización tanto en la subida del precio de la vivienda como en el volumen de compraventas. Este hecho parece indicar que pueda repetirse una situación similar a la de la crisis de 2008, en la cual el comprador sea reticente a tomar una decisión arriesgada y prefiera informarse adecuadamente. 

Es, por tanto, el momento idóneo para proporcionar herramientas de análisis al comprador que le ayuden a tomar una decisión informada y acertada a la hora de adquirir una vivienda. Una herramienta de modelizado del precio del metro cuadrado como la propuesta en este proyecto, cuyas predicciones sean robustas ante efectos espaciales y, por consiguiente, aporten mayor fiabilidad, es justamente lo que el demandante de vivienda necesita. A su vez, también se trata de un valioso y potente recurso para el sector empresarial, ya que aporta beneficios tales como una correcta valoración o tasación de inmuebles, que además puede descomponerse por características y determinar la aportación de cada una de ellas al precio total de cada vivienda.

La ciudad de Madrid es, sin duda, una de las que más variabilidad presenta en el precio de la vivienda entre distritos o barrios, lo cual la convierte en una elección interesante para este tipo de análisis.  

## Base de datos

La extracción de la información del portal inmobiliario [Idealista](https://www.idealista.com/) se ha llevado a cabo mediante un método de *web scraping* en el que se ha barrido cada uno de los 21 distritos de la ciudad de Madrid, de manera que se ha obtenido un total de 5935 observaciones.

Asimismo, en la gráfica se puede conocer la distribución del precio de mercado por metro cuadrado de los inmuebles en los diferentes distritos. Como se puede observar, hay una diferencia del 380% entre el barrio más caro, el de Salamanca, y el más barato, Villaverde. La variabilidad puede observarse en el mapa de la figura.

![Precio metro por distrito](/images/precio_metro_por_distrito.PNG)

Por otra parte, vamos a valernos del proyecto colaborativo [OpenStreetMap](https://www.openstreetmap.org/) para descargar información geográfica relevante (colegios, hospitales, etc.). La situación de los puntos de interés será incluida en nuestro conjunto de datos, permitiéndonos ponderar cada observación en relación a su proximidad a dichas localizaciones.

A continuación se incluyen las visualizaciones de los datos descargados, así como las variables calculadas a partir de los mismos:


- Hospitales

La información se ha descargado mediante una búsqueda con *key = 'amenity'* y *value = "hospital"*:

![Mapa de hospitales](/images/mapa_hospitales.PNG)

A partir de esta información se ha calculado la densidad de hospitales en un radio de 1km para cada vivienda.

- Centros comerciales

La información se ha descargado mediante una búsqueda con *key = 'shop'* y *value = "mall"*:

![Mapa de centros comerciales](/images/mapa_cc.PNG)

A partir de esta información se ha calculado la densidad de centros comerciales en un radio de 1km para cada vivienda.

- Transporte público

La información se ha descargado mediante una búsqueda con *key = 'public\_transport'* y *value = "station"*:

![Mapa de transporte publico](/images/mapa_tp.PNG)

A partir de esta información se ha calculado la distancia más cercana a una estación de metro o de cercanías RENFE para cada vivienda.

- Colegios

La información se ha descargado mediante una búsqueda con *key = 'amenity'* y *value = "school"*:

![Mapa de colegios](/images/mapa_colegios.PNG)

A partir de esta información se ha calculado la densidad de colegios en un radio de 1km para cada vivienda.

## Hipótesis previas

Se procede a plantear las hipótesis preliminares para los algoritmos de predicción a implementar, siendo estos tanto interpretables como no interpretables. Asimismo, los distintos modelos predictivos serán juzgados tanto en base a sus respectivas bondades de ajuste como a través del análisis de sus residuos con la finalidad de determinar su idoneidad.


### Regresión lineal múltiple (RLM)

Nuestro punto de partida será una regresión lineal múltiple, cuya forma funcional viene dada por:

<a href="https://www.codecogs.com/eqnedit.php?latex=Y&space;=&space;\sum_{i=1}^k&space;X_i&space;\beta_i&space;&plus;&space;\epsilon" target="_blank"><img src="https://latex.codecogs.com/svg.latex?Y&space;=&space;\sum_{i=1}^k&space;X_i&space;\beta_i&space;&plus;&space;\epsilon" title="Y = \sum_{i=1}^k X_i \beta_i + \epsilon" /></a>

donde Y es la variable dependiente de interés (el precio de la vivienda), X<sub>i</sub> son las variables explicativas del modelo, β<sub>i</sub> es el coeficiente de regresión que mide la influencia de cada variable X<sub>i</sub> sobre Y y ε es el error aleatorio.

Las principales hipótesis de este tipo de regresión son:


- **Linealidad** en la relación entre X<sub>i</sub> e Y.
  
- **Independencia** entre las observaciones, entre las variables explicativas y entre los residuos del modelo.
    
- **Normalidad** en la distribución de los residuos.
    
- **Homocedasticidad** en los residuos.
    

En cuanto se viola una de las hipótesis, el modelo deja de ser óptimo y no podemos garantizar la fiabilidad de sus predicciones. En este caso, nuestro conjunto de datos está muy afectado por la dependencia espacial, lo cual se traduce en dependencias entre observaciones y heterocedasticidad en los residuos. Para hacer frente a este inconveniente, tomamos dos planteamientos alternativos:

1.  Adición de variables espaciales con la intención de vencer la dependencia espacial.
    
2. Adición de no linealidades mediante modelos *Multiadaptative regression splines* (MARS).

Aun así, no esperamos lograr romper completamente los efectos espaciales, por lo que recurriremos a modelos más robustos en los que se añade un término de dependencia espacial, bien en la variable dependiente (modelos de retardo espacial), bien en los residuos (modelos de error espacial).

### Modelos de retardo espacial (SAR)

Este tipo de modelos incluyen la correlación espacial en la variable dependiente y permiten a las observaciones en una determinada zona depender de observaciones en áreas vecinas. El modelo de retardo espacial básico se define como:


<a href="https://www.codecogs.com/eqnedit.php?latex=Y=X\beta&space;&plus;&space;\rho&space;WY&plus;\epsilon" target="_blank"><img src="https://latex.codecogs.com/svg.latex?Y=X\beta&space;&plus;&space;\rho&space;WY&plus;\epsilon" title="Y=X\beta + \rho WY+\epsilon" /></a>


siendo $W$ la matriz de pesos espaciales, ε los errores independientes y ρ el nivel de relación autorregresiva espacial entre la variable dependiente y sus observaciones vecinas. Es decir, ρ es el impacto ''boca a boca'', lo cual quiere decir que las observaciones están impactadas por lo que sucede a su alrededor.

Resolviendo el sistema se obtiene:

<a href="https://www.codecogs.com/eqnedit.php?latex=Y=(I-\rho&space;W)^{-1}(X\beta&space;&plus;\epsilon)&space;\to&space;E[Y]=(I-\rho&space;W)^{-1}(X\beta)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?Y=(I-\rho&space;W)^{-1}(X\beta&space;&plus;\epsilon)&space;\to&space;E[Y]=(I-\rho&space;W)^{-1}(X\beta)" title="Y=(I-\rho W)^{-1}(X\beta +\epsilon) \to E[Y]=(I-\rho W)^{-1}(X\beta)" /></a>

De esta forma, esperamos obtener un ρ muy significativo, de manera que los residuos del sistema puedan considerarse independientes y, por tanto, estemos ante una mejor especificación del modelo. 

### Modelos de error espacial (SEM)

Como ya hemos argumentado, este tipo de modelos explican la dependencia espacial en el término de error o residual, es decir,  el error lleva implícita una estructura espacial. 

Se define como:

<a href="https://www.codecogs.com/eqnedit.php?latex=Y=X\beta&space;&plus;&space;e" target="_blank"><img src="https://latex.codecogs.com/svg.latex?Y=X\beta&space;&plus;&space;e" title="Y=X\beta + e" /></a>

<a href="https://www.codecogs.com/eqnedit.php?latex=e&space;=&space;\lambda&space;W&space;e&space;&plus;&space;\epsilon" target="_blank"><img src="https://latex.codecogs.com/svg.latex?e&space;=&space;\lambda&space;W&space;e&space;&plus;&space;\epsilon" title="e = \lambda W e + \epsilon" /></a>

donde W es la matriz de pesos espaciales, ε el término aleatorio de error y $\lambda$ es el parámetro autorregresivo. 

Resolviendo el sistema:

<a href="https://www.codecogs.com/eqnedit.php?latex=Y=X\beta&space;&plus;&space;(I-&space;\lambda&space;W)^{-1}&space;\epsilon" target="_blank"><img src="https://latex.codecogs.com/svg.latex?Y=X\beta&space;&plus;&space;(I-&space;\lambda&space;W)^{-1}&space;\epsilon" title="Y=X\beta + (I- \lambda W)^{-1} \epsilon" /></a>

En esta ocasión esperamos vencer por completo la heterocedasticidad de los residuos y, al igual que en el modelo SAR, lograr una muy buena especificación del sistema.

### Modelos geográficamente ponderados (GWR)

Hasta ahora hemos definido modelos de regresión global general, en los cuales se tienen valores únicos de los parámetros β<sub>i</sub> para todas las observaciones del conjunto de datos.

Con este tipo de modelizado, sin embargo, en lugar de tener un coeficiente global para cada variable, los coeficientes pueden variar en función del espacio. La idea fundamental es la medición de la relación entre la variable respuesta y sus variables explicativas independientes a través de la combinación de las diferentes áreas geográficas.

El modelo se define como:  

<a href="https://www.codecogs.com/eqnedit.php?latex=Y_s=\beta_{s1}X_1&plus;\ldots&plus;\beta_{s1}X_p&plus;\epsilon" target="_blank"><img src="https://latex.codecogs.com/svg.latex?Y_s=\beta_{s1}X_1&plus;\ldots&plus;\beta_{s1}X_p&plus;\epsilon" title="Y_s=\beta_{s1}X_1+\ldots+\beta_{s1}X_p+\epsilon" /></a>

siendo $s$ cada zona geográfica. Es decir, en el modelo ponderado geográficamente se tienen diferentes estimadores para cada una de las variables dependiendo de la localización.
  
Resolviendo el sistema:

<a href="https://www.codecogs.com/eqnedit.php?latex=\beta_s=(X^tW_sX)^{-1}X^tW_sY" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\beta_s=(X^tW_sX)^{-1}X^tW_sY" title="\beta_s=(X^tW_sX)^{-1}X^tW_sY" /></a>

Así, conseguimos reducir la dependencia espacial de los residuos del modelo, aunque no vamos a romper la heterocedasticidad de los mismos como veremos más adelante.

### Gradient Boosting (GB)

El método de *Gradient Boosting* es una técnica de aprendizaje automático o *Machine Learning* que genera un modelo predictivo a partir de un conjunto de algoritmos de predicción débiles, típicamente árboles de decisión. 

Al combinar *weak learners* de forma iterativa, el objetivo es que el algoritmo  F aprenda a predecir valores minimizando el error cuadrático medio. De esta manera, en cada iteración el árbol de decisión se centra en disminuir los errores arrojados en la predicción previa. La predicción final se obtendrá a partir de la suma de todas las predicciones de los árboles de decisión implementados.

Al contrario de los modelos propuestos hasta ahora, el método de GB se trata de una técnica no interpretable, que además requiere de un gran esfuerzo en la parametrización o *fine-tunning*, de manera que no se caiga en un sobreajuste al conjunto de datos.

## Evaluación de los modelos

A la hora de evaluar cada modelo y determinar su bondad de ajuste, vamos a apoyarnos fundamentalmente en cuatro validaciones:

1. Coeficiente de determinación ajustado. Su valor indica la proporción de variabilidad en la variable endógena explicada por el modelo en relación a la variabilidad total, ajustándose al número de grados de libertad: 
    
  <a href="https://www.codecogs.com/eqnedit.php?latex=\bar{R}^2&space;=1&space;-&space;\frac{n-1}{n-k-1}&space;\frac{SS_{\text{res}}}{SS_{\text{tot}}}" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\bar{R}^2&space;=1&space;-&space;\frac{n-1}{n-k-1}&space;\frac{SS_{\text{res}}}{SS_{\text{tot}}}" title="\bar{R}^2 =1 - \frac{n-1}{n-k-1} \frac{SS_{\text{res}}}{SS_{\text{tot}}}" /></a>

  siendo n el tamaño de la base de datos, k el número de variables explicativas, SS<sub>res</sub> la suma de residuos al cuadrado y SS<sub>tot</sub> la suma total de cuadrados.

2. *I* de Moran. Este indicador proporciona una medida de la autocorrelación espacial, comparando el valor en una determinada área i en relación al resto de áreas. Su forma viene dada por
    
  <a href="https://www.codecogs.com/eqnedit.php?latex=I&space;=&space;\frac{N}{\sum_i&space;\sum_j&space;w_{ij}}&space;\frac{\sum_i&space;\sum_j&space;w_{ij}&space;(y_i&space;-&space;\bar{y})&space;(y_j&space;-&space;\bar{y})}{\sum_i&space;(y_i&space;-&space;\bar{y})^2}" target="_blank"><img src="https://latex.codecogs.com/svg.latex?I&space;=&space;\frac{N}{\sum_i&space;\sum_j&space;w_{ij}}&space;\frac{\sum_i&space;\sum_j&space;w_{ij}&space;(y_i&space;-&space;\bar{y})&space;(y_j&space;-&space;\bar{y})}{\sum_i&space;(y_i&space;-&space;\bar{y})^2}" title="I = \frac{N}{\sum_i \sum_j w_{ij}} \frac{\sum_i \sum_j w_{ij} (y_i - \bar{y}) (y_j - \bar{y})}{\sum_i (y_i - \bar{y})^2}" /></a>
    
  siendo N el número de áreas consideradas, w<sub>ij</sub> las componentes de la matriz de pesos espaciales y Y<sub>i</sub> el valor de la variable Y en el área i.
    
3. *Test* de *Jarque-Bera*. Se trata de una prueba de bondad de ajuste para comprobar si una muestra de datos tiene la asimetría y curtosis de una distribución normal. Su forma es

  <a href="https://www.codecogs.com/eqnedit.php?latex=I&space;=&space;\frac{n}{6}&space;\left&space;(&space;S^2&space;&plus;&space;\frac{1}{4}&space;(K-3)^2\right&space;)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?I&space;=&space;\frac{n}{6}&space;\left&space;(&space;S^2&space;&plus;&space;\frac{1}{4}&space;(K-3)^2\right&space;)" title="I = \frac{n}{6} \left ( S^2 + \frac{1}{4} (K-3)^2\right )" /></a>
    
  donde n es el número de observaciones, S la asimetría de la muestra y K la curtosis.
    
4. *Spatial Scan Statistics*. Detecta y evalúa *clusters* en el espacio, permitiendo diferenciar si estos ocurren de forma aleatoria o siguen una distribución de probabilidad determinada. Para ello, se analiza gradualmente en intervalos espaciales si la variable en cuestión toma valores diferentes a los esperados.
    
    En nuestro caso, usaremos la herramienta [SatScan](https://www.satscan.org/), un *software* especializado mediante el cual analizaremos los residuos de cada modelo, esperando que su distribución sea normal en cada región del espacio. Definimos estos intervalos espaciales usando círculos que contengan al 10\% de la población y cuyo centro esté localizado en cada una de nuestras observaciones. El programa se valdrá de simulaciones Montecarlo, obteniendo un p-value para cada región que no cumpla la distribución esperada.

## Comparativa entre modelos

Como puede observarse, todos los modelos poseen un coeficiente de determinación ajustado superior al 75% sobre una base de datos de prueba, por lo que todos ellos proporcionan una explicación lo suficientemente buena de la variabilidad de la variable dependiente.

![Comparativa_R2](/images/R_2_por_modelo.PNG)

En lo referente al poder predictivo de cada uno de ellos, es necesario diferenciar el modelo de *Machine Learning*, *Gradient Boost*, por tratarse de un algoritmo no interpretable. Así, si bien es el que mejores predicciones arroja de todos los modelos implementados, no tenemos conocimiento de cómo está contribuyendo cada variable, es decir, no se conoce el efecto marginal de cada atributo al precio final de la vivienda. En este sentido, se trata de una ''caja negra'' que puede no ser del todo conveniente si lo que se busca es entender cómo se ve afectado el valor de un inmueble en función de sus características. 

Si indagamos un poco más en los residuos, vemos lo siguiente:

![Comparativa_final](/images/comparativa_final.PNG)

El principal objetivo de este proyecto consistía en implementar una correcta modelización del precio del metro cuadrado en la ciudad de Madrid, para lo cual se ha buscado romper tanto la heterocedasticidad como la dependencia espacial con el objetivo de arrojar predicciones robustas sobre futuras valoraciones de nuevos inmuebles. Con esta premisa en mente, podemos descartar los modelos RLM, GWR y GB ya que que no cumplen con la meta que nos hemos propuesto. En efecto, ninguno de ellos es capaz de vencer los efectos espaciales, por lo que sus estimaciones serán en general sesgadas y poco fiables. 

De entre las modelizaciones restantes, las cuales sí son interpretables, aquellas con mayor capacidad predictiva son el modelo de retardo espacial y el modelo de error espacial. Estos algoritmos sí que permiten conocer cómo afecta la variación de una variable independiente al resultado final, por lo que son una elección acertada en las situaciones en las que se requiera considerar este tipo de impacto sobre el precio de la vivienda.

Además, los modelos SAR y SEM sí consiguen deshacerse de los efectos espaciales puesyo que un valor de los parámetros ρ y λ significativos implica un alto nivel de relación autorregresiva espacial entre la variable dependiente y sus observaciones vecinas. Es decir, se están incorporando satisfactoriamente los efectos espaciales en estos modelos. Este factor se ve recalcado mediante el resultado del *test* *I* de Moran, para el cual observamos un valor compatible con la hipótesis nula según la cual no existe dependencia espacial en los residuos. Por tanto, se concluye que los residuos no están autocorrelados espacialmente y **se ha conseguido romper la dependencia espacial**. 

En concreto, a la hora de discernir cuál de los dos modelos es más apropiado, puede argumentarse que el poder de predicción del modelo SAR es ligeramente superior (0.5%), mientras que el modelo SEM parece eliminar más exitosamente la autocorrelación espacial. Por tanto, a priori no existen grandes disimilitudes entre ambos y la elección deberá realizarse basándose en las discrepancias entre resultados --de haberlas-- al aplicarse sobre diferentes bases de datos.

Por otra parte, es útil considerar la información recopilada en el siguiente cuadro, en el cual se muestran los resultados del análisis estadístico espacial realizado mediante la herramienta *SatScan*. 

![Comparativa_final SS](/images/comparativa_final_SS.PNG)

Conociéndose el número de *clusters* con p-value inferior al 10%, así como el porcentaje de población que estos representan y su distribución en el espacio, podremos discernir las zonas problemáticas para cada modelo. De esta forma, por ejemplo, para los modelos interpretables SAR y SEM se tiene que el centro de Madrid es probablemente más propenso a arrojar errores en la predicción, si bien el porcentaje total de la población que representan es bastante bajo (<5%). Así, las posibles causas de este efecto pueden ser las expuestas a continuación:

- Omisión de variables relevantes. Pese a que nuestro modelo incluye la variable *dist\_centro* (representando la distancia al centro de Madrid), así como los diferentes distritos en los que se halla cada piso, puede que la dimensión espacial no se esté teniendo en cuenta adecuadamente o haya más atributos relevantes en esta zona. 

- Mala especificación del modelo. Es posible que nuestro modelo no sea el adecuado para resolver este tipo de problema y, aunque se incluyan más variables explicativas, no se aprecie ninguna mejora significativa. 

- Problemas con la linealidad del modelo. Puede ocurrir que las variables presenten no linealidades precisamente en las regiones identificadas con *SatScan*.

En contraposición, el modelo no interpretable GB es menos fiable al sur y este de la ciudad, comprendiendo en este caso más del doble de observaciones con respecto al SAR y SEM (casi un 10%).



