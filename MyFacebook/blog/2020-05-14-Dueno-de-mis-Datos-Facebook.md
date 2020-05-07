---
layout: post
current: post
cover:  assets/blogposts/blog-011.png
navigation: True
title: Dueño de mis datos - Capítulo Facebook 
date: 2020-05-14 10:00:00
tags: [blog, Facebook, ggplot2, r, python, text-mining]
class: post-template
subclass: 'post tag-blog'
author: nerudista
---

En mi [entrada anterior](https://tacosdedatos.com/dueno-de-mis-datos-spotify) les platiqué acerca de cómo fui a pedir la información que tienen de mí las redes sociales que suelo, o solía, utilizar.

Es esta nueva serie vamos a jugar con todos los posteos que hice en Facebook y todos los comentarios que puse a posteos de otras personas. Aprovechando el gran curso de Text Mining que [@jmtoral](https://twitter.com/jmtoralc) nos dio durante la cuarentena, vamos a analizar mis textos e intentar encontrar algunas cosas interesantes. Al final, y porque nos gusta mucho, haremos gráficas y más gráficas.

¡A darle átomos!

![atomos](https://github.com/nerudista/DataViz/blob/master/MyFacebook/imagenes/atomos.jpg?raw=true)

## Consiguiendo los datos

Tus datos son precísamente eso: TUYOS. Así que cualquier servicio que uses te los debería dar cuando los pidas. 

Eso hice hace unos meses pero, por descuidado, no guardé las capturas de pantalla del proceso. Y es que, además, pedir mis datos fue la última cosa que hice antes de borrar definitivamente la cuenta que hice por allá en 2008.

Pero no todo está perdido. En   [esta página ](https://es-es.facebook.com/help/212802592074644) vienen los pasos a seguir.

Para que se den una idea de cuánto guardan de nosotros les diré que recibí 26 folders donde en cada uno pueden venir uno o varios JSON.

Aquí algunos de ellos:

![foldersim](https://github.com/nerudista/DataViz/blob/master/MyFacebook/imagenes/all_folders.png?raw=true)

Para este análisis sólo usaremos los que vienen en los folders posts y comments:

![jsons](https://github.com/nerudista/DataViz/blob/master/MyFacebook/imagenes/jsons.png?raw=true)

## Preparando los datos

Una ventaja de los JSON es que no tienen una estructura fija. Pueden contener tantos elementos como queramos. Son súper flexibles. Sin embargo, no son lo ideal para nuestro análisis.

Dado que haremos análisis de textos sólo nos interesan las cosas que escribí. Para este pequeño análisis podemos descartar muchos de los campos que vienen ahí. Vamos a quedarnos con tres: la hora de la publicación, el título de la publicación y el texto que escribí.

Empecemos con los más fáciles: los comentarios a otros posts. EL JSON viene de esta manera:

```r
{
  "comments": [
    {
      "timestamp": 1483030841,
      "data": [
        {
          "comment": {
            "timestamp": 1483030841,
            "comment": "Avisen!! Vivo a la vuelta :p",
            "author": "Pablo Quetzalc\u00c3\u00b3atl"
          }
        }
      ],
      "title": "Pablo Quetzalc\u00c3\u00b3atl coment\u00c3\u00b3 la publicaci\u00c3\u00b3n de Nata TP."
    },
    {
      "timestamp": 1476976208,
      "data": [
        {
          "comment": {
            "timestamp": 1476976208,
            "comment": "\u00c2\u00bfC\u00c3\u00b3mo no lo pens\u00c3\u00a9 antes?",
            "author": "Pablo Quetzalc\u00c3\u00b3atl"
          }
        }
      ],
      "title": "Pablo Quetzalc\u00c3\u00b3atl coment\u00c3\u00b3 la publicaci\u00c3\u00b3n de SuFa Rojbas."
    }
  ]
}
```

Lo primero que vemos es que los caracteres latinos vienen con algún enconding que tenemos que arreglar. Spoiler alert: sufriremos por novatos.

Si analizamos bien el archivo, podemos ver que el `comment` que queremos está :

- En la llave `comment`
- Dentro del diccionario `comment`
- Dentro de la lista `data`
- Dentro de la lista `comments

![comment](https://github.com/nerudista/DataViz/blob/master/MyFacebook/imagenes/comment_example.png?raw=true)

Con este código nos quedamos con los tres campos que queremos:

```python
# Creo una lista para quedarme la lista final de campos
mis_comentarios=[]

# comments son diccionarios dentro de la lista data
comments = data['comments']

# itero sobre la lista para obtener los datos de cada post
for count,element in enumerate(comments):    
    try:
        #lista para un row
        #print(count)
        comentario=[]
        if element['data']:
            j = element['data']
            l = j[0]['comment']        
            #print (element['title'])        
            comentario.append(l['timestamp'])
            comentario.append(element['title'].encode('latin1').decode('utf8'))
            comentario.append(l['comment'].encode('latin1').decode('utf8'))
        else:
            #print("error")
            comentario.append(element['timestamp'])
            comentario.append(element['title'].encode('latin1').decode('utf8'))
            comentario.append('')

        #print (comentario)
        mis_comentarios.append(comentario)
    except:
        #print ("error in : " + str(element))
        pass

with open ("./datos/misComentarios.csv", 'w',encoding='utf-8',newline='') as file:
    writer = csv.writer(file,
                        quoting=csv.QUOTE_NONNUMERIC)
    writer.writerow(["Timestamp", "Title", "Comment"])
    writer.writerows(mis_comentarios)
```
Siendo honestos exageré un poco. Yo sufrí mucho pero ustedes no tienen porqué hacerlo. La solución al encoding está en esta línea `.encode('latin1').decode('utf8')`.

Para mayor explicación pueden ver este [hilo de Twitter](https://twitter.com/nerudista/status/1252084827404279810) que hice cuando batallé con esto.

Ahora vámonos con los posts:

```r
[
  {
    "timestamp": 1509378754,
    "attachments": [
      {
        "data": [
          {
            "external_context": {
              "name": "The Strokes - I Can't Win - Listen on Deezer",
              "source": "Deezer",
              "url": "http://www.deezer.com/en/track/15591112"
            }
          }
        ]
      }
    ],
    "data": [
      
    ],
    "title": "Pablo Quetzalc\u00c3\u00b3atl escuch\u00c3\u00b3 The Strokes - I Can't Win - Listen on Deezer de The Strokes - Listen on Deezer | Music Streaming en Deezer."
  },
  {
    "timestamp": 1499345371,
    "attachments": [
      {
        "data": [
          {
            "external_context": {
              "name": "Cuentos Completos I",
              "source": "Goodreads",
              "url": "http://www.goodreads.com/book/show/1058650.Cuentos_Completos_I"
            }
          }
        ]
      }
    ],
    "data": [
      
    ],
    "title": "Pablo Quetzalc\u00c3\u00b3atl made progress with a book on Goodreads."
  },
  {
    "timestamp": 1476742550,
    "data": [
      {
        "post": "Que no se diga que los programadores, testers y BA's son solo unos gorditos buena onda.\nBusco alguien que est\u00c3\u00a9 interesado en que lo entrene para un triatl\u00c3\u00b3n. \nNo experience required. For free. \nAnybody?"
      }
    ],
    "title": "Pablo Quetzalc\u00c3\u00b3atl public\u00c3\u00b3 en Globant MX Market && Social."
  },
  {
    "timestamp": 1475510192,
    "data": [
      {
        "post": "Tarde pero seguro.\nFeliz cumplea\u00c3\u00b1os Sara."
      }
    ],
    "title": "Pablo Quetzalc\u00c3\u00b3atl escribi\u00c3\u00b3 en la biograf\u00c3\u00ada de Sara Lozano."
  }
]
```

Aquí la cosa ya se pone más coqueta porque las estructuras cambian. Los primeros dos elementos son publicaciones que dos aplicaciones hicieron en mi nombre (y que nunca les presté atención) y los últimos dos son publicaciones reales.

Miren la diferencia:

![post](https://github.com/nerudista/DataViz/blob/master/MyFacebook/imagenes/posts.png?raw=true)

Aunque la estructura cambia hay una lista que se repite. En el caso de las aplicaciones externas queda en blanco y en mis publicaciones hay una llave `post`. Con eso ya podemos jugar.

```python
# Creo una lista para quedarme la lista final de campos
list_posts=[]
error_list=[]

# El archivo es una lista de diccionarios. Voy a iterar en ella
for count, element in enumerate(posts):
    try:
        list_single_post =[]

        #asignar el title
        if element.get("title"):
            title = element['title'].encode('latin1').decode('utf8')
        else:
            title = "No Title"
        if element.get("timestamp"):
            time_stamp = element['timestamp']
        # asignar el post
        if element.get('data'):
            data_key = element.get('data')  
            #print (type(data_key))
            for key in data_key:
                if key.get('post') :
                    #print(key)
                    post = str(key.get('post')).encode('latin1').decode('utf8')

                    list_single_post.append(time_stamp)
                    list_single_post.append(title)
                    list_single_post.append(post)

                    list_posts.append(list_single_post)

    except Exception as e: # work on python 3.x
        print(e)

with open ("./datos/misPosts.csv", 'w',encoding='utf-8',newline='') as file:
    writer = csv.writer(file,
                        quoting=csv.QUOTE_NONNUMERIC)
    writer.writerow(["Timestamp", "Title", "Comment"])
    writer.writerows(list_posts)
```
¡ Y listo! Ya tenemos dos archivos CSV con los datos que vamos a ocupar.

## ¿Y los bocetos?
Esta vez rompí mi regla de crear bocetos en papel y es que me enfoqué más en poder hacer los análisis y no tenía una idea de qué me iba a encontrar y por ende no sabía qué y cómo graficar.

Disculpen la omisión. Les prometo que lo que se viene lo compensa.

## Creando mi _theme_

Crear un theme ayuda a simplificar el código que tenemos que escribir para cada gráfica. Para este caso conseguí los códigos de colores que usa Spotify en su aplicación y el font más parecido al que usaban en su versión anterior. El de la nueva ya tenía costo así que por economía nos veremos _oldies but goodies_

Este es el código para el theme que utilizaremos:

```r
#theme
#colors
# 1db954, 1ed760, ffffff, 191414

theme_spoty <- theme(
    #Esto pone negro el titulo , los ejes, etc
    plot.background = element_rect(fill = '#191414', colour = '#191414'), 
    #Esto pone negro el panel de la gráfica, es decir, sobre lo que van los bubbles
    panel.background = element_rect(fill="#191414",color="#191414"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    text = element_text(color = "#1db954",
                        family="Gotham"   #esta es la fuente que instalé en mi lap
    ),
    # limpiar la gráfica
    axis.line = element_line(colour="#191414"),
    axis.title=element_blank(),
    axis.text=element_blank(),
    axis.ticks=element_blank(),
    # ajustar titulos y notas
    plot.title = element_text(size=32,
                              color="#1db954"),
    plot.subtitle = element_text(size=20,
                              color="#1db954"),
    plot.caption = element_text(
      color="#1db954",
      face="italic",
      size=13
    ),
    complete=FALSE
  )

```

Esta vez aprendí la diferencia entre el `plot.background` y `panel.background`. El panel es el espacio donde se pintan las figuras y el plot abarca el espacio del título, los ejes y el caption.

Fuera de eso, lo demás es limpieza de ejes y asignar fuentes y colores. Anímense a cambiar los valores para que vean como cambia su gráfica.

## Importando los datos

Como recibí tres archivos con los datos de streaming tenemos que importarlos y después unirlos. Eso se hace bien fácil con:

```r
#importar json como dataframe
df0 <- fromJSON("./Data/StreamingHistory0.json")
df1 <- fromJSON("./Data/StreamingHistory1.json")
df2 <- fromJSON("./Data/StreamingHistory2.json")

#Unir los dataframes
data <- rbind(df0,df1,df2)

#Cargar la fuente desde mi Windows 
windowsFonts(`Gotham` = windowsFont("Gotham"))
```
Al final cargo la fuente que voy a utilizar para las gráficas. Como tengo Windows sólo descargué la fuente de un sitio de internet y luego hice _drag and drop_ a mi pantalla de Font Settings. Una vez instalada la fuente en Windows ya puedo usarla en R con ese comando.

## Historical Bubble Chart

No sé si se llame así pero me gusta el nombre. Lo que vamos a hacer es graficar verticalmente bubbles que tendran como _encoding_ el mes de reproducción en la posición y el tamaño para los minutos de reproducción. Es decir, algo así:

![bubbles](https://github.com/nerudista/DataViz/blob/master/MySpotify/MySpotify/graficas/TopMensual.png?raw=true)

Antes de ver el código intentemos desmenuzar la gráfica para saber qué es lo que tenemos que hacer.

Cada circulo representa el artista que más escuché en el mes. Esto significa que tengo que agrupar el tiempo reproducido de cada canción por artista y por mes y luego sacar el top 1 de cada mes. Algo así:

```r
dfArtistaMes <- data %>% 
  group_by(mesAño,artistName)%>% 
  summarise(minutosMes= round((sum(minPlayed)))) %>% 
  top_n(1)  #me da el top1 de cada grupo creado arriba
```

Intentemos pensar en las capas que necesitamos para crear la gráfica:

1. Una capa para las burbujas. Estan van ordenadas en el mismo punto X pero ordenadas cronológicamente, de arriba hacia abajo, en el eje Y.
2. Una capa para los textos de la derecha: mes-año.
3. Una capa para los textos de la derecha: artista más escuchado por mes.
4. Una capa para los textos de la derecha: minutos.
5. Una capa para la línea blanca que atraviesa las bolitas para dar idea de continuidad (_conque aplicando Teoría Gestalt eh?_).

El código para crear estas capas fue:

```r
plotArtistaMes <-ggplot(data=dfArtistaMes,
       aes( x=1, 
            y=reorder(mesAño, desc(mesAño))  #ordenar ascendente el mesAño 
       )
       )+
  geom_point( aes(                    #Capa 1
                  size=minutosMes, 
                  color=artistName),
              show.legend = FALSE,
              alpha = 1
              )  +
  geom_text(aes(x=1.06,label=mesAño), #Capa 2
            color="#FFFFFF",
            family="Gotham",
            size=6,
            hjust="left")+
  geom_text(aes(x=.94,                #Capa 3
                label=artistName,
                color=artistName),
            family="Gotham",
            size=6,
            show.legend = FALSE,
            hjust="right")+
  geom_text(aes(x=.94, label=paste(minutosMes,"m")),   #Capa 4
            hjust="right",
            size=6,
            color="#FFFFFF",
            family="Gotham",
            vjust=1.8)+
  geom_line(data=data.frame(x=c(1,1),y=c(1,13)),     #Capa 5
            aes(x=x, y=y),
            alpha=0.4,
            size=.85,
            color="#FFFFFF",
            linetype = "dotted")+
  scale_x_discrete(limits=c(1))+
  scale_radius(range = c(4, 26))+
  scale_color_brewer(palette="Dark2")+
  labs(title="Mi Spotify en el Último Año",
       subtitle="Minutos escuchados por artista",
       caption="Hecho por @nerudista con datos de Spotify") +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )+
  theme_spoty  ; plotArtistaMes
```

Para esta gráfica no busqué en internet cómo hacerla sino que me imaginé cómo armarla desde cero. Si usteden encuentran una mejor opción, ¡compartanla!.

Lo que hice fue poner todas las burbujas en el valor `x=1` y para las capas de los textos le resté, o sumé, algunas centésimas para ponerlas a la derecha o la izquierda. Después ya es cosa de poner título, subtítulo  y caption. Centrar los primeros dos y aplicar el _theme_.

Bueno, ya que estamos con burbujas intentemos hacer algo más coqueto.

## _Circle Packing_ para mostrar cada canción escuchada

Desde hacía buen rato había querido hacer un treemap pero en burbujas. _Circle Packing_ le llaman.

Esta es la gráfica que haremos:

![circlePacking](https://github.com/nerudista/DataViz/blob/master/MySpotify/MySpotify/graficas/SingleBubble.png?raw=true)

Lo que intento visualizar es qué canciones escuché por más tiempo durante el último año. Para esto voy a poner el tamaño de la burbuja como _encoding_ y el color será diferente por cada canción. 

Esta vez tenemos que agrupar no por artista ni por mes sino por canción en todo el año:

```r
dfCanciones <- data %>%
  group_by(artistName,trackName) %>%
  summarise(min=sum(minPlayed))%>%
  filter (min > 5)

```
Vamos a necesitar una nueva #BibliotecasNoLibreria para crear esta visualización:


```r
#install.packages("packcircles")
library("packcircles")


```
Ya con el data frame agrupado por cancion, vamos a meter la canción (_trackName_) a la función `circleProgressiveLayout` para que nos cree un nuevo dataframe con la posición x,y y el radio de cada burbuja:


x | y | radio
---------|----------|---------
 -1.34224959 | 0.00000000 | 1.342250
 1.95766469 | 0.00000000 | 1.957665
 ... | ... |...
 5.05310636 | 4.81689588 | 2.509851

Después hay que meter ese nuevo data frame a la función `circleLayoutVertices`:

```r
# los npoints dicen las caras de la figura 3-triangulo, 4-cuadrado
# con el 50 ya se parece a un círculo
dat.gg <- circleLayoutVertices(packing, npoints=50)
```

Lo que queda es ya crear la gráfica:

```r
plotSingleBubble <- ggplot()+
  # Make the bubbles
  geom_polygon(data=dat.gg, aes(x,
                                y,
                                group=id,
                                colour = "black",
                                alpha = 0.6,
                                fill=as.factor(id)
                                )
               ) +
  scale_size_continuous(range = c(1,5)) +
  labs(title="Un Universo de Música",
       subtitle="Minutos de reproducción por canción ",
       caption="Hecho por @nerudista con datos de Spotify") +
  scale_color_brewer(palette="Dark2")+
  #theme_void()+
  theme_spoty+
  theme(legend.position="none") +
  coord_equal(); plotSingleBubble

```

Poquito código y queda algo bonito. Sin embargo no me dice qué canción escuché más ni cuántos minutos escuché cada uno. No pintamos texto sobre las burbujas porque o no cabe o es tanto texto que tapa las figuras.

¿Y si cuando pase el mouse me dijera qué canción es y cuánto la escuché? Eso ya sería hacer algo interactivo. Y pues ...

## _Circle Packing_ interactivo

Primero vamos a importar la biblioteca para la parte interactiva. Luego toca crear una columna nueva en el data frame con el texto que queremos desplegar:

```r

#install.packages("ggiraph")
library(ggiraph)

# Add a column with the text you want to display for each bubble:
dfSimpleBubble$text <- paste("Canción: ",dfSimpleBubble$dfCanciones.trackName, "\n", "Min:", dfSimpleBubble$dfCanciones.min)
```
Lo que sigue es crear de nuevo la gráfica de burbujas pero agregando el tooltip con la línea:
`tooltip= dfSimpleBubble$text[id]`:

```r
plotSingleBubbleInter <- ggplot()+
  geom_polygon_interactive(data=dat.gg,
                           aes(x,y,
                               group=id,
                               fill=as.factor(id),
                               tooltip= dfSimpleBubble$text[id],
                               family="Gotham",
                               data_id = id),
                           colour = "black", alpha = 0.6)+
  theme_spoty +
  scale_color_brewer(palette="Dark2")+
  theme(legend.position="none") +
  labs(title="Un Universo de Música",
       subtitle="Minutos de reproducción por canción ",
       caption="Hecho por @nerudista con datos de Spotify") +
  coord_equal()

widg <- ggiraph(ggobj = plotSingleBubbleInter, width_svg = 6, height_svg = 9)

```

Ya con la gráfica construido hay que pasarla por `ggiraph` para que cree la parte interactiva. El resultado de esto es un archivo html con su respectiva carpeta que contiene los archivos necesarios para crear la visualización web. Si revisan el código van a darse cuenta que usa javascript por debajo para construir la visualización. ¡Un pasito más cerca de D3!

Vean nomás qué chulada queda:

![interactive_bubble](https://github.com/nerudista/DataViz/blob/master/MySpotify/MySpotify/imagenes/interactive_bubble.png?raw=true)
<div id="htmlwidget_container">
    <div id="htmlwidget-8bb1dcfd60108c6f90b8" class="girafe html-widget" style="width:960px;height:500px;">
    </div>
</div>

De mis pendientes quedan poder poner color por artista y no por canción. Tengo que agarrarle más la onda a las funciones de los vértices para poder tener en el data frame alguna variable por artista que me deje hacer el fill por ese nuevo campo y no por `id`.

## Lollipops 

Y ya para acabar con los `geom_points()` haremos una grafica de ¿paleta?. No sé cómo le digan en español pero en inglés les dicen _lollipop_.

Empecemos viendo el resultado final para desmenuzarla de nuevo:

![top5](https://github.com/nerudista/DataViz/blob/master/MySpotify/MySpotify/graficas/plotTop5.png?raw=true)

La gráfica muestra los 5 artistas más escuchados e inmediatamente después muestra qué canción, de ese artista, fue la más escuchada. Ojo aquí, no es el top 5 de artistas y el top 5 de canciones. Es el top 5 de artistas con su respectiva canción más reproducida. Este pequeño detalle me hizo darle varias vueltas a la solución. 

Lo primero es crear los data frames para tener los artistas y las canciones:

```r
#Crear data frame con el tiempo total por cada canción junto con el artista.
#Necesito el artista para filtrar más adelante.
dfCanciones <- data %>%
  group_by(artistName,trackName) %>%
  summarise(min=sum(minPlayed))%>%
  filter (min > 5)


# Crear df el top n de artistas por minutos reproducidos en el año
dfArtistaAnio <- data%>%
  group_by(artistName)%>%
  summarise(min=sum(minPlayed)) %>%
  top_n(5)%>%   # de una vez me quedo con el top 5
  arrange(min)  # ordeno ya encarrerado el ratón

```

Ya con ambos dataframes voy a crear uno nuevo, basado en `dfCanciones`, donde esté agrupado por `artistName`.  No le voy a poner que sumarise nada sólo quiero la estructura del `group by` para aplicarla en el siguiente paso. 

Sigue crear el df `dfTopCanciones` que es el resultado de tomar el top 1 del df `artistas` para finalmente hacerle merge al df `dfArtistaAnio`. Al final nos quedan los 5 artistas más escuchados con su respectiva canción.

Sé que suena enredado pero solo son 3 comandos. Muévanle a esos tres para que vean que resultados diferentes les dan para que tenga cierta lógica:

```r
# crear un df con el group by solo por artistName 
artistas <- dfCanciones %>% group_by(artistName)

# filtrar el df artistas tomando el registro con más minutos. Va inverso porque no hay max_rank()
# sino min_rank(). Solo tomo un row: el más alto
dfTopCanciones <- filter(artistas, min_rank(desc(min)) <= 1 )

# hago un join entre el df dfArtistaAnio y dfTopCanciones por artistName
# así solo me quedan los top artistas con su canción más escuchada
dfCancionesArtistasTop <- merge(x=dfArtistaAnio, y=dfTopCanciones, by="artistName", all.x = TRUE)
```

La salida del último df es:

artistName | min.X | trackName | min.Y
---------|----------|---------|---------
 Arcade Fire | 1993.59 | The Suburbs | 224.74
 Gallina Pintadita | 1781.42 | Hormiguita | 153.22

Hasta ahí parece que vamos bien pero ¿cómo usamos esta salida para graficar? Podría usar dos capas donde en el primer `aes(x= ?)` use `artistName` y en la otra el `trackName`. Sin embargo, cuando junte las capas el orden se me rompe.

Como todo en esta vida hay más de una forma de solucionar las cosas y la que se me ocurrió fue generar esta salida:

item | min | type |
---------|----------|---------|
 Arcade Fire | 1993.59 | A |
 Gallina Pintadita | 1781.42 | A |
 ... | ... | ... |
 The Suburbs | 224.74 | C

 Donde el `ìtem` es la canción o el artista, `min` los minutos reproducidos y en `type` "C" si es canción y "A" si es artista. Esta variable es importante para poder hacer formato condicional dentro de la misma capa. Con este df ya no necesito hacer dos capas sino una sola condicionando la salida por el tipo de item.

 Este es el código para crear la salida que buscamos:

```r
 dfTemp1 <- data.frame( item = dfCancionesArtistasTop$artistName,
                                          min = dfCancionesArtistasTop$min.x,
                                          type = "A")%>% arrange(-min)

# manualmente pongo el orden en que quiero que aparezcan los artistas
dfTemp1$order <- c(1,3,5,7,9)


dfTemp2 <- data.frame( item = dfCancionesArtistasTop$trackName,
                       min = dfCancionesArtistasTop$min.y,
                       type = "C")

# manualmente pongo el orden en que quiero que aparezcan las canciones
dfTemp2$order <- c(2,6,8,4,10)

dfCancionesArtistasTopList=rbind(dfTemp1,dfTemp2)
```

Noten que también creamos una columna con el orden en específico en que queremos que aparezcan los items. Como eran pocos registros lo hice manual. Si fueran mcuhos más, toca pensar como hacerlo en automático.

Intentemos dibujar la gráfica desde la gramática de gráficos:

1. Una capa para las líneas del _lollipop_.
2. Una capa para el círculo de la paleta.
3. Una capa para los textos (minutos escuchados).
4. LA capa de título, subtítulo, etc.

Con esto en mente es más fácil saber qué construir:

```r
#ahora a pintar la gráfica
plotTop5 <- ggplot(data=dfCancionesArtistasTopList,
       aes(x=item,
           y=min
       ))+
  geom_segment(data=dfCancionesArtistasTopList ,
               aes(x=reorder(item,-order),
                   xend=item,
                   y=0,
                   yend=min
                   ),
               color=ifelse(dfCancionesArtistasTopList$type=="A","#67A61F","#E72A8A"),
               size=2
               )+
  geom_point(
             color=ifelse(dfCancionesArtistasTopList$type=="A","#67A61F","#E72A8A"),
             size=7
  )+
  geom_text(aes(label=paste(round(min,0)," min")),
            color=ifelse(dfCancionesArtistasTopList$type=="A","#67A61F","#E72A8A"),
            size=4,
            #color="#FFFFFF",
            family="Gotham",
            nudge_x = -.3)+
  coord_flip()+
  scale_color_brewer(palette="Dark2")+
  ylab("")+
  xlab("")+
  theme(legend.position="none") +
  labs(title="Top 5 de Artistas",
       subtitle="Con su canción más escuchada",
       caption="Hecho por @nerudista con datos de Spotify") +
  theme(
    text = element_text(color = "#1db954",
                        family="Gotham"
    ),
    #Esto pone negro el titulo , los ejes, etc
    plot.background = element_rect(fill = '#191414', colour = '#191414'), 
    #Esto pone negro el panel de la gráfica, es decir, sobre lo que van los lollipops
    panel.background = element_rect(fill="#191414",color="#191414"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size=32,
                              color="#1db954"),
    plot.subtitle = element_text(size=20,
                                 color="#E72A8A"),
    plot.caption = element_text(
      color="#1db954",
      face="italic",
      size=13
    ),
    axis.text=element_text(family = "Gotham",
                           size=13,
                           color="#FFFFFF"),
    axis.ticks=element_blank(),
    axis.text.x = element_blank(),
  );plotTop5

```
Noten dos cosas:

1. El uso el `ifelse` con la variable `type` que creamos. Podemos jugar con el color dependiendo de si es canción o artista.
2. No apliqué mi _theme_ porque en él desaparezco las leyendas de los ejes y aquí los necesito para mostrar el nombre de la canción y el artista sobre el eje Y. Además, quería mostrarles la diferencia entre un `+theme_spoty` y tooooodo lo que tuve que poner para arreglar la gráfica. ¿Ven porqué están chidos los _themes_?

## Comentarios finales

Después del ejercicio de los [Pats](https://tacosdedatos.com/primeros-pasos-con-ggplot-y-altair) intenté hacer cosas nuevas usando bibliotecas nuevas. No le tengan miedo. Anímense. Poco a poco irán saliendo cosas mejores. La cosa es no dejar de aprender.

Por otro lado, los aliento a ir pos sus datos a todas las plataformas en las que estén inscritos. Son sus datos y tienen derecho a saber qué conocen de ustedes. En Spotify no encontré nada especial pero en otros servicios sí me he ido para atrás con lo que han colectado de mí. Cultivemos una cultura de la responsabilidad de los datos. Son parte de nustra vida.

Por último, les recuerdo que este año Github está duplicando las donaciones que le hagan a [@tacosdedatos](https://github.com/sponsors/chekos). Con esa lana se puede pagar un chorro de cosas para mantener el sitio arriba y hasta para rifar uno que otro libro, si se junta la lana. Un dolar al mes es menos que una cerveza al día. ¿Ah, verdad?

## Recursos

Para esta entrada usé muchísimo la página [Data to Viz](https://www.data-to-viz.com/). Ahí van a encontrar chorro de ejemplos en R, Python y hasta en otras herramientas. 

El repo con el código está en:

[https://github.com/nerudista/DataViz/tree/master/MySpotify](https://github.com/nerudista/DataViz/tree/master/MySpotify)

Enren a verlo poque hay código que no puse en el blog y que en necesario para que las gráficas funcionen. Ya saben, cosa de economía para que el blog no se haga eterno y lo boten a media lectura.

***

¿Qué te pareció la nota? [Mandanos un tuit a @tacosdedatos](https://twitter.com/share?text=Obvio+que+estuvo+super+el+blog+%40tacosdedatos+%F0%9F%8C%AE) o [a @nerudista](https://twitter.com/share?text=Obvio+que+estuvo+super+el+blog+%40tacosdedatos+y+%40nerudista+%F0%9F%8C%AE) o envianos un correo a [✉️ sugerencias@tacosdedatos.com](mailto:sugerencias@tacosdedatos.com?subject=Sugerencia&body=Hola-holaaa). Y recuerda que puedes subscribirte a nuestro boletín semanal aquí debajo.

