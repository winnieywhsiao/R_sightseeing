library(RMySQL)
library('visNetwork')
library('igraph')

connect <- dbConnect(MySQL(), 
                     db = "homestead",
                     username = "root", 
                     password = "sightseeing",
                     host = "140.136.155.116")

# #homestead(共11個表)
# dbListTables(connect)
# #site_data的表頭
# dbListFields(connect, "site_data")

#傳值到cityname
cname <- '台北'
sn_sql <- paste("select * from site_data where city_name ='", cname,"'",sep="")
sa_sql <- paste("select DISTINCT a.id, a.type, a.tag, a.color, a.shape, d.city_name 
      			     FROM site_relationship r, site_data d, site_attr a
              	 WHERE (r.from_id = d.id AND r.to_id = a.id)
              	 AND d.city_name ='", cname,"'",sep="")
sr_sql <- paste("select r.from_id,r.to_id 
                FROM site_relationship r, site_data d, site_attr a 
                WHERE (r.from_id = d.id AND r.to_id = a.id) 
                AND d.city_name ='", cname,"'",sep="")

dbSendQuery(connect,"SET NAMES big5")
sn <- dbGetQuery(connect , sn_sql)
sa <- dbGetQuery(connect , sa_sql)
sr <- dbGetQuery(connect ,sr_sql)

x <- data.frame(sn)
# print(x$name)
y <- data.frame(sa)

n <- merge(x, y, by.x = c("id","type","name","city_name","color"), 
           by.y = c("id","type","tag","city_name","color"), all = TRUE)
# print(n)
nodes <- data.frame(id = c(n$id), group = c(n$type),
                    #label = c(n$name),
                    color = c(n$color),  
                    # title = paste("<p>", n$name,"</p>"),
                    shape = c(n$shape.y), font.size = 30)
edges <- data.frame(from = c(sr$from), to = c(sr$to))

visNetwork(nodes,edges, width = "100%",height = "1000px") %>%
  visIgraphLayout() %>% #靜態
  visOptions(highlightNearest = TRUE,
             nodesIdSelection = TRUE)

# g <- graph.data.frame(edges, directed=FALSE, vertices=nodes)
# graph <- betweenness(g, v = V(g), directed = FALSE, weights = NA)
# visIgraph(g) %>%
#   visOptions(highlightNearest = TRUE)

# dbDisconnect(connect)
on.exit(dbDisconnect(connect))

# 測試db連接
# lapply(dbListConnections(MySQL()), dbDisconnect) 