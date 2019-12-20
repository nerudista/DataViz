#Archivo limpio para las graficas finales

library(ggplot2)
library(tidyverse)
library(readr)
library(ggthemes) # Load

########################################
#### CREAR MI THEME PARA NO REPETIRLO EN LAS GRAFICAS
########################################

#Color codes for Pats logo
#blue #002145
#red  #C8032B
#gray #B0B7BC

theme_pats_gray <- theme_hc() +
  theme(
    text=element_text(size=12,
                      family="mono",
                      color="#002145"),
    # limpiar la gráfica
    axis.ticks = element_blank(),
    #axis.title.x = element_text(color="#08415C"),
    #axis.title.y = element_text(color="#08415C"),
    #axis.text.x = element_text(color="#08415C"),
    #axis.text.y = element_text(color="#08415C"),
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
    # fondo
    plot.background = element_rect(fill = "#B0B7BC"),
    
    #grid lines
    #panel.grid.major = element_blank(),
    #panel.grid.minor = element_blank(),
    
    # legend color
    legend.background = element_rect(fill='#B0B7BC'),
    legend.position = "top",
    legend.text = element_text(
      color="#08415C"), 
    legend.spacing.x = unit( 1,"cm"),
    legend.box.margin = margin(.5, .5, .5, .5, "cm")
  )


theme_pats_white <- theme(
  
  text=element_text(size=12,
                    family="mono",
                    color="#002145"),
  # limpiar la gráfica
  axis.ticks = element_blank(),
  #axis.title.x = element_text(color="#08415C"),
  #axis.title.y = element_text(color="#08415C"),
  #axis.text.x = element_text(color="#08415C"),
  #axis.text.y = element_text(color="#08415C"),
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
                                  week = col_number(),
                                  week_type = col_character()))
summary(data)


