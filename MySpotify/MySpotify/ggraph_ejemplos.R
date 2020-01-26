# Libraries
library(ggraph)
library(igraph)
library(tidyverse)
# We need a data frame giving a hierarchical structure. Let's consider the flare dataset:
edges <- flare$edges

# Usually we associate another dataset that give information about each node of the dataset:
vertices <- flare$vertices

# Then we have to make a 'graph' object using the igraph library:
mygraph <- graph_from_data_frame( edges, vertices=vertices )

# Make the plot
ggraph(mygraph, layout = 'circlepack') + 
  geom_node_circle() +
  theme_void()

ggraph(mygraph, 'partition', circular = TRUE) + 
  geom_node_arc_bar(aes(fill = depth), size = 0.25) +
  theme_void() +
  theme(legend.position="none")

ggraph(mygraph, layout='dendrogram', circular=TRUE) + 
  geom_edge_diagonal() +
  theme_void() +
  theme(legend.position="none")

ggraph(mygraph, layout='dendrogram', circular=FALSE) + 
  geom_edge_diagonal() +
  theme_void() +
  theme(legend.position="none")
