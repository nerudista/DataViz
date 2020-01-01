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

En total, haciendo apróx. una hora diaria, me tarde como 10-12 días en poder tener el código que me servía. ¿Cosas que aprendí? Listas, funciones, lambdas y más pandas.

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

## Castigos Ofensivos y Defensivos

Decidí hacer una _bar plot_ para mostrar las  yardas promedio históricas por tipo de castigo.

Empecemos viendo el resultado en ambas bibliotecas.

![https://github.com/nerudista/DataViz/blob/master/Pats/graficas/R/RplotCastigosOfensivos.png?raw=true](https://github.com/nerudista/DataViz/blob/master/Pats/graficas/R/RplotCastigosOfensivos.png?raw=true)


![https://github.com/nerudista/DataViz/blob/master/Pats/graficas/Altair/AltairCastigosOfensivos.png?raw=true](https://github.com/nerudista/DataViz/blob/master/Pats/graficas/Altair/AltairCastigosOfensivos.png?raw=true)

En ambos casos tuve que crear un dataframe ya que agrupe por varios campos y obtuve el promedio de yardas. El código es similar en ambos lenguajes:
R:
```r
df_yds_totales <-data %>%
  group_by(game_winner_cat,team_penalty_cat,penalty_side,season,week) %>%
  summarise(sum_yds=sum(penalty_yards)) %>%
  group_by(game_winner_cat,team_penalty_cat,penalty_side)%>%
  summarise(mean_yds=round( mean(sum_yds),1))

```

Python:
```py
df_yds_totales_week = data.groupby(["game_winner_cat","team_penalty_cat","penalty_side",\
                               "season","week"])["penalty_yards"].sum().reset_index(name="sum_yds")


df_yds_totales = df_yds_totales_week.groupby(["game_winner_cat","team_penalty_cat", \
                                              "penalty_side"])["sum_yds"].mean().round(1).reset_index(name="mean_yds")


```

Yo estoy muy enamorado de Pandas pero el operador  `%>%` se me hizo una chulada.



Este es el código de **ggplot** para crear la gráfica:

```r
##### Gráfica de castigos ofensivos

ggplot(df_yds_totales %>% filter(penalty_side=='Castigo Ofensivo'),
       aes(x=game_winner_cat, y=mean_yds, fill=team_penalty_cat))+
  geom_bar(stat = "identity",
           position = "dodge" )+
  geom_text(aes(label=paste(mean_yds," yds")),
            position=position_dodge(width=.9),
            family="mono",
            color="#08415C",
            size=3.5,
            vjust=-0.5                       #separacion vertical de la barra
            ) +  
  labs(title="Castigos Ofensivos por Equipo - ggplot",
          caption="@nerudista") +
  guides(fill=guide_legend(title=NULL))+      #remove legend title
  scale_x_discrete(labels=c("Cuando Pats Ganan","Cuando Pats Pierden"))+
  scale_y_continuous(breaks = NULL,          #remove y breaks lines
                     limits = c(0,31))+    #cambiar rango del eje y       
  scale_fill_manual(
                    values=c("#08415C", "#B0B7BC")
                    #labels=c("NE","Oponente")
                    )+
  ylab("Promedio de Yardas\n Concedidas Por Partido")+
  theme_pats_white+
theme(
  axis.title.x = element_blank()
)
```

Aquí está el de **Altair**:

```py
#primer intento ofensivos
from altair.expr import datum, if_

barOf = alt.Chart(df_yds_totales).transform_filter(
    "datum.penalty_side == 'Castigo Ofensivo'"
  ).transform_calculate(
    Genus='indexof(["NE"], datum.game_winner_cat) >= 0 ? "Cuando los Pats Ganan": "Cuando los Pats Pierden"'
).mark_bar().encode(
    x=alt.X('team_penalty_cat:N', title='', axis=None),
    y=alt.Y('mean(mean_yds):Q', title='Promedio de Yardas\nConcedidas por Partido'),    
    color=alt.Color('team_penalty_cat:N' , 
                    legend=alt.Legend(direction="horizontal",orient="none",legendX=250, legendY=-50))
)


textOf = barOf.mark_text(dx=0 ,dy=-8, fontSize=12, font="Courier", color="#08415C").encode(
    text = alt.Text( "mean(mean_yds):Q" , format=".1f",),   #redondear decimales en el label
    opacity=alt.value(0.9),
)

base_castigos_ofensivos= alt.layer(barOf, textOf).properties(
    width = 300,
    height = 250,
).facet(
    column = alt.Column("Genus:N", title=""),
)

finalOf = alt.vconcat(base_castigos_ofensivos, caption_chart).configure_header(    
    #El configure header va aquí para evitar errores de config
    title=None,
    labelOrient="bottom",  #Posición del "Cuando los Pats ganan",
    labelFontSize = 14,    #Tamaño del "Cuando los Pats ganan",
    labelFont="Courier",
    
).properties(
 title = "Castigos Ofensivos Por Equipo - Altair",
)

finalOf = finalOf.configure_title(
    anchor='start'
)

finalOf
```

En **Altair** tuve que seguir la siguiente lógica:
1. Crear chart 
2. Filtrar dentro de Altair el tipo de castigo
3. Crear un nuevo campo para generar el label "Cuando ganan .." 
4. Crear la gráfica de barra
5. Crear otra gráfica para los textos arriba de las barras
6. Hacer una _layer chart_ para unir las dos anteriores
7. Hacer una _facet chart_ para duplicar la gráfica por la variable que creé al inicio
8. Crear una gráfica para el _caption_
9. Concatenar verticalmente la _facet chart_ con el _caption_
10. Ajustar el header para que los labels de la _facet chart_  queden por debajo el eje x
11. Ajustar el título

Básicamente, tuve que entender los conceptos, diferencias y usos de layer y facet y luego ver en qué parte del proceso tenía que ajustar las etiquetas que necesitaba.

En **Altair** no logré quitar el eje Y por completo. Pude quitar los labels y los ticks pero no la línea del eje. Además, no permite saltos de línea en el título del eje, cosa que se arregla con un `\n` en **ggplot**

Una de las cosas más complicadas que tuve en **Altair** fue poner títulos, subtítulos y _captions_ (la nota que va hasta abajo). En *ggplot* eso se logra con estás líneas:

```r
labs(title="Castigos Ofensivos por Equipo - ggplot",
          caption="@nerudista") +
```

Mientras que para **Altair** tuve que seguir otro artículo del master tacos para hacer un _vconcat_ :

```py
finalOf = alt.vconcat(base_castigos_ofensivos, caption_chart).configure_header(    
    #El configure header va aquí para evitar errores de config
    title=None,
    labelOrient="bottom",  #Posición del "Cuando los Pats ganan",
    labelFontSize = 14,    #Tamaño del "Cuando los Pats ganan",
    labelFont="Courier",
    
).properties(
 title = "Castigos Ofensivos Por Equipo - Altair",
)

```
Mi complicación con el _vconcat_ es que tardé en entender que el label "Cuando Ganan los Pats" es parte del _header_ y es por eso que debo configurar el _labelOrient_ en esa parte del código. 

En **ggplot** también existe el concepto de _facet_ pero para esta gráfica no tuve que usarla. Logré un efecto similar con esta parte del código:

```r
 aes(x=game_winner_cat, 
           y=mean_yds, 
           fill=team_penalty_cat  #esto pone color por equipo
           )
       )+
  geom_bar(stat = "identity",
           position = "dodge"  #esto es similar al facet de Altair
           )+
```

Solo por no dejar va la secuencia de pasos de **ggplot**:


1. Filtrar dentro de ggplot el tipo de castigo
2. Definir los aes() de la gráfica
3. Crear la gráfica de barra
4. Sobre la anterior crear la gráfica para los textos arriba de las barras
5. Cambiar las etiquetas "Cuando ganan .." 
6. Aplicar el _theme_ que definimos al inicio. 
7. Generar el titulo y el _caption_

En cuanto a tiempos la de ggplot me tomó una hora o dos mientras que la de Altair como unas 6,7. Esto debido a que me costó entender la secuencia layer --> facet --> concat. Si no la seguía bien, este error se reproducía como conejo:

```
ValueError: Objects with "config" attribute cannot be used within LayerChart. Consider defining the config attribute in the LayerChart object instead.

```
Por su simplicidad, **ggplot** me gustó más para este ejercicio.


---------------
 Seguramente hay formas más eficientes de realizar lo que se va a mostrar aquí o incluso de completar algunas tareas que no pude finalizar porque ya de plano no encontré documentación o ejemplos que me pudieran ayudar. 