########################################
#### CAMBIAR LOS LEVELS
########################################
#Cambiar los labels, de los levels, de team_penalty_cat
df_juegos_posesion$team_penalty_cat <- factor(df_juegos_posesion$team_penalty_cat,
                                              levels = c("NE", "Oponente"), 
                                              labels = c("Castigo de NE", "Castigo de Oponente"))



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
  labs(title="Castigos Ofensivos por Equipo",
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
  
  
ggsave(filename = "./Graficas/R/RplotCastigosOfensivos.png",
       width = 210,
       height = 140,
       units ="mm"
       )  

#### Gráfica de castigos defensivos

ggplot(df_yds_totales %>% filter(penalty_side=='Castigo Defensivo'),
       aes(x=game_winner_cat, y=mean_yds, fill=team_penalty_cat))+
  geom_bar(stat = "identity",
           position = "dodge"
  )+
  geom_text(aes(label=paste(mean_yds," yds")),
            position=position_dodge(width=.9),
            family="mono",
            color="#08415C",
            size=3.5,
            vjust=-0.5                       #separacion vertical de la barra
  ) +  
  labs(title="Castigos Defensivos por Equipo",
        caption="@nerudista") +
  scale_x_discrete(labels=c("Cuando Pats Ganan","Cuando Pats Pierden"))+
  scale_y_continuous(breaks = NULL,          #remove y breaks lines
                     limits = c(0,40))+    #cambiar rango del eje y
  scale_fill_manual(values=c("#08415C", "#B0B7BC"),
                    labels=c("NE","Oponente"))+
  guides(fill=guide_legend(title=NULL))+      #remove legend title
  ylab("Promedio de Yardas\n Concedidas Por Partido") +
  theme_pats_white+
  theme(
    axis.title.x = element_blank()
  )

ggsave(filename = "./Graficas/R/RplotCastigosDefensivos.png",
       width = 210,
       height = 140,
       units ="mm"
)  

########################################
###   CHECK PENALTIES BY OPPRTUNITY
########################################



 df_opp <- data %>%
  group_by(opportunity,team_penalty_cat) %>%
  summarise(count=sum(penalty_yards)) #count

levels(as.factor(df_opp$team_penalty_cat))  

  plot_opp <- ggplot(df_opp,
                     aes(x=opportunity, y=count,
                         fill=team_penalty_cat
                         #fill=factor(team_penalty_cat,levels=c("NE","Oponente"))
                         )) +
  geom_bar(stat = "identity",
           position="stack")+
  geom_text(aes(label=count),
            position=position_stack(vjust = .5),
            family="mono",
            color="#FFFFFF",
            size=3.5
            )+ 
  xlab("Oportunidad")+
  coord_flip()+
  labs(title="Yardas Concedidas\nPor Equipo y Oportunidad",
       subtitle="Incluye Castigos Ofensivos y Defensivos",
       caption="@nerudista") +
  guides(fill=guide_legend(title=NULL))+      #remove legend title
  scale_fill_manual(values=c("#08415C", "#B0B7BC"))+
  scale_y_discrete(breaks=NULL)+
  
  theme_pats_white+
  theme(
    axis.title.x = element_blank()
  ); plot_opp

ggsave(plot_opp,
       filename = "./Graficas/R/RplotYardasOportunidad.png",
       width = 210,
       height = 140,
       units ="mm"
)  

########################################
###   CHECK PENALTIES IN LAST 5 MIN IN 4Q
########################################
library(data.table)

#Create column for minute:second in time left
data$mytime <- strptime(data$time_left_qtr,"%M:%S") %>% as.ITime()
limit <- strptime("05:00","%M:%S") %>% as.ITime()

 
########## CASTIGOS TEMPORADA REGULAR
 
  df_4q_5min_reg<- data %>%
  filter( difftime(data$mytime, limit) < 0 , quarter == "Q4", 
          game_type=='REG',team_penalty_cat !='NE') %>%
  group_by(week) %>%
  summarise(count=n())
  #summarise(count=sum(penalty_yards))%>%
  
  plot_4q_5min_reg <- ggplot(df_4q_5min_reg,aes(x=reorder(week, sort(as.numeric(week))) , y=count)) +
  geom_bar(stat = "identity",
           fill = "#B0B7BC")+ #gray
  geom_hline(aes(yintercept = mean(count)),
             color='#C8032B',
             linetype="dashed",
             size=1,
             alpha=0.8)+
  annotate(geom="text", y=6.3,x=3.5, 
           label="Promedio de Castigos",
           family="mono",
           color="#C8032B")+
  geom_text(aes(label=count),
                family="mono",
                vjust=2.5,
                color="#C8032B")+
  theme(
    axis.text.y =  element_blank()
  )+
  xlab("Semana")+
  ylab("Número de Castigos")+
  labs(title="Castigos de Contrarios\nEn los 5 min Finales",
       subtitle="Partidos de Temporada Regular",
       caption="@nerudista") +
  theme_pats_white;  plot_4q_5min_reg
 
  ggsave(plot_4q_5min_reg,
         filename = "./Graficas/R/RplotCastigoPorSemanasReg.png",
         width = 210,
         height = 140,
         units ="mm"
  )    
  

  ########## CASTIGOS POST-TEMPORADA 
#El dataset tiene un error. EL SB de 2014 lo pone ocmo Week 5 y debe ser 4

data$week <- ifelse( data$game_type=='POST' & data$week==5,
                     '4',
                     data$week)



  df_4q_5min_post<- data %>%
  filter( difftime(data$mytime, limit) < 0 , quarter == "Q4",
          game_type=='POST',team_penalty_cat !='NE') %>%
  group_by(week_type,penalty_side) %>%
  summarise(count=n())
  
  #Cambiar los labels, de los levels, de team_penalty_cat
  df_4q_5min_post$week_type <- factor(df_4q_5min_post$week_type,
                                      levels = c("Wildcard", "Ronda Divisional",
                                                 "Ronda Campeonato","Super Tazón")
                                      )
  
  
  
  plot_4q_5min_post <- ggplot(df_4q_5min_post,
                              aes(x=week_type,
                              y=count , 
                              fill=penalty_side)) +
  geom_bar(stat = "identity",
          position = "stack")+
  geom_text( aes(label=count),
             family="mono",
             position=position_stack(vjust = .5),
             vjust=0.5,
             color="#FFFFFF"
  )+
  xlab("Semana")+
labs(title="Castigos de Contrarios\nEn los 5 min Finales",
     subtitle="Partidos de Postemporada",
       caption="@nerudista") +
       guides(fill=guide_legend(title=NULL))+      #remove legend title
       scale_fill_manual(values=c("#08415C", "#B0B7BC"))+
    theme(
      axis.text.y =  element_blank(),
      axis.title.y = element_blank()
    )+
    theme_pats_white;  plot_4q_5min_post
  
  
  ggsave(plot_4q_5min_post,
         filename = "./Graficas/R/RplotCastigoPorSemanasPost.png",
         width = 210,
         height = 140,
         units ="mm"
  )    
  
  ########################################
  ### VER CASTIGOS EN JUEGOS DE UNA POSESION
  ### 
  ########################################
  
  
  df_juegos_posesion <- data %>%
    group_by(game_winner_cat,team_penalty_cat,season,week,quarter,one_posession_game) %>%
    filter(one_posession_game=='Juego de una posesión', quarter != 'Q5') %>%
    summarise(cnt_pen=n())%>%
    group_by(game_winner_cat,team_penalty_cat,quarter,one_posession_game)%>%
    summarise(mean_pen=round(mean(cnt_pen),2))
  
  #Cambiar los labels, de los levels, de team_penalty_cat
  df_juegos_posesion$team_penalty_cat <- factor(df_juegos_posesion$team_penalty_cat,
                                                levels = c("NE", "Oponente"), 
                                                labels = c("Castigo\nde NE", "Castigo\nde Oponente"))
  
  plot_juegos_1_posesion <- ggplot(df_juegos_posesion,
         aes(x=game_winner_cat, y=mean_pen, fill=quarter))+
    geom_bar( stat = "identity",
              position = "dodge")+
    geom_text( aes(label=mean_pen),
               family="mono",
               position=position_dodge(width=.9),
               vjust=2,
               size=3,
               color="#FFFFFF"
    )+
    facet_grid( team_penalty_cat ~ .   ) +
    scale_x_discrete(labels=c("Cuando Pats ganan","Cuando Pats pierden"))+
    scale_fill_manual(values=c("#a8bdc6","#8ea8b4","#4b7488","#08415C"))+
    labs(title="Promedio de Castigos por Quarter",
         subtitle="Juegos de Una Posesión",
         caption="@nerudista") +
    guides(fill=guide_legend(title=NULL))+      #remove legend title
    scale_y_continuous(breaks=NULL)+            #remove y axis numbers
    theme_pats_white+
    theme(
      #titulos del facet
      strip.text.y = element_text(size = 10, colour = "black", angle = 90),
      #remover titulos de los ejes
      axis.title.y = element_blank(),  
      axis.title.x = element_blank()
      )
  
  
  ggsave(plot_juegos_1_posesion,
         filename = "./Graficas/R/RplotJuegosUnaPosesion.png",
         width = 210,
         height = 140,
         units ="mm"
  )    
  
  ########################################
  ### VER CASTIGOS POR TEMPORADA, OFENSIVOS Y DEFENSIVOS
  ### HECHOS POR OPONENTES
  ########################################
  
  #biblioteca para textos en scatter
  library(ggrepel)
  
  
  
  df_temporada_help <- data %>%
    group_by(season,week,team_penalty_cat,penalty_side,game_type) %>%
    summarise(cnt_pen_game=n(),
              pats_points_game=mean(pats_points),
              opp_points_game=mean(opps_points)) %>%
    filter (  team_penalty_cat == 'Oponente') %>%
    group_by(season,penalty_side) %>%
    summarise(sum_pen_season=sum(cnt_pen_game),
              opp_points_season=sum(opp_points_game))
  
  
  
  plot_temporada_help <- ggplot( df_temporada_help,aes(x=sum_pen_season, y=opp_points_season))+
    geom_point(aes(color=penalty_side,
                   #shape=penalty_side,
                   size = sum_pen_season,
                   ),
               show.legend = FALSE,           #esto elimina el legend de los bubbles
               alpha = 0.4) +
    geom_smooth(aes(color=penalty_side,       #crea linea de regresion
                    fill = penalty_side
                ), 
                se=FALSE,
                alpha=0.2,
                method = lm,
                fullrange = TRUE)+
    geom_text_repel(aes(label = season,  color = penalty_side), 
                     size = 2.5,
                     show.legend = FALSE
                     )+   #label de dots
    scale_color_manual(values = c("#C8032B", "#08415C"))+
    xlab("Castigos")+
    ylab("Puntos")+
    labs(caption="@nerudista",
         title="Castigos de Contrarios vs Puntos Permitidos",
         subtitle="Totales por Temporada"
         )+
  theme(
    legend.title = element_blank(),
    legend.key = element_rect(fill="#FFFFFF"),     #quita el color gris de la línea de castigos  
    #legend.position = "right",
    #legend.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    legend.position = c(0.7, 0.35)
  )  +
    theme_pats_white
    
    
  ggsave(plot_temporada_help,
         filename = "./Graficas/R/RplotCastigosVSYardas.png",
         width = 210,
         height = 140,
         units ="mm"
  )    
  
  
  ########################################
  ### VER CASTIGOS POR TEMPORADA, OFENSIVOS Y DEFENSIVOS
  ### HECHOS POR TODOS
  ########################################
  
  library(directlabels)
  
  df_temporada_help_all <- data %>%
    group_by(season,week,team_penalty_cat,penalty_side,game_type) %>%
    summarise(cnt_pen_game=n(),
              pats_points_game=mean(pats_points),
              opp_points_game=mean(opps_points)) %>%
    group_by(season,team_penalty_cat,penalty_side) %>%
    summarise(sum_pen_season=sum(cnt_pen_game),
              opp_points_season=sum(opp_points_game))
  
  #Crear columna para unir el tipo de castigo y quién lo hizo
  df_temporada_help_all$cat_made <- paste(df_temporada_help_all$team_penalty_cat,df_temporada_help_all$penalty_side)
  
  plot_temporada_all <- ggplot(df_temporada_help_all,aes(x=season,
                                   y=sum_pen_season,
                                   group=cat_made))  +
    geom_line(aes(color=cat_made, size=sum_pen_season),
              show.legend = TRUE,
              alpha = .8)+
    #geom_point(aes(color=cat_made))+
    geom_dl(aes(label = cat_made), 
            
            #method = list(dl.trans(x = x + .2), "last.points")
            #method = list( "smart.grid",cex=.8) 
            #method = list( "last.points",rot=30,colour="#08415C",family="mono") 
            #method="top.points"
            method=list("top.bumptwice",colour="#08415C",family="mono")
            #method = list(dl.trans(x = x + .2), "first.points")
            ) +
    scale_color_manual(values=c("#08415C","#a5b9c3","#d23051","#eba3b1"))+
    xlab("Temporada")+
    ylab("Total de Castigos")+
    guides(size=FALSE,color=FALSE)+
    labs(caption="@nerudista",
         title="Castigos por Temporada"
         #subtitle="Totales por Temporada"
    )+
    theme(
      legend.position = "top",
      legend.box = "vertical",
      legend.title = element_blank(),
    )+
    theme_pats_white
  
  ggsave(plot_temporada_all,
         filename = "./Graficas/R/RplotCastigosAllSeason.png",
         width = 210,
         height = 140,
         units ="mm"
  )  
  
  ########################################
  ### PARALLEL COORDINATES
  ### POR SEASON
  ########################################
  
  library(GGally)
  
  #Voy a usar el mismo dataset de la gráfica pasada
  
  #Creo un vector de los años en que los Pats fueron campeones
  años_campeon <- c(2015,2017,2019)
  
  #CREAR COLUMNA PARA VER SI FUE CAMPAÑA DE SB
  df_temporada_help_all$super_bowl <- ifelse(df_temporada_help_all$season %in% años_campeon ,
                                             'Campeón','No campeón')
  
  
  #tenemos que modificar el df para poner el cat made como columna y no como fila
  library(reshape2)
  
  cast.df_temporada_help_all <- dcast(df_temporada_help_all, 
                                      season+super_bowl~cat_made,
                                      value.var = "sum_pen_season")
  
  #Cambiar los labels, de los levels, de team_penalty_cat
  cast.df_temporada_help_all$super_bowl <- factor(cast.df_temporada_help_all$super_bowl,
                                                levels = c("No campeón", "Campeón"), 
                                                labels = c("No campeón", "Campeón"))
  
  
  
  colors <- ifelse( cast.df_temporada_help_all$season %in% años_campeon,
                    "#08415C", "#f5d1d8") 
  
  plot_parallel <- ggparcoord(cast.df_temporada_help_all,
             columns = c(3,4,5,6), 
             groupColumn = "season",
             scale="globalminmax",
             title = "Comportamiento de Castigos Por Temporada",
             #order="skewness",
             alphaLines = 0.8,
             showPoints = TRUE
  ) +
    #geom_line(aes(size=.4))+
    geom_dl(aes(label = season), 
            
            #method = list(dl.trans(x = x + .2), "last.points")
            method = list( "smart.grid",cex=.8) 
            #method = list( "last.points",cex=.8,rot=30,colour="#08415C",family="mono") 
            #method="top.points"
            #method=list("top.bumptwice",colour="#08415C",family="mono")
            #method = list(dl.trans(x = x + .2), "first.points")
    ) +
    scale_color_manual(values=colors ) +
    xlab("")+
    ylab("Castigos")+
    guides(color=FALSE)+
    theme (
      panel.grid.minor = element_line(color = "gray")
      
    )+
    theme_pats_white
  
  
  ggsave(plot_parallel,
         filename = "./Graficas/R/RplotCastigosBySeasonParallel.png",
         width = 280,
         height = 140,
         units ="mm"
  )
  