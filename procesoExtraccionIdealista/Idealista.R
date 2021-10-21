############################ APP ANALISIS #######################################################
#################################################################################################
#################################################################################################
###################################################################################################


#Control Spatial Info Idealista
###########################

###########################################################
#
# Web Scraping en el Idealista.
#
###########################################################

library(RCurl)
library(stringr)
library(rvest)
library(httr)
library(lubridate)
library(dplyr)
library(RSelenium)
library(httpcache)
library(XML)

XC <- read.csv("Idealista/Control/control_descarga.csv", sep = ";")


#Previos ids ya encontrados
htmlFiles <- list.files(path = "Idealista/html", pattern = "*.html")
i <- 1
listado_id_html <- rep(NA, length(htmlFiles))
for (x in htmlFiles) {
  listado_id_html[i] <- as.numeric(str_split(x, "_", simplify = TRUE)[3])
  i <- i + 1
}

#Abre el navegador y devuelve el html.
#@Param: url
#@Returns: html
abrirNavegador <- function(url, browser = c("firefox")) {
  #tryCatch(
  #expr = {
  print(paste("Abriendo: ", url))
  rD <- rsDriver(verbose = FALSE, port = 4445L, check = FALSE, browser = browser)
  remDr <- rD$client
  remDr$navigate(url)
  html <- remDr$getPageSource()[[1]]

  rrnd <- as.numeric(sample(x = 10:15, size = 1))
  Sys.sleep(rrnd)

  remDr$close()
  rD$server$stop()
  system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)

  if (grepl(pattern = 'geo.captcha-delivery.com', html)) {
    stop("Ha saltado el captcha!")
  }
  #},
  #error = function(e) {
  #  system("taskkill /im javaf.exe /f", intern = FALSE, ignore.stdout = FALSE)
  #  print(paste("Ha habido un error abriendo el navegador:",e))
  #})
  return(html)
}


encuentra <- function(eso, diccionario) {
  esta = 0;
  for (palabra in diccionario) {
    esta = esta + grepl(palabra, eso) * 1
  }
  return(min(esta, 1))
}

Idlta <- function(controlDescarga, barrios = 10, maxNumeroPisosPorPagina = 30, max_paginas = 2, desktop_agents = c("firefox", "chrome"), sleepBetweenPages = 15) {

  tryCatch(
    expr = {
      #Mata procesos existentes
      system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)

      #Crea un orden aleatorio en el excel de control
      zz <- 1:nrow(controlDescarga)
      controlDescarga$IIDD <- sample(zz, nrow(controlDescarga), replace = T)
      controlDescarga <- controlDescarga[with(controlDescarga, order(IIDD)),]

      #Empieza a descargar Informacion. un x por cada barrio.
      for (x in 1:barrios) {
        #Primera URL que abre la web de Idealista por ciudad y barrio para ver cuantas viviendas hay.
        url0 <- paste0("https://www.idealista.com/venta-viviendas/", controlDescarga$ciudades[x], "/", controlDescarga$barrios[x], "/", "con-pisos/")
        html <- xml2::read_html(abrirNavegador(url0))

        ss <- html_text(html)
        b <- unlist(gregexpr(pattern = 'Explorar la zona en un mapa', ss))
        numeroPisosEnBarrio <- as.numeric(gsub("[.,\"]", "", substr(ss, b + 29, b + 33)))

        max_paginas_random <- as.numeric(sample(x = 5:max_paginas, size = 1))
        numpages <- max(min(floor(numeroPisosEnBarrio / 30) - 1, max_paginas_random), 1)
        print(paste("Número de páginas: ", numpages))

        coor <- matrix(0, 30 * numpages, 8) # Objeto que contiene la información de las viviendas. Cada pag tiene 30 viviendas
        print(paste("Registros a rellenar: ", dim(coor)[1], " Columnas: ", dim(coor)[2]))

        browser <- desktop_agents[sample(1:length(desktop_agents), 1)]

        for (j in 1:numpages) {
          #Ponemos otro sleep
          rrnd <- as.numeric(sample(x = 1:sleepBetweenPages, size = 1))
          Sys.sleep(rrnd)

          print(paste("Página: ", j, "|", "Ciudad: ", controlDescarga$ciudades[x], "|", "Barrio: ", controlDescarga$barrios[x]))

          #Segunda URL que abre la pagina en concreto
          url <- paste0("https://www.idealista.com/venta-viviendas/", controlDescarga$ciudades[x], "/", controlDescarga$barrios[x], "/con-pisos", "/pagina-", j, ".htm")
          html <- xml2::read_html(abrirNavegador(url, browser))

          #recuperamos el id y el precio de cada vivienda:
          ids <- html_nodes(html, '.item-link') #crea una lista de viviendas que aparecen en la página
          ids <- as.character(unlist(html_attrs(ids)))
          ids <- as.data.frame(ids)
          ids <- as.character(dplyr::filter(ids, grepl("inmueble", ids))$id) #cogemos los ids
          precios <- html_nodes(html, '.item-price') %>% html_text() #cogemos los precios
          print(paste("Página: ", j, "Precios: "))
          print(precios)
          precios <- gsub('[.]', '', precios)
          precios <- substr(precios, 1, nchar(precios) - 1)

          for (i in 1:min(numeroPisosEnBarrio, maxNumeroPisosPorPagina)) {

            print(paste("Página:", j, "Piso:", i))
            k <- i + maxNumeroPisosPorPagina * (j - 1)

            coor[k, 1] <- gsub("[^0-9\\.]", "", as.character(ids[i])) # identificador de la vivienda
            coor[k, 2] <- precios[i] # precio

            #validamos si el id estaba ya lo teniamos
            isIdInDBHtml <- as.numeric(as.character(coor[k, 1])) %in% listado_id_html
            print(paste("Está repetido? ", isIdInDBHtml))
            if (!isIdInDBHtml) {

              #guardamos id en variable en runtime
              listado_id_html[length(listado_id_html[]) + 1] <- as.numeric(as.character(coor[k, 1]))
              print(paste("Id añadido:",listado_id_html[length(listado_id_html[])]))

              #Tercera URL que abre la vivienda
              url2 <- paste0("https://www.idealista.com/", ids[i])
              html <- abrirNavegador(url2, browser)

              #guardar el html entero:
              code <- paste(as.character(html), collapse = "\n")
              write.table(code,
                          file = paste0("Idealista/html", "/", controlDescarga$ciudades[x], "_", controlDescarga$barrios[x], "_", coor[k, 1], "_", "piso.html"),
                          quote = FALSE,
                          col.names = FALSE,
                          row.names = FALSE,
                          fileEncoding = "UTF-8")

              html <- html_text(xml2::read_html(html))
              b1 <- unlist(gregexpr(pattern = 'Características básicas', html))
              b2 <- unlist(gregexpr(pattern = 'Ampliar mapa', html))
              eso <- substr(html, b1, b2)

              # Detalles de la vivienda:
              b <- unlist(gregexpr(pattern = 'm² construidos', eso))
              coor[k, 8] <- gsub("\n", "", substr(eso, b - 5, b - 1))

              print(paste("Id:", coor[k, 1], "|", "Precio:", coor[k, 2], "|", "Superficie en m²:", coor[k, 8]))
              print("###########################################")
            }
          }
        }
      }
    },
    error = function(e) {
      print(paste("Ha habido un error parseando el piso: ", i))
      print(e)
    }
  )
  return("fin de la extraccion")
}

Idlta(XC, barrios = 21, maxNumeroPisosPorPagina = 30, max_paginas = 10, desktop_agents = c("firefox", "chrome"), sleepBetweenPages = 60)
