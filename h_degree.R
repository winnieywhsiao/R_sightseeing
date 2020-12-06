library(RMySQL)
library('visNetwork')
library('igraph')

con <- dbConnect(MySQL(), 
                 db = "homestead",
                 username = "root", 
                 password = "sightseeing",
                 host = "140.136.155.116")
dbSendQuery(con,"SET NAMES big5")

#找到目標id
hname <- '台北東旅'
id_sql <- paste("SELECT id FROM hotel_data WHERE name = '",hname,"'", sep="")
sid <- dbGetQuery(con, id_sql)

#找到好的(P)裡面degree最大的
g_sql <- paste("SELECT s.degree 
                FROM h_segment_data s, hotel_data hd 
                WHERE (s.hotel_id = hd.id) 
                AND s.hotel_id = '",sid,"' 
                AND s.evaluation = 'P'", sep="")
good <- dbGetQuery(con, g_sql)
DegreeMax <- max(good$degree)

# 找到maxdegree的名稱
g <- paste0("SELECT id, segment, color, degree
            FROM h_segment_data s
            WHERE evaluation = 'P' 
            AND hotel_id = '",sid,"'
            AND degree = '",DegreeMax,"'",sep="")
gname <- dbGetQuery(con, g)

#找到與maxdegree的id
gid = gname$id

# =============以上是為了找到gid(degree最高的點)=============
#被連到最多的圖亮吧
seg <- paste("SELECT s.id, s.segment, s.color, s.hotel_id, hd.name  
              FROM h_segment_data s, hotel_data hd 
              WHERE (s.hotel_id = hd.id) 
              AND s.hotel_id = '",sid,"' 
              AND s.evaluation = 'P'", sep="")
seg_relat <- paste("SELECT from_id,to_id,weight,color 
                    FROM h_segment_relationship 
                    WHERE hotel_id = '",sid,"' 
                    AND from_id = ANY(SELECT id FROM h_segment_data WHERE hotel_id = '",sid,"' AND evaluation = 'P')", sep="")

segment <- dbGetQuery(con, seg)
relationship <- dbGetQuery(con, seg_relat)
x <- data.frame(segment)
y <- data.frame(relationship)
fsize <- (good$degree)
nodes <- data.frame(id = c(x$id), color = c(x$color),
                    label = c(x$segment), 
                    # title = paste("<p>", x$segment,"</p>")
                    font.size = 40, value = fsize)
edges <- data.frame(from = c(y$from_id), to = c(y$to_id),
                    value = c(y$weight),color = c(y$color))

visNetwork(nodes,edges, width = "100%",height = "500px") %>%
  visIgraphLayout() %>%
  visOptions(highlightNearest = list(enabled = T, hover = T),
             nodesIdSelection = list(enabled = TRUE))

# dbDisconnect(con)
on.exit(dbDisconnect(con))

# 測試db連接
lapply(dbListConnections(MySQL()), dbDisconnect)