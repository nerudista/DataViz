---
title: "Primeros pasos con ggplot (R) y Altair (Python)"
output: html_document
---

# Primeros pasos con ggplot (R) y Altair (Python)

Hace un par de meses, mientras veía el partido de los Pats contra los Cowboys, un tuitero famosón mencionó que a los Pats siempre los benefician los arbitros. Por esas fechas leía un libro sobre sesgos cognitivos y pensé que tal vez habría un tanto de eso con los Pats. Así que me decidí jugar un poco con los datos para ver qué encontraba.

Tenía rato que quería hacer gráficas con ggplot en R y con Altair en Python ya que ambas usan la _gramática de la visualización_ para crear sus gráficas. Además, tengo poca experiencia con Python y R por lo que consideré que sería un gran reto armar algo desde cero y visualizarlo usando ambas bibliotecas para poder tener un punto de comparación.

En este artículo intentaré explicar cómo fue mi proceso creativo y de codificación. Como mencioné previamente soy principiante en ambas herramientas. Por favor ten en mente que este es mi acercamiento inicial a estas herramientas. No intento dar un manual de cómo se deben hacer las cosas sino abrir la conversación acerca de cómo perderle el miedo a jugar con los datos, los retos que afronté y las cosas que no logré completar.

Dicho esto, a darle que es mole de olla.

## Armando el dataset

Como quería analizar cosas objetivas y no subjetivas, me decidí por hacer un análisis de los castigos a favor y en contra de los Pats.

