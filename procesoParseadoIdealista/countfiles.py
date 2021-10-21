import pandas as pd
import glob

colnam = ["Ciudad", "Municipio", "id"]
#readFiles
htmlFiles = glob.glob("html\*.html")
pisos = [[0 for x in range(len(colnam))] for y in range(len(htmlFiles))]
#Parser:
i = 0
for x in htmlFiles:
    splitted = x.split("_")
    if (len(splitted) > 3):
        pisos[i][0] = splitted[0]
        pisos[i][1] = splitted[1]
        pisos[i][2] = splitted[2]
        i = i + 1

df = pd.DataFrame(pisos, columns=colnam)
print(df['Municipio'].value_counts())