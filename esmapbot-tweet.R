# Twitter token
esmapbot_token <- rtweet::rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Load boundaries

spain <- sf::st_read("https://raw.githubusercontent.com/PrograMapa/esmapbot/master/spain.geojson")

# Random coordinates 

point <- sf::st_sample(spain, 1)

coord <- sf::st_coordinates(point)

lon <- round(coord[1],4)
lat <- round(coord[2],4)

# Random zoom level
zoom <- sample(14:16, 1)


# Mapbox API petition
img_url <- paste0(
  "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/",
  paste0(lon, ",", lat, ",", zoom),
  ",0/600x900@2x?access_token=",
  Sys.getenv("MAPBOX_PUBLIC_ACCESS_TOKEN")
)

# Download the image as temp file
temp_file <- tempfile(fileext = ".jpeg")
download.file(img_url, temp_file)


# Geocoding point
location = paste0("https://api.mapbox.com/geocoding/v5/mapbox.places/",paste0(lon, ",", lat),".json?types=place&limit=1&access_token=",Sys.getenv("MAPBOX_PUBLIC_ACCESS_TOKEN"))
loc_encoded = utils::URLencode(location, reserved = FALSE, repeated = FALSE)
address = jsonlite::fromJSON(loc_encoded, flatten = TRUE)
text = address$features$place_name

# Twitter message
# if (is.null(text)) { message <- paste0(
#  "📍 ¿Adivinas? \n",
#  "🌐 ",lat, ", ", lon, "\n",
#  "🗺️ ","https://www.google.es/maps/@", lat, ",", lon, ",16z"
# )} else { message <- paste0(
#  "📍 ", text, "\n",
#  "🌐 ",lat, ", ", lon, "\n",
#  "🗺️ ","https://www.google.es/maps/@", lat, ",", lon, ",16z"
# )}

message <- paste0(
  "📍 ", text, "\n",
  "🗺️ ","https://www.google.es/maps/@", lat, ",", lon, ",16z"
)

alt_text <- paste0("Imagen de satélite de ", text)

# Send tweet
rtweet::post_tweet(
  status = message,
  media = temp_file,
  media_alt_text = alt_text,
  token = esmapbot_token
)
