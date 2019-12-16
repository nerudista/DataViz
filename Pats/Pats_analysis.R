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
                                  week = col_character()))


#Create column for opponent/Pats

data$team_penalty <- ifelse(data$Penalty_on == 'NE', 'Pats', 'Opponent')


#Filter penalties for 2019 made in Q4
df_2019_4Q <- data %>% filter(Quarter == "Q4", Season == "2019")



view(df_2019_4Q)

summary(df_2019_4Q)



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
  
       