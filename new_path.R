library('visNetwork')
library('igraph')

n<-read.csv("C:/xampp/htdocs/SNA/path_node.csv", header=T, as.is=T, sep=',', fileEncoding = 'utf-8')
sr<-read.csv("C:/xampp/htdocs/SNA/path_edge.csv", header=T, as.is=T, sep=',', fileEncoding = 'utf-8')


s_name <- n[1,1]
nodes <- data.frame(id = c(n$sid), group = c(n$level), 
                    color = c(n$color), 
                    # label = c(n$near_site), 
                    # title = paste("<p>", n$cityname,"</p>"),
                    font.size = 30)
edges <- data.frame(from = c(sr$from_id), to = c(sr$to_id),
                    value = c(sr$d_edge))

visNetwork(nodes, edges, width = "100%", height = "1000px")%>%
  visIgraphLayout() %>% #靜態
  visOptions(highlightNearest = TRUE, selectedBy= "group",
             nodesIdSelection = list(enabled = TRUE,  selected = s_name))
