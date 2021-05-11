## Load spotifyr ####
library(spotifyr)
library(tidyverse)
library(here)
library(jsonlite)

# Authentication ####
Sys.setenv(SPOTIFY_CLIENT_ID = '566b5d4a15364b02b04739694250cc5e')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '3d62d3df0d4942358dad82b4646747cb')

# Get token
access_token <- get_spotify_access_token()


# Get info from tracks ####
arcade <- get_artist_audio_features('arcade fire')

arcade %>% 
  select(artist_name,album_release_year,album_name, disc_number,
         track_name, track_number, external_urls.spotify,duration_ms,
         danceability,energy,loudness,key_mode,key,mode,
         speechiness,acousticness,instrumentalness,liveness,valence,tempo) %>% 
  group_by(album_name) %>% 
  # create new field to keep orde track in Reflektor (has two discs)
  mutate(track_order_fullalbum = 1:n()) %>% 
  # write csv file
  #write_csv(file = here::here("01Data","arcade_fire_data.csv") )
  # write json file
  jsonlite::prettify() %>% 
  jsonlite::write_json(path = here::here("01Data","arcade_fire_data.json"))