Después de buscar en internet no encontré un dataset con todos los datos que quería: saber el resultado del partido, quién lo ganó, el _quarter_ con su minuto y segundo cuando el castigo fue cometido, si fue castigo ofensivo o defensivo o si ese año fueron campeones los Pats, entre otras cosas. Así que me di a la tarea de buscar alguna API de Python que me dejara ver jugada a jugada los partidos de los Pats. Me encontré con la API [**nflgame**](http://nflgame.derekadair.com/)
que me daba justo lo que quería. El único pero es que sólo tiene info desde el 2009 pero consideré que 10 años era un buen período para analizar.

Si bien la API tiene clases y métodos para dar información sumarizada, tuve que entrar a ver cómo estaban construidas algunas clases para sacar el detalle de jugadas y no el resumen de ellas. Como el paradigma de objetos me saca ronchas tardé como una semana en poder entender cómo funcionaba pero al final obtuve un dataset de este tipo:


id|season|home|away|week|score_home|score_away|winner|loser|team_possesion|field_position|...|team_possesion_cat|team_penalty_cat|penalty_side|opportunity|yards_to_go|week_type|one_posession_game|pats_points|opps_points|game_winner_cat
---------|----------|------------------|----------|------------------|----------|------------------|----------|------------------|----------|------------------|----------|------------------|----------|------------------|----------|------------------|----------|------------------|----------|---------|---------
0|2009|NE|BUF|1|25|24|NE|BUF|BUF|BUF 43|...|Oponente|Oponente|Castigo Ofensivo|3.0|7.0|1|Juego de una posesión|25|24|NE
1|2009|NE|BUF|1|25|24|NE|BUF|NE|NE 30|...|NE|NE|Castigo Ofensivo|2.0|8.0|1|Juego de una posesión|25|24|NE
2|2009|NE|BUF|1|25|24|NE|BUF|NE|NE 45|...|NE|Oponente|Castigo Defensivo|1.0|10.0|1|Juego de una posesión|25|24|NE
3|2009|NE|BUF|1|25|24|NE|BUF|BUF|BUF 48|...|Oponente|NE|Castigo Defensivo|1.0|10.0|1|Juego de una posesión|25|24|NE
4|2009|NE|BUF|1|25|24|NE|BUF|BUF|NE 43|...|Oponente|Oponente|Castigo Ofensivo|2.0|1.0|1|Juego de una posesión|25|24|NE
5|2009|NE|BUF|1|25|24|NE|BUF|NE|NE 26|...|NE|Oponente|Castigo Defensivo|4.0|16.0|1|Juego de una posesión|25|24|NE


El código para replicar la obtención del dataset lo encuentran aquí:

https://github.com/nerudista/DataViz/blob/master/Pats/get_pats_data.ipynb

## A graficar se ha dicho

Como todo principiante me emocioné y empecé a leer blogs y documentacion de **ggplot** para empezar a visualizar. Ahí perdí como 3 días porque me ocupé más en _**cómo**_ visualizar y no en _**qué**_ visualizar.

Regresando a lo que mandan los cánones tomé papel y lapiz y me puse a tirar ideas y bocetos de qué quería comunicar. Este es un ejemplo:

![https://github.com/nerudista/DataViz/blob/master/Pats/ideas/boceto1.png?raw=true](https://github.com/nerudista/DataViz/blob/master/Pats/ideas/boceto1.png?raw=true)

Perdón por los jeroglíficos. El pdf con las demás ideas está aca:

https://github.com/nerudista/DataViz/blob/master/Pats/ideas/Pats%20an%C3%A1lisis%202019-12-15.pdf


## Creando _themes_

Durante los días que di batazos de ciego encontré un gran [artículo](https://towardsdatascience.com/consistently-beautiful-visualizations-with-altair-themes-c7f9f889602) del buen tacos de datos acerca de crear plantillas de diseño para darle agilidad y consistencia a la creación de gráficas.

Estas plantillas se llaman _themes_ y pueden crearse tanto para ggplot como para Altair.

Este es el que creé para **ggplot**:

```r
theme_pats_white <- theme(
  
  text=element_text(size=12,
                    family="mono",
                    color="#002145"),
  # limpiar la gráfica
  axis.ticks = element_blank(),
  # ajustar titulos y notas
  plot.title = element_text(size=20,
                            #family = "mono",
                            color="#08415C"
                            ),
  plot.caption = element_text(
                            color="#08415C",
                            face="italic",
                            size=6
                            ),
  # Hide panel borders and remove grid lines
  panel.border = element_blank(),
  panel.grid.major = element_blank(),
  panel.background= element_blank(),
  panel.grid.minor = element_blank(),
  
  # legend color
  legend.background = element_rect(fill='#FFFFFF'),
  #legend.position = "top",
  legend.text = element_text(
    color="#08415C"), 
  legend.key = element_rect(fill="#FFFFFF"),     #quita el color gris de la línea de castigos  
  legend.spacing.x = unit( 1,"cm"),
  legend.box.margin = margin(.5, .5, .5, .5, "cm"),
  complete = FALSE
  )

```

Y acá el de **Altair**:

```py
def theme_pats_white():
    # Typography
    font = "Courier",
    labelFont = "Courier" 
    sourceFont = "Courier"
    fontColor = "#08415C"    #Blue Pats
    
    # Axes
    axisColor = "#000000"
    gridColor = "#DEDDDD"
    
    # Colors
    main_palette = ["#08415C", 
                    "#B0B7BC",
                   ]
    
    return{        
        'config':{            
            "title": {
                "fontSize": 22,
                "font": font,
                "anchor": "middle", # equivalent of left-aligned.                
                "color": fontColor,
            },
            "axisX": {
                "labelFont": labelFont,
                "titleFont": font,
                "titleFontSize": 12,
                "titleColor" : fontColor,
                "titleFontSize": 18,
                "grid": False,
                
            },
            "axisY": {
                "axis":None,
                "labelFont": labelFont,
                "labelFontSize": 12,
                "titleFont": font,
                "titleColor" : fontColor,
                "titleFontSize": 16,
                "grid": False,
                "ticks": False,
                "labels":False,
                
            },
            "legend": {
                "labelFont": labelFont,
                "labelFontSize": 12,
                "titleFont": font,
                "titleFontSize": 12,
                #"titleColor" : fontColor,
                "orient": "top",
                "title": None,
                #"labelAlign":"center",
            },
            "range": {
                "category": main_palette,             
            },
            "view": {
                "stroke": "transparent", # altair uses gridlines to box the area
                                         #where the data is visualized. This takes that off.
            },
            "facet":{
              "spacing":20,  
            },
            "header":{
              "labelColor": fontColor,  
              #"labelFont": labelFont,
              "labelSize" : 10
            },

        }
    }


alt.themes.register('my_custom_theme', theme_pats_white)
alt.themes.enable('my_custom_theme')
```

Ambos básicamente limpian los ejes y el grid (cuadriculado de fondo), especifican la paleta de colores que voy a usar, la tipografía y las _legends_ que se usan en las gráficas.

Yo vengo del mundo de BI por lo que el formato JSON me es muy familiar. Sin embargo me gustó mucho la sintaxis de **R**. Me parece muy limpia y ocupa menos espacio. Prácticamente ocupé 100 líneas menos para conseguir algo similar.



---------------
 Seguramente hay formas más eficientes de realizar lo que se va a mostrar aquí o incluso de completar algunas tareas que no pude finalizar porque ya de plano no encontré documentación o ejemplos que me pudieran ayudar. 
