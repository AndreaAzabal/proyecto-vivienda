#######################################################################################################
###############################   TFM VICTORIA   ###############################################
#######################################################################################################
#######################################################################################################

#IMPORTO LIBRERIAS PARA TRABAJAR
#################################

memory.limit(size = 147000)

packages_list=c("lubridate","geosphere","foreign","sp","rgdal","dplyr","maptools","rvest","MortalityTables",
                "ggmap","tmap","tmap","spdep","spatialEco","rgeos","ggplot2","mgcv","shinyjs","shinyWidgets","spgwr",
                "rsatscan","SpatialEpi","ResourceSelection","pROC","McSpatial","car","spatialprobit","raster","gbm",
                "Matrix","splines","earth","stats","party","ROCR","ROCR","leaflet","shiny","RSelenium","osmdata",
                "leaflet.extras", "RColorBrewer","smerc","vcd","gbm","AMOEBA","maptools","plotrix","data.table")

for (pkg in packages_list){
    print(paste0("check: ",pkg))
    if(!require(pkg,character.only = T)){
        print(paste0("need to install: ",pkg))
       install.packages(pkg)  }
  library(pkg,character.only = T)
}

#OTRAS FUNCIONES NUESTRAS
#########################
Descarga_OSM<-function(ciudad="Madrid, Spain",key='building',value = "hospital"){
  
    #Descargo la Iformación
  mapa1 <- opq(bbox = ciudad)
  Poligonos_dentro <- add_osm_feature(mapa1, key = key, value = value)
  df <- osmdata_sp(Poligonos_dentro)
  #Centroides de cada polígono + representación
  spChFIDs(df$osm_polygons) <- 1:nrow(df$osm_polygons@data)
  centroides <- gCentroid(df$osm_polygons, byid = TRUE)
  names<-df$osm_polygons$name
  
  #Creo los Buffers de Hospitales. En menos de 200 metros. 
  buffer <- gBuffer(centroides, byid = TRUE, width = 0.002)
  
  #Convierto en Spatial Polygon DataFrame
  buffer <- SpatialPolygonsDataFrame(buffer, data.frame(row.names = names(buffer), n = 1:length(buffer)))
  #Combino los Polígonos que se entrecruzan
  gt <- gIntersects(buffer, byid = TRUE, returnDense = FALSE)
  ut <- unique(gt); nth <- 1:length(ut); buffer$n <- 1:nrow(buffer); buffer$nth <- NA
  for(i in 1:length(ut)){
    x <- ut[[i]];  buffer$nth[x] <- i}
  buffdis <- gUnaryUnion(buffer, buffer$nth)
  
  #Combino los Polígonos que se entrecruzan otra vez.
  gt <- gIntersects(buffdis, byid = TRUE, returnDense = FALSE)
  ut <- unique(gt); nth <- 1:length(ut)
  buffdis <- SpatialPolygonsDataFrame(buffdis, data.frame(row.names = names(buffdis), n = 1:length(buffdis)))
  buffdis$nth <- NA
  for(i in 1:length(ut)){
    x <- ut[[i]];  buffdis$nth[x] <- i}
  buffdis <- gUnaryUnion(buffdis, buffdis$nth)
  
  sd<-list(centroides,buffdis,names)
  
  return(sd)
  
}
