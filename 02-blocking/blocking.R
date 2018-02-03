## ---- libraries and data ----------------------------
library(RecordLinkage)
data(RLdata500)
head(RLdata500)


# Record pairs for comparison
choose(500,2)

# Blocking by last name initial  
last_init <- substr(RLdata500[,"lname_c1"], 1, 1)
head(last_init)
# Number of blocks
length(unique(last_init))



# Number of records per block
tbl <- table(last_init)
head(tbl)

# Block sizes can vary a lot
summary(as.numeric(tbl))



# Number of records pairs per block
sapply(tbl, choose, k=2)

# Reduction on comparison space
sum(sapply(tbl, choose, k=2))

# Code to extract subset of duplicate records
RLdata500c <- RLdata500[,-c(2,4)]
cln <- table(identity.RLdata500)
iddup <- which(cln>1)-1
dup <- which(identity.RLdata500%in%iddup)
sub_dup <- RLdata500c[dup,]
oid <- order(identity.RLdata500[dup])
dup_set <- sub_dup[oid,]
tail(dup_set)

# Levenshtein similarity 
levenshteinSim("SCHUTE", "SCHULTE")
levenshteinSim("CHRISTA", "CHRISTAH")
# Jaro-Winkler similarity
jarowinkler(c("SCHUTE","CHRISTA"),
            c("SCHULTE","CHRISTAH"))

tail(dup_set)

tail(soundex(dup_set$fname_c1))
tail(soundex(dup_set$lname_c1))

head(dup_set)

head(soundex(dup_set$lname_c1))

# Two records must agree in either first name initial 
# or bith year to be compared.
# Only 2709 pairs instead of 124750!

rpairs <- compare.dedup(RLdata500c, 
blockfld = list(1, 3), #list with blocking fields
identity = identity.RLdata500)

tail(rpairs$pairs)

rpairsfuzzy <- compare.dedup(RLdata500c, 
               phonetic = FALSE, blockfld = 3, 
               strcmp = TRUE, strcmpfun = jarowinkler)

tail(rpairsfuzzy$pairs)

# tail(rpairs$pairs)
# Using comparison data blocking by first name initial
# and birth year
rpairs1 <- epiWeights(rpairs)

# Weights to compute thresholds for classification
rpairs1$Wdata[1:5]

## summary(rpairs1)

## ---- eval=FALSE, message=FALSE, warning=FALSE---------------------------
## result <- epiClassify(rpairs1, 0.7)
## summary(result)
## 
## alpha error: 0.080000 # False negative rate
## beta error: 0.000000  # False positive rate
## accuracy: 0.998523
## 
## Classification table:
## 
##            classification
## true status    N    P    L
##       FALSE 2659    0    0
##       TRUE     4    0   46

