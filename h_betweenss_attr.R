library(RMySQL)
library('visNetwork')
library('igraph')

con <- dbConnect(MySQL(), 
                 db = "homestead",
                 username = "root", 
                 password = "sightseeing",
                 host = "140.136.155.116")

#傳值到cityname
cname <- '台北'
tag1 <- '游泳池'
tag2 <- '免費停車'
sn_sql <- paste("select DISTINCT d.id,d.name, d.city_name, d.color 
                FROM hotel_relationship r, hotel_data d, hotel_attr a 
                WHERE (r.from_id = d.id AND r.to_id = a.id) 
                AND d.city_name ='", cname,"' 
                AND (a.tag ='", tag1,"' OR a.tag ='", tag2,"')",sep="")
sa_sql <- paste("select * from hotel_attr WHERE tag ='", tag1,"' OR tag ='", tag2,"'",sep="")
sr_sql <- paste("select r.from_id,d.name,r.to_id,a.tag 
                FROM hotel_relationship r, hotel_data d, hotel_attr a 
                WHERE (r.from_id = d.id AND r.to_id = a.id) 
                AND d.city_name ='", cname,"' 
                AND (a.tag ='", tag1,"' OR a.tag ='", tag2,"')",sep="")

dbSendQuery(con,"SET NAMES big5")
sn <- dbGetQuery(con , sn_sql)
sa <- dbGetQuery(con ,sa_sql)
sr <- dbGetQuery(con ,sr_sql)

nq <- nrow(sn)

x <- data.frame(sn)
# print(x$name)
y <- data.frame(sa)

n <- merge(x, y, by.x = c("id","name","color"), 
           by.y = c("id","tag","color"), all = TRUE)
# print(n)
nodes <- data.frame(id = c(n$id), color = c(n$color),
                    # label = c(n$name),  
                    # title = paste("<p>", n$name,"</p>"),
                    shape = c(n$shape), font.size = 30)
edges <- data.frame(from = c(sr$from), to = c(sr$to))

visNetwork(nodes,edges, width = "100%",height = "1000px") %>%
  visIgraphLayout() %>% #靜態
  visOptions(highlightNearest = TRUE,
             nodesIdSelection = TRUE)

# dbDisconnect(connect)
on.exit(dbDisconnect(connect))

# 測試db連接
# lapply(dbListConnections(MySQL()), dbDisconnect)