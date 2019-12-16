library(ggplot2)
library(tidyverse)
library(readr)
library(ggthemes) # Load

#read csv
data <- read_csv("Pats_penalty_plays_2009_2019.csv", 
                 col_types = cols(penalty_yards = col_integer(), 
                                  season = col_character(), 
                                  yards_to_td = col_integer(),
                                  yards_to_go = col_integer(),
                                  time_left_qtr = col_character(),
                                  week = col_number()))
summary(data)




#Filter penalties for 2019 made in Q4
df_2019_4Q <- data %>% filter(Quarter == "Q4", Season == "2019")


# Grouped
p <- ggplot(df_2019_4Q) +
 geom_col(aes(x=Season, y=Penalty_Yards, group=team_penalty, fill=team_penalty, label=team_penalty), position="dodge")
                 #  +  geom_text(aes(label=Penalty_Yards))




#try with geom_bar
#this creates a grouped bar but using count not SUM
ggplot(data , aes(x=Season,  y=Penalty_Yards, fill=team_penalty)) + 
  geom_bar(position="dodge",stat ="identity")
       

#attemp for sum
data_grouped_ <- data %>%
  group_by(Season,team_penalty ) %>%
  summarise(count = sum(Penalty_Yards))

ggplot(data_grouped) +
  geom_bar(aes(x=Season, y=count, fill=team_penalty),
           position = 'dodge', stat="identity") +
   theme(
     # Hide panel borders and remove grid lines
     panel.border = element_blank(),
     panel.grid.major = element_blank(),
     panel.grid.minor = element_blank(),
     legend.title= element_text(colour = "red", size = rel(1.5)) ,
     axis.ticks = element_blank()
   ) 


#try with classic
p_classic <- ggplot(data_grouped) +
  geom_bar(aes(x=Season, y=count, fill=team_penalty),
           position = 'dodge', stat="identity") +
  theme_classic( ); p_classic 

#try with custom theme
p_custom <- ggplot(data_grouped) +
  geom_bar(aes(x=Season, y=count, fill=team_penalty),
           position = 'dodge', stat="identity") +
  scale_fill_manual(values=c("#08415C", "#F15152"))+
  theme(
    # Hide panel borders and remove grid lines
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.background= element_blank(),
    panel.grid.minor = element_blank()) +
    xlab("Temporada") +
    ylab("Yardas otorgadas") +
  ggtitle("¿Quién ha recibido más yardas por castigo?") ; p_custom


#try with js highchart 
p_js <- ggplot(data_grouped, aes(x=Season, y=count, fill=team_penalty)) +
  geom_bar( 
            stat="identity",
            width=0.6,
            position=position_dodge(width=0.6)  #dodge for grouped bar
  ) +  
  geom_text(aes(label=count),
            position=position_dodge(width=0.7),
            size=2.5,
            vjust=-0.8) +  #labels on bars
  theme_hc()+ scale_colour_hc() +
  xlab("Temporada")+
  ylab("Yardas otorgadas")+
  scale_y_continuous(limits = c(0,1400), breaks = NULL)+  #nreaks on y axis
  #scale_y_continuous( breaks = NULL)+  # remove breaks in y axis
  scale_fill_manual(values=c("#B0B7BC", "#002244"))+
  theme(
    plot.title = element_text(hjust = 0.5),  #align title
    legend.position="top",                #move legend to top
    axis.text.y = element_blank(),
  )+
  guides(fill=guide_legend(title=NULL))+      #remove legend title
  ggtitle("¿Quién ha otorgado más yardas en castigos?") ; p_js



##############
# ultimo cuarto
#Filter penalties for 2019 made in Q4
df_4Q <- data %>% filter(Quarter == "Q4")
df_4Q


df_grouped_4Q <- df_4Q %>%
  group_by(Season,team_penalty ) %>%
  summarise(count = sum(Penalty_Yards))
  

#try with js highchart 
p_4Q <- ggplot(df_grouped_4Q, aes(x=Season, y=count, fill=team_penalty)) +
  geom_bar( 
    stat="identity",
    width=0.6,
    position=position_dodge(width=0.6)  #dodge for grouped bar
  ) +  
  geom_text(aes(label=count),
            position=position_dodge(width=0.7),
            size=2.5,
            vjust=-0.8) +  #labels on bars
  theme_hc()+ scale_colour_hc() +
  xlab("Temporada")+
  ylab("Yardas otorgadas")+
  scale_y_continuous(limits = c(0,400), breaks = NULL)+  #nreaks on y axis
  scale_fill_manual(values=c("#B0B7BC", "#002244"))+
  theme(
    plot.title = element_text(hjust = 0.5),  #align title
    legend.position="top",                #move legend to top
    axis.text.y = element_blank(),
  )+
  guides(fill=guide_legend(title=NULL))+      #remove legend title
  ggtitle("¿A quién castigan más en el 4Q?") ; p_4Q


