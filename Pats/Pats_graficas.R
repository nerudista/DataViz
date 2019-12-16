#Archivo limpio para las graficas finales

library(ggplot2)
library(tidyverse)
library(readr)
library(ggthemes) # Load

########################################
#### LEER ARCHIVO DE DATOS
########################################
#read csv
data <- read_csv("Pats_penalty_plays_2009_2019.csv", 
                 col_types = cols(penalty_yards = col_integer(), 
                                  season = col_character(), 
                                  yards_to_td = col_integer(),
                                  yards_to_go = col_integer(),
                                  time_left_qtr = col_character(),
                                  week = col_number()))
summary(data)

########################################
#### VER YARDAS TOTALES POR CASTIGO, DEFENSIVO Y OFENSIVO,
#### A FAVOR Y EN CONTRA
########################################

#Crear columna game_winner_cat para ver quién ganó el partido
data$game_winner_cat <- ifelse(data$winner == 'NE', 'NE', 'Oponente')

df_yds_totales <-data %>%
  group_by(game_winner_cat,team_penalty_cat,penalty_side,season,week) %>%
  summarise(sum_yds=sum(penalty_yards)) %>%
  group_by(game_winner_cat,team_penalty_cat,penalty_side)%>%
  summarise(mean_yds=round( mean(sum_yds),1))

##### Gráfica de castigos ofensivos

ggplot(df_yds_totales %>% filter(penalty_side=='Offensive Penalty'),
       aes(x=game_winner_cat, y=mean_yds, fill=team_penalty_cat))+
  geom_bar(stat = "identity",
           position = "dodge" )+
  geom_text(aes(label=mean_yds),
            position=position_dodge(width=.9),
            color="#08415C",
            size=rel(5.4),
            vjust=-0.5                       #separacion vertical de la barra
            ) +  
  labs(title="Castigos Ofensivos por equipo",
          caption="@nerudista") +
  guides(fill=guide_legend(title=NULL))+      #remove legend title
  scale_x_discrete(labels=c("Cuando Pats ganan","Cuando Pats pierden"))+
  scale_y_continuous(breaks = NULL,          #remove y breaks lines
                     limits = c(0,31))+    #cambiar rango del eje y       
  scale_fill_manual(values=c("#08415C", "#F15152"),
                    labels=c("NE","Oponente"))+
  ylab("Promedio de Yardas por partido") +
  theme_hc() +
  theme(
    # limpiar la gráfica
    axis.ticks = element_blank(),
    axis.title.x = element_blank(), #quita el game_winner_cat del eje  x
    axis.title.y = element_text(size=20,
                                color="#08415C"),
    axis.text.y = element_blank(), #quita el 10,20,30 del eje y
    axis.text.x = element_text(size=20,
                               color="#08415C"),
    # ajustar titulos y notas
    plot.title = element_text(color="#08415C",
                              size=30),
    plot.caption = element_text(size=12,
                                color="#08415C",
                                face="italic"),
    # fondo
    plot.background = element_rect(fill = "#B0B7BC"),
    
    # legend color
    legend.background = element_rect(fill='#B0B7BC'),
    legend.position = "top",
    legend.text = element_text(size=15, color="#08415C"),  #tamaño del NE,Opponen
    #legend.spacing.y = unit( 1,"cm"),
    legend.spacing.x = unit( 1,"cm"),
    legend.box.margin = margin(.5, .5, .5, .5, "cm")
  )

#### Gráfica de castigos defensivos

ggplot(df_yds_totales %>% filter(penalty_side=='Defensive Penalty'),
       aes(x=game_winner_cat, y=mean_yds, fill=team_penalty_cat))+
  geom_bar(stat = "identity",
           position = "dodge"
  ) +
  labs(title="Castigos Defensivos por equipo",
        caption="@nerudista") +
  scale_x_discrete(labels=c("Cuando Pats ganan","Cuando Pats pierden"))+
  scale_fill_manual(values=c("#08415C", "#F15152"))+
  theme_hc()


