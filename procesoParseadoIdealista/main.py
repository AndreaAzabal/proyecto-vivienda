import codecs
import pandas as pd
import re
import glob
from lxml import html

#Define parser
STRING_VACIO = ""
SEPARADOR_MILES = "."

colnam = ["id", "price", "lon", "lat", "precio metro", "planta", "construccion", "metros", "habitaciones", "baths", "terraza", "ascensor",
            "aire", "exacta", "garaje", "piscina", "zonas verdes", "trastero", "armarios", "buen estado", "reformar", "obra nueva", "exterior",
            "balcon", "chalet", "atico", "duplex", "estudio", "piso", "calle", "distrito"]

def contiene(textHtml, diccionario):
    return diccionario.upper() in textHtml.upper()

def encontrarUnNumero(line):
    numList = re.findall("-?\d+", line)
    if len(numList) > 0:
        return numList[0]

def encontrarNumeroPorLinea(textHtml, diccionario):
    for line in textHtml.splitlines():
        if contiene(line,diccionario):
            return encontrarUnNumero(line)

def getPrimerElemento(iterador):
    for elemento in iterador:
        return elemento

#readFiles
#htmlFiles = glob.glob("html\muestra\*.html")
htmlFiles = glob.glob("html\*.html")
pisos = [[0 for x in range(len(colnam))] for y in range(len(htmlFiles))]
errores = []

#Parser:
i = 0
for x in htmlFiles:

    try:
        #Leer fichero:
        print("Leyendo piso: " + x)
        file = codecs.open(x, "r", "utf-8")
        html_text = file.read()
        tree = html.document_fromstring(html_text)

        #Ids, precio etc
        pisos[i][0] = encontrarUnNumero(getPrimerElemento( tree.xpath("//*[@rel='canonical']") ).get('href'))
        pisos[i][1] = encontrarUnNumero(getPrimerElemento(tree.xpath("//*[@class='price-container']")).text_content().replace(SEPARADOR_MILES,STRING_VACIO))
        pisos[i][2] = re.search("longitude: '(.*?)'", tree.text_content()).group(1)
        pisos[i][3] = re.search("latitude: '(.*?)'", tree.text_content()).group(1)

        #parser características
        caracteristicas = getPrimerElemento(tree.xpath("//*[@class='details-property-feature-one']")).text_content()
        pisos[i][6] = encontrarNumeroPorLinea(caracteristicas, "construido en")
        pisos[i][7] = encontrarNumeroPorLinea(caracteristicas, "construidos")
        hab = encontrarNumeroPorLinea(caracteristicas, "habitaci")
        pisos[i][8] = 0 if hab is None else hab
        baths = encontrarNumeroPorLinea(caracteristicas, "baño")
        pisos[i][9] = 0 if baths is None else baths
        pisos[i][10] = int(contiene(caracteristicas, "terraza"))
        pisos[i][14] = int(contiene(caracteristicas, "Plaza de garaje incluida"))
        pisos[i][17] = int(contiene(caracteristicas, "Trastero"))
        pisos[i][18] = int(contiene(caracteristicas, "Armarios empotrados"))
        pisos[i][19] = int(contiene(caracteristicas, "buen estado"))
        pisos[i][20] = int(contiene(caracteristicas, "para reformar"))
        pisos[i][21] = int(contiene(caracteristicas, "obra nueva"))
        pisos[i][23] = int(contiene(caracteristicas, "Balcón") | contiene(caracteristicas, "Balcon"))

        caracteristicas2 = getPrimerElemento(tree.xpath("//*[@class='details-property-feature-two']")).text_content()
        planta = encontrarNumeroPorLinea(caracteristicas2, "Planta")
        pisos[i][5] = planta if planta is not None else 0 if contiene(caracteristicas2, "Bajo") | contiene(caracteristicas2, "Entreplanta") else None
        pisos[i][11] = int(contiene(caracteristicas2, "con ascensor"))
        pisos[i][12] = int(contiene(caracteristicas2, "aire acondicionado"))
        pisos[i][15] = int(contiene(caracteristicas2, "Piscina"))
        pisos[i][22] = int(contiene(caracteristicas2, "exterior"))
        pisos[i][16] = int(contiene(caracteristicas2, "Zonas verdes"))

        #Tipo
        titulo = getPrimerElemento(tree.xpath("//*[@class='main-info__title-main']")).text_content()
        pisos[i][24] = int(contiene(titulo, "Chalet"))
        pisos[i][25] = int(contiene(titulo, "Ático") | contiene(titulo, "atico"))
        pisos[i][26] = int(contiene(titulo, "Dúplex") | contiene(titulo, "Duplex"))
        pisos[i][27] = int(contiene(titulo, "Estudio"))
        pisos[i][28] = int(contiene(titulo, "Piso"))
        pisos[i][13] = int(getPrimerElemento(tree.xpath("//*[@class='no-show-address-feedback-text']")) is None)
        pisos[i][29] = getPrimerElemento(tree.xpath("//*[@class='main-info__title-main']")).text_content()
        pisos[i][4] = int(int(pisos[i][1]) / int(pisos[i][7]))
        pisos[i][30] = x.split("_")[1]

    except Exception as e:
        print("Hemos fallado al parsear: " + x)
        print(e)
        errores.append(x)

    finally:
        #cambiamos de piso:
        i = i + 1

#Guardar los datos transformados:
df = pd.DataFrame(pisos, columns=colnam)
df.to_csv("IdealistaDepurado.csv", index=False, encoding='utf-8')

#print errores:
print("Pisos en los que ha habido error: \n ", errores)