###########
## tipos de castigo

#df_type <- data %>% filter(Penalty_on == 'NE' , Penalty=="Defensive Offside")

df_type <- data %>% 
           #filter(team_penalty=='Pats') %>%
           group_by(Season,Penalty, team_penalty) %>%
           summarise(count=sum(Penalty_Yards)) %>%
           filter(count > 30) %>%
           top_n(n = 10, wt = count)
           

ggplot(data=df_type , aes(Season,Penalty,fill=count)) +
       geom_tile()+
       theme_hc()+ 
       scale_colour_hc()+
       geom_text(aes(label=count),
            size=4.4,
            #colour="#C60C30",
            colour="#FFFFF5",
            vjust=-0) +   #labels on bars
       facet_grid(. ~ team_penalty ) +
       scale_fill_gradient(low="#B0B7BC", high="#002244") +
       xlab("Temporada")+
       theme(
             strip.text.x = element_text(size = 16, colour = "#002244"),
             legend.position = "none",  #remove legend
             # modify Title
             plot.title = element_text(color = "#002244", size = 18, face = "bold",hjust = 0.5),
             #modify labels in axis
             axis.title.x = element_text(size = rel(1.6), angle = 00),
             axis.title.y = element_blank(),
             axis.text.y = element_text(size=rel(1.4),color = "#002244") ,
             axis.text.x = element_text(size=rel(1.4),color = "#002244",face = "bold") ,
             #remove legend title
             strip.background = element_rect( fill="#FFFFFF")) +
       guides(fill=guide_legend (title=NULL)) +     
        ggtitle("¿Qué castigos han otorgado más yardas?") 


###########
## 4Q horizontal
###########

data$team_with_ball <- ifelse(data$Team_Possesion == 'NE', 'Pats', 'Opponent')

df_grouped_weeks <- data %>%
  filter(team_penalty=='Opponent',team_with_ball=='Pats') %>%
  group_by(Week,team_with_ball ) %>%
  summarise(count = sum(Penalty_Yards))

ggplot(df_grouped_weeks ,
       aes(x=Week,y=count)) +
       geom_bar(stat = "identity"
                )+
         coord_flip()


  geom_text(aes(label=count),
            position=position_dodge(width=0.7),
            size=3.5,
            hjust=-0.5) +  #labels on bars
  theme_hc()+ scale_colour_hc() 
  
