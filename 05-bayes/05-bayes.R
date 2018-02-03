## ----libraries -----------------
library(knitr)
library(ggplot2)

## ----data -----------------------------------------------------
library(blink) # load blink library
library(RecordLinkage) # load data library
data("RLdata500") # load data
head(RLdata500) # take a look

# categorical variables
X.c <- as.matrix(RLdata500[, c("by","bm","bd")]) 

# string variables 
X.s <- as.matrix(RLdata500[, c("fname_c1", "lname_c1")]) 

# keep track of which rows of are in which files
file.num <- rep(c(1, 2, 3), c(200, 150, 150))

# Subjective choices for distortion probability prior
# parameters of a Beta(a,b)
a <- 1
b <- 999

# string distance function example
d <- function(s1, s2) {
  adist(s1, s2) # approximate string distance
}

# steepness parameter
c <- 1

lam.gs <- rl.gibbs(file.num = file.num, # file
                   X.s = X.s, X.c = X.c, # data 
                   num.gs = 100000, # iterations
                   a = a, b = b, # prior params
                   c = c, d = d, # distortion
                   M = 500) # max # latents

## ----get-estimates-sizes----------------------
# count how many unique latent individuals
size_est <- apply(lam.gs, 1, function(x) { 
  length(unique(x)) 
  })

## ----plots--------------
theme_set(theme_bw(base_family = "serif", base_size = 15))

ggplot() +
  geom_line(aes(1:100000, size_est)) +
  xlab("Iteration") +
  ylab("Estimated size")

ggplot() +
  geom_histogram(aes(size_est[-(1:25000)])) +
  geom_vline(aes(xintercept=450), colour = "red") +
  geom_vline(aes(xintercept=mean(size_est[-(1:25000)])), lty=2) +
  xlab("Estimated size") +
  xlim(c(400, 500))
  

# estimated pairwise links
est_links_pair <- pairwise(links(lam.gs[-(1:25000), ]))

# true pairwise links
true_links_pair <- pairwise(links(matrix(identity.RLdata500, nrow = 1)))

#comparison
comparison <- links.compare(est_links_pair, true_links_pair, counts.only = TRUE)

# precision
precision <- comparison$correct/(comparison$incorrect + comparison$correct)

# recall
recall <- comparison$correct/(comparison$correct + comparison$missing)


# results
c(precision, recall)

## ---- Your turn -------------------------
# 1. complete cases of data onl
# load data
library(RLdata)
data("cora")
data("cora_gold")

not_missing <- complete.cases(cora[, c("year", "journal", "title", "authors")])

# 2. formatting data 
# categorical variables
X.c <- as.matrix(cora[not_missing, c("year","journal")]) 

# string variables 
X.s <- as.matrix(cora[not_missing, c("title", "authors")]) 

# keep track of which rows of are in which files
file.num <- rep(c(1, 2, 3), c(200, 200, 160))

# 3. hyperparameters

# Subjective choices for distortion probability prior
# parameters of a Beta(a,b)
a <- 1
b <- 999

# string distance function example
d <- function(s1, s2) {
  adist(s1, s2) # approximate string distance
}

# steepness parameter
c <- 1

# 4. run the gibbs sampler
lam.gs <- rl.gibbs(file.num = file.num, # file
                   X.s = X.s, X.c = X.c, # data 
                   num.gs = 10, # iterations
                   a = a, b = b, # prior params
                   c = c, d = d, # distortion
                   M = nrow(X.s)) # max # latents


# 5. (extra) evaluation

# estimated pairwise links
est_links_pair <- pairwise(links(lam.gs))

# true pairwise links, only for those included
# get true number
included_idx <- seq_len(sum(not_missing)) 
names(included_idx) <- cora[not_missing, "id"]
included_pairs <- subset(cora_gold, id1 %in% names(included_idx) & id2 %in% names(included_idx))

# get index for graphmaking
included_pairs <- apply(included_pairs, 2, function(col) {
  names <- as.character(col)
  included_idx[names]
})

# need list of pairs to compare
true_links_pair <- split(included_pairs, seq(nrow(included_pairs)))

#comparison
comparison <- links.compare(est_links_pair, true_links_pair, counts.only = TRUE)

# precision
precision <- comparison$correct/(comparison$incorrect + comparison$correct)

# recall
recall <- comparison$correct/(comparison$correct + comparison$missing)


# results
c(precision, recall)

# count how many unique latent individuals
size_est <- apply(lam.gs, 1, function(x) { 
  length(unique(x)) 
  })


# get true number of individuals by using graph clusters
library(igraph)
g <- make_empty_graph(length(included_idx))
g <- add_edges(g, as.vector(t(included_pairs)))
clust <- components(g, "weak")

# plots of results
theme_set(theme_bw(base_family = "serif", base_size = 30))

ggplot() +
  geom_line(aes(1:10, size_est)) +
  xlab("Iteration") +
  ylab("Estimated size")

ggplot() +
  geom_histogram(aes(size_est)) +
  geom_vline(aes(xintercept=clust$no), colour = "red") +
  geom_vline(aes(xintercept=mean(size_est)), lty=2) +
  xlab("Estimated size")
  

