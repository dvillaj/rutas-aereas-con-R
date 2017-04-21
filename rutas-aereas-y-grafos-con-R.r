#Descargar archivo flights.csv

#Ver work directory de R
getwd()

#Poner archivo flights.csv en el work directory de R

#Leer la lista de vuelos
flights <- read.csv("flights.csv", stringsAsFactors = FALSE)

#Instalar y cargar los paquetes necesarios para hacer la georeferenciación
install.packages("ggplot2")
install.packages("ggmap")
library(ggmap)

#Obtener listado de aeropuertos, eliminando los duplicados
airports <- unique(c(flights$From, flights$To))

#Georeferenciar los aeropuertos
coords <- geocode(airports)

#Crear un dataframe con los aeropuertos y sus coordenadas
airports <- data.frame(airport=airports, coords)

#Georeferenciar la lista de vuelos
flights <- merge(flights, airports, by.x="To", by.y="airport")
flights <- merge(flights, airports, by.x="From", by.y="airport")

#Instalar y cargar las librerías necesarias para poder crear el mapa de rutas aéreas
install.packages("ggrepel")
library(ggplot2)
library(ggrepel)

#Crear el mapa base
worldmap <- borders("world", colour="grey60", fill="#efede1")

#Dibujar la rutas sobre el mapa base
ggplot() + worldmap + 
 geom_curve(data=flights, aes(x = lon.x, y = lat.x, xend = lon.y, yend = lat.y), col = "#b29e7d", size = 1, curvature = .2) + 
 geom_point(data=airports, aes(x = lon, y = lat), col = "#970027") + 
 geom_text_repel(data=airports, aes(x = lon, y = lat, label = airport), col = "black", size = 2, segment.color = NA) + 
 theme(panel.background = element_rect(fill="white"), 
 axis.line = element_blank(),
 axis.text.x = element_blank(),
 axis.text.y = element_blank(),
 axis.ticks = element_blank(),
 axis.title.x = element_blank(),
 axis.title.y = element_blank()
 )
 
#Construir el diagrama de grafos
install.packages("igraph")
library(igraph)

#Crear listado de rutas 
edgelist <- as.matrix(flights[c("From", "To")])

#Convertirlos en grafos
g <- graph_from_edgelist(edgelist, directed = TRUE)

#Simplicar los grafos (quitar aquellos grafos donde los dos nodos sean iguales)
g <- simplify(g)
par(mar=rep(0,4))

#Dibujar el diagrama de grafos
plot.igraph(g, 
            edge.arrow.size=0,
            edge.color="orange",
            edge.curved=TRUE,
            edge.width=2,
            vertex.size=1,
            vertex.color="blue", 
            vertex.frame.color=NA, 
            vertex.label=V(g)$name,
            vertex.label.cex=0.8,
            layout=layout.fruchterman.reingold)