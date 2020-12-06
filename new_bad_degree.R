library('RMySQL')
library('visNetwork')
library('igraph')

con <- dbConnect(MySQL(), 
                 db = "homestead",
                 username = "root", 
                 password = "sightseeing",
                 host = "140.136.155.116")
dbSendQuery(con,"SET NAMES big5")

#找到目標id
sname <- '卑南文化公園'
id_sql <- paste("SELECT id FROM site_data WHERE name = '",sname,"'", sep="")
sid <- dbGetQuery(con, id_sql)

#找到壞的(N)裡面degree最大的
b_sql <- paste("SELECT s.degree 
                FROM segment_data s, site_data sd 
                WHERE (s.site_id = sd.id) 
                AND s.site_id = '",sid,"' 
                AND s.evaluation = 'N'", sep="")
bad <- dbGetQuery(con, b_sql)
DegreeMax <- max(bad$degree)

# 找到maxdegree的名稱
b <- paste0("SELECT id, segment, color, degree
            FROM segment_data s
            WHERE evaluation = 'N' 
            AND site_id = '",sid,"'
            AND degree = '",DegreeMax,"'",sep="")
bname <- dbGetQuery(con, b)

#找到與maxdegree的id
bid = bname$id

# =============以上是為了找到bid(degree最高的點)=============
#被連到最多的圖亮吧
seg <- paste("SELECT s.id, s.segment, s.color, s.site_id, sd.name  
              FROM segment_data s, site_data sd 
              WHERE (s.site_id = sd.id) 
              AND s.site_id = '",sid,"' 
              AND s.evaluation = 'N'", sep="")
seg_relat <- paste("SELECT from_id,to_id,weight,color 
                    FROM segment_relationship 
                    WHERE site_id = '",sid,"' 
                    AND from_id = ANY(SELECT id FROM segment_data WHERE site_id = '",sid,"' AND evaluation = 'N')", sep="")

segment <- dbGetQuery(con, seg)
relationship <- dbGetQuery(con, seg_relat)
x <- data.frame(segment)
y <- data.frame(relationship)
fsize <- (bad$degree)
nodes <- data.frame(id = c(x$id), color = c(x$color),
                    label = c(x$segment), 
                    # title = paste("<p>", x$segment,"</p>")
                    font.size = 30, value = fsize)
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