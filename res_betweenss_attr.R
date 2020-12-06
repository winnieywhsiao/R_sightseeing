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
tag1 <- '中式料理'
tag2 <- '無'
sn_sql <- paste("select DISTINCT rd.id,rd.name, rd.city_name, rd.type, rd.color 
                FROM restaurant_relationship rr, restaurant_data rd, restaurant_attr ra 
                WHERE (rr.from_id = rd.id AND rr.to_id = ra.id) 
                AND rd.city_name ='", cname,"'
                AND (ra.tag ='", tag1,"' OR ra.tag ='", tag2,"')",sep="")
sa_sql <- paste("select * from restaurant_attr WHERE tag ='", tag1,"' OR tag ='", tag2,"'",sep="")
sr_sql <- paste("select rr.from_id,rd.name,rr.to_id,ra.tag 
                FROM restaurant_relationship rr, restaurant_data rd, restaurant_attr ra 
                WHERE (rr.from_id = rd.id AND rr.to_id = ra.id) 
                AND rd.city_name ='", cname,"' 
                AND (ra.tag ='", tag1,"' OR ra.tag ='", tag2,"')",sep="")

dbSendQuery(connect,"SET NAMES big5")
sn <- dbGetQuery(connect , sn_sql)
sa <- dbGetQuery(connect ,sa_sql)
sr <- dbGetQuery(connect ,sr_sql)

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
lapply(dbListConnections(MySQL()), dbDisconnect)