########################################
###   CHECK PENALTIES BY OPPRTUNITY
########################################
   


  plot_opp <- data %>%
    #filter( quarter=='Q4') %>%
    group_by(opportunity) %>%
    #summarise(count=n()) #count
    summarise(count=sum(penalty_yards)) %>%#count
  ggplot( aes(x=opportunity, y=count)) +
    geom_bar(stat = "identity")+
    coord_flip()+
    geom_text(aes(label=count)) ; plot_opp
  
  
  ########################################
  ###   CHECK PENALTIES IN LAST 5 MIN IN 4Q
  ########################################
  
  
  #Create column for minute:second in time left
  data$mytime <- strptime(data$time_left_qtr,"%M:%S") %>% as.ITime()
  limit <- strptime("05:00","%M:%S") %>% as.ITime()
  
  plot_4q_5min <- data %>%
                 filter( difftime(data$mytime, limit) < 0 , quarter == "Q4") %>%
                 group_by(week) %>%
                 summarise(count=n())%>%
                 #summarise(count=sum(penalty_yards))%>%
              ggplot(aes(x=reorder(week, sort(as.numeric(week))) , y=count)) +
                  geom_bar(stat = "identity")+
                  #geom_hline(aes(yintercept = mean(count))
                  geom_hline(aes(yintercept = mean(count))); plot_4q_5min
  
  ########################################
  ### VER YARDAS TOTALES POR CASTIGO, DEFENSIVO Y OFENSIVO
  ### A FAVOR Y EN CONTRA
  ########################################
  
  #crear columna para ver quién ganó el partido
  data$game_winner_cat <- ifelse(data$winner == 'NE', 'NE', 'Opponent')
  
  df_yds_totales <-data %>%
                  group_by(game_winner_cat,team_penalty_cat,penalty_side,season,week) %>%
                  filter(season=='2009') %>%
                  summarise(sum_yds=sum(penalty_yards)) %>%
                  group_by(game_winner_cat,team_penalty_cat,penalty_side)%>%
                  summarise(mean_yds=mean(sum_yds))
  
  ## Gráfica de castigos ofensivos
  ggplot(df_yds_totales %>% filter(penalty_side=='Offensive Penalty'),
         aes(x=game_winner_cat, y=mean_yds, fill=team_penalty_cat))+
        geom_bar(stat = "identity",
                 position = "dodge"
                # position=position_dodge(width=0.6)  #dodge for grouped bar
        )+
    ggtitle("Castigos Ofensivos por equipo") +
    scale_x_discrete(labels=c("Win","Lose"))+
    scale_fill_manual(values=c("#08415C", "#F15152"))+
    theme_hc()
    
  ## Gráfica de castigos defensivos
  ggplot(df_yds_totales %>% filter(penalty_side=='Defensive Penalty'),
         aes(x=game_winner_cat, y=mean_yds, fill=team_penalty_cat))+
    geom_bar(stat = "identity",
             position = "dodge"
    ) +
    ggtitle("Castigos Defensivos por equipo") +
    scale_x_discrete(labels=c("Cuando Pats ganan","Cuando Pats pierden"))+
    scale_fill_manual(values=c("#08415C", "#F15152"))+
    #theme_classic()   #quita ticks
    theme_hc()
    #theme_minimal()
    #theme_solid() #quita las letras y legends
    #theme_test()   #limpio y enmarcado en un cuadro
    #theme_tufte()   #limpio y tipografia formal
    #theme_void()     #solo deja los legends
    
  ########################################
  ### VER CASTIGOS EN JUEGOS DE UNA POSESION
  ### 
  ########################################
  
  #crear columna para ver quién ganó el partido
  data$game_winner_cat <- ifelse(data$winner == 'NE', 'NE', 'Opponent')
  
  #crear columna para ver la diferencia de puntaje
  data$game_point_diff <- ifelse(abs(data$score_home - data$score_away)  <= 8, 'Juego de una posesión', 'Juego de más posesiones')
  
  df_juegos_posesion <- data %>%
                    group_by(game_winner_cat,team_penalty_cat,season,week,quarter,game_point_diff) %>%
                    #filter(season=='2009') %>%
                    summarise(cnt_pen=n())%>%
                    group_by(game_winner_cat,team_penalty_cat,quarter,game_point_diff)%>%
                    summarise(mean_pen=round(mean(cnt_pen),2))

  #Cambiar los labels, de los levels, de team_penalty_cat
  df_juegos_posesion$team_penalty_cat <- factor(df_juegos_posesion$team_penalty_cat,
                                              levels = c("NE", "Opponent"), 
                                          labels = c("Castigo de NE", "Castigo de Oponente"))
  
  ggplot(df_juegos_posesion,
         aes(x=game_winner_cat, y=mean_pen, fill=quarter))+
         geom_bar( stat = "identity",
                   position = "dodge")+
    facet_grid( team_penalty_cat ~ .  ) +
    scale_x_discrete(labels=c("Cuando Pats ganan","Cuando Pats pierden"))+
    theme(
          strip.text.y = element_text(size = 10, colour = "black", angle = 90))
    
  ########################################
  ### VER CASTIGOS POR TEMPORADA, OFENSIVOS Y DEFENSIVOS
  ### HECHOS POR OPONENTES
  ########################################
  
  #biblioteca para textos en scatter
  library(ggrepel)
  
  
  # crer columna para ver los puntos a favor y en contra de los pats
  
  data$pats_points <- ifelse(data$home == 'NE',data$score_home,data$score_away)
  data$opp_points  <- ifelse(data$home != 'NE',data$score_home,data$score_away)
  
  
  df_temporada_help <- data %>%
                          group_by(season,week,team_penalty_cat,penalty_side,game_type) %>%
                          summarise(cnt_pen_game=n(),
                                    pats_points_game=mean(pats_points),
                                    opp_points_game=mean(opp_points)) %>%
                          filter (  team_penalty_cat == 'Opponent') %>%
                          group_by(season,penalty_side) %>%
                          summarise(sum_pen_season=sum(cnt_pen_game),
                                    opp_points_season=sum(opp_points_game))


  
  ggplot( df_temporada_help,aes(x=sum_pen_season, y=opp_points_season))+
    geom_point(aes(color=penalty_side,
                   #shape=penalty_side,
                   size = sum_pen_season),
               alpha = 0.5) +
    geom_smooth(aes(color=penalty_side,       #crea linea de regresion
                    fill = penalty_side), 
                se=FALSE,
                method = lm,
                fullrange = TRUE)+
    geom_text_repel(aes(label = season,  color = penalty_side), size = 3)+
    scale_color_manual(values = c("#00AFBB", "#E7B800"))+
    scale_fill_manual(values = c("#00AFBB", "#E7B800"))+
    labs(caption="@nerudista",
         title="Ayudas a los Pats / Castigos hechos por los contrarios")
  
  ########################################
  ### VER CASTIGOS POR TEMPORADA, OFENSIVOS Y DEFENSIVOS
  ### HECHOS POR TODOS
  ########################################
  
  #biblioteca para textos en scatter
  library(ggrepel)
  
  
  # crer columna para ver los puntos a favor y en contra de los pats
  
  data$pats_points <- ifelse(data$home == 'NE',data$score_home,data$score_away)
  data$opp_points  <- ifelse(data$home != 'NE',data$score_home,data$score_away)
  
  
  df_temporada_help_all <- data %>%
    group_by(season,week,team_penalty_cat,penalty_side,game_type) %>%
    summarise(cnt_pen_game=n(),
              pats_points_game=mean(pats_points),
              opp_points_game=mean(opp_points)) %>%
    group_by(season,team_penalty_cat,penalty_side) %>%
    summarise(sum_pen_season=sum(cnt_pen_game),
              opp_points_season=sum(opp_points_game))
  
  #Crear columna para unir el tipo de castigo y quién lo hizo
  df_temporada_help_all$cat_made <- paste(df_temporada_help_all$team_penalty_cat,df_temporada_help_all$penalty_side)

  ggplot(df_temporada_help_all,aes(x=season,
                                   y=sum_pen_season,
                                   group=cat_made))  +
    geom_line(aes(color=cat_made))+
    geom_point(aes(color=cat_made))+
    theme_minimal()
  
  ########################################
  ### PARALLEL COORDINATES
  ### POR SEASON
  ########################################
  
  library(GGally)
  # crer columna para ver los puntos a favor y en contra de los pats
  
  data$pats_points <- ifelse(data$home == 'NE',data$score_home,data$score_away)
  data$opp_points  <- ifelse(data$home != 'NE',data$score_home,data$score_away)
  
  #Crear columna para unir el tipo de castigo y quién lo hizo
  df_temporada_help_all$cat_made <- paste(df_temporada_help_all$team_penalty_cat,df_temporada_help_all$penalty_side)
  
  
  df_temporada_help_all <- data %>%
    group_by(season,week,team_penalty_cat,penalty_side,game_type) %>%
    summarise(cnt_pen_game=n(),
              pats_points_game=mean(pats_points),
              opp_points_game=mean(opp_points)) %>%
    group_by(season,team_penalty_cat,penalty_side) %>%
    summarise(sum_pen_season=sum(cnt_pen_game),
              opp_points_season=sum(opp_points_game))
  
  años_campeon <- c(2015,2017,2019)
  
  #CREAR COLUMNA PARA VER SI FUE CAMPAÑA DE SB
  df_temporada_help_all$super_bowl <- ifelse(df_temporada_help_all$season %in% años_campeon ,
                                             'Campeón','No campeón')
  
  #Crear columna para unir el tipo de castigo y quién lo hizo
  df_temporada_help_all$cat_made <- paste(df_temporada_help_all$team_penalty_cat,df_temporada_help_all$penalty_side)
  

  #tenemos que modificar el df para poner el cat made como columna y no como fila
  library(reshape2)
  
  cast.df_temporada_help_all <- dcast(df_temporada_help_all, 
                                      season+super_bowl~cat_made,
                                      value.var = "sum_pen_season")
  
  colors <- ifelse( cast.df_temporada_help_all$season %in% años_campeon,
                    "#002244", "#B0B7BC") 
  
  ggparcoord(cast.df_temporada_help_all,
              columns = c(3,4,5,6), 
             groupColumn = "season",
             scale="globalminmax",
             title = "Parallel Coordinate Plot for PAts penalties",
             #order="skewness",
             alphaLines = 0.9,
             showPoints = TRUE
              ) +
    scale_color_manual(values=colors ) +
    theme_minimal()+
    xlab("")

    
  
    