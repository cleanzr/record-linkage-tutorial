## ----libraries-----------------
library(knitr)
library(ggplot2)
library(RecordLinkage)


## ----your-turn1----------------------------------------------------------
# load RL data
data("RLdata500")

# select only 2 records
records <- RLdata500[129:130, c(1,3)]
names(records) <- c("First name", "Last name")

# inspect records
kable(records)

## ----helpful-packages---------------------------------------
library(textreuse) # text reuse/document similarity
library(tokenizers) # shingles


## ----load-ex-data--------------------------------------------
library(RLdata) # data library
data(cora) # load the cora data set
str(cora) # structure of cora

## ----your-turn2-sol-------------------------------
# get only the columns we want
n <- nrow(cora) # number of records
dat <- data.frame(id = seq_len(n)) # create id column
dat <- cbind(dat, cora[, c("title", "authors", "journal")]) # get columnds we want

# 1. paste the columns together and tokenize for each record
shingles <- apply(dat, 1, function(x) {
  # tokenize strings
  tokenize_character_shingles(paste(x[-1], collapse=" "), n = 3)[[1]]
})

# 2. Jaccard similarity between pairs
jaccard <- expand.grid(record1 = seq_len(n), # empty holder for similarities
                       record2 = seq_len(n))

# don't need to compare the same things twice
jaccard <- jaccard[jaccard$record1 < jaccard$record2,]

time <- Sys.time() # for timing comparison
jaccard$similarity <- apply(jaccard, 1, function(pair) {
  jaccard_similarity(shingles[[pair[1]]], shingles[[pair[2]]]) # get jaccard for each pair
})
time <- difftime(Sys.time(), time, units = "secs") # timing

## ----your-turn2-plot----
# plot the jaccard similarities for each pair of records
ggplot(jaccard) +
  geom_raster(aes(x = record1, y = record2, fill=similarity)) +
  theme(aspect.ratio = 1) +
  scale_fill_gradient("Jaccard similarity") +
  xlab("Record id") + ylab("Record id")

## ----hash-tokens----------------------------------------------
# instead store hash values (less memory)
hashed_shingles <- apply(dat, 1, function(x) {
  string <- paste(x[-1], collapse=" ") # get the string
  shingles <- tokenize_character_shingles(string, n = 3)[[1]] # 3-shingles
  hash_string(shingles) # return hashed shingles
})

## ----hash-tokens-jaccard-------------------------------------
# Jaccard similarity on hashed shingles
hashed_jaccard <- expand.grid(record1 = seq_len(n), record2 = seq_len(n))

# don't need to compare the same things twice
hashed_jaccard <- hashed_jaccard[hashed_jaccard$record1 < hashed_jaccard$record2,]

time <- Sys.time() # see how long this takes
hashed_jaccard$similarity <- apply(hashed_jaccard, 1, function(pair) {
  jaccard_similarity(hashed_shingles[[pair[1]]], hashed_shingles[[pair[2]]])
}) # get jaccard for each hashed pair
time <- difftime(Sys.time(), time, units = "secs") # timing

## ----characteristic------------------------------------------
# return if an item is in a list
item_in_list <- function(item, list) {
  as.integer(item %in% list) 
}

# get the characteristic matrix
# items are all the unique hash values
# columns will be each record
# we want to keep track of where each hash is included 
char_mat <- data.frame(item = unique(unlist(hashed_shingles)))

# for each hashed shingle, see if it is in each row
contained <- lapply(hashed_shingles, function(col) {
  vapply(char_mat$item, FUN = item_in_list, FUN.VALUE = integer(1), list = col)
})

char_mat <- do.call(cbind, contained) # list to matrix
rownames(char_mat) <- unique(unlist(hashed_shingles)) # row names
colnames(char_mat) <- paste("Record", seq_len(nrow(dat))) # column names

# inspect results
kable(char_mat[10:15, 1:5])

## ----minhash-1-----------------------------------------------
# set seed for reproducibility
set.seed(02082018)

# function to get signature for 1 permutation
get_sig <- function(char_mat) {
  # get permutation order
  permute_order <- sample(seq_len(nrow(char_mat)))
  
  # get min location of "1" for each column (apply(2, ...))
  t(apply(char_mat[permute_order, ], 2, function(col) min(which(col == 1))))
}

# repeat many times
m <- 360
sig_mat <- matrix(NA, nrow=m, ncol=ncol(char_mat)) #empty matrix
for(i in 1:m) {
  sig_mat[i, ] <- get_sig(char_mat) #fill matrix
}
colnames(sig_mat) <- colnames(char_mat) #column names

# inspect results
kable(sig_mat[1:10, 1:5])

## ----jaccard-sig-------------------------------
# add jaccard similarity approximated from the minhash to compare
# number of agreements over the total number of combinations
hashed_jaccard$similarity_minhash <- apply(hashed_jaccard, 1, function(row) {
  sum(sig_mat[, row[["record1"]]] == sig_mat[, row[["record2"]]])/nrow(sig_mat)
})

# how far off is this approximation? plot differences
qplot(hashed_jaccard$similarity_minhash - hashed_jaccard$similarity) +
  xlab("Difference between Jaccard similarity and minhash approximation")

## ----banding---------------------------------------------
# view the signature matrix
print(xtable::xtable(sig_mat[1:10, 1:5]), hline.after = c(-1,0,5,10), comment=F)

## ----inclusion-probs----
# library to get divisors of m
library(numbers) 

# look at probability of binned together for various bin sizes and similarity values
bin_probs <- expand.grid(s = c(.25, .75), h = m, b = divisors(m))
bin_probs$prob <- apply(bin_probs, 1, function(x) lsh_probability(x[["h"]], x[["b"]], x[["s"]]))


# plot as curves
ggplot(bin_probs) +
  geom_line(aes(x = prob, y = b, colour = factor(s), group = factor(s)), size = 2) +
  geom_point(aes(x = prob, y = b, colour = factor(s)), size = 3) +
  xlab("Probability") +
  scale_color_discrete("s")
  

## ----show-package-lsh-----------------------------
# choose appropriate num of bands
b <- 90

# create the minhash function
minhash <- minhash_generator(n = m, seed = 02082018)

# build the corpus using textreuse
docs <- apply(dat, 1, function(x) paste(x[-1], collapse = " ")) # get strings
names(docs) <- dat$id # add id as names in vector
corpus <- TextReuseCorpus(text = docs, # dataset
                          tokenizer = tokenize_character_shingles, n = 3, simplify = TRUE, # shingles
                          progress = FALSE, # quietly
                          keep_tokens = TRUE, # store shingles
                          minhash_func = minhash) # use minhash

# perform lsh to get buckets
buckets <- lsh(corpus, bands = b, progress = FALSE)

# grab candidate pairs
candidates <- lsh_candidates(buckets)

# get Jaccard similarities only for candidates
lsh_jaccard <- lsh_compare(candidates, corpus, jaccard_similarity, progress = FALSE)

## ---- lsh-plot-----------------------------------------------------------
# plot jaccard similarities that are candidates
qplot(lsh_jaccard$score)

library(igraph) #graph package

# think of each record as a node
# there is an edge between nodes if they are candidates
g <- make_empty_graph(n, directed = FALSE) # empty graph
g <- add_edges(g, as.vector(t(candidates[, 1:2]))) # candidate edges
g <- set_vertex_attr(g, "id", value = dat$id) # add id

# get custers, these are the blocks
clust <- components(g, "weak") # get clusters
blocks <- data.frame(id = V(g)$id, # record id
                     block = clust$membership) # block number  
head(blocks)

