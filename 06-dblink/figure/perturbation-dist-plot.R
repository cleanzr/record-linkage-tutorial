require(dplyr)
require(ggplot2)

theme_set(theme_bw() + theme(text = element_text(size = 9)))

# Use SHIW data
file.dir <- "/home/nmarchant/Dropbox/Employment/AMSIIntern ABS/experiments/shiw-data/"
file.name <- "comp.fixed.csv"
file.df <- read.csv(paste0(file.dir,file.name), 
                    stringsAsFactors = FALSE, colClasses = "character")

num.rec <- nrow(file.df)
# Use empirical distribution of IREG field as the base distribution
base.dist <- as.array(table(file.df$IREG)/num.rec)
support <- names(base.dist)

# Compute epsilon for updating the IREG field of an entity
dist.prob <- 0.1 # use high distortion probability so perturbation is not too strong
rec.values <- c("20", "11") # values of IREG for 2 records linked to the entity
epsilon <- replace(x = base.dist, values = 1.0)
for (x in rec.values) {
  temp <- 1 + (1/dist.prob - 1)/base.dist[x]
  epsilon[x] <- temp * epsilon[x]
}
epsilon <- epsilon - 1.0

# Construct perturbated component
pert.dist <- epsilon * base.dist
normC <- sum(pert.dist)

# Target distribution
target.dist <- 1/(1+normC) * base.dist + 1/(1+normC) * pert.dist

cat("Mixing weights:",1/(1+normC),"* base +", normC/(1+normC), "* perturbation.")

# Put distributions in data.frame for use with ggplot
dist.df <- data.frame(support = seq_along(support), 
                      target.dist = as.numeric(target.dist), 
                      pert.dist = as.numeric(pert.dist/normC), 
                      base.dist = as.numeric(base.dist))

ggplot(data = dist.df, aes(x = support, y = base.dist)) + 
  geom_col() + 
  xlab("Element index") + 
  ylab("Probability") + 
  ggtitle("Base component") + 
  theme_bw()

ggplot(data = dist.df, aes(x = support, y = target.dist)) + 
  geom_col() + 
  xlab("Element index") + 
  ylab("Probability") + 
  ggtitle("Target distribution") + 
  theme_bw()

ggplot(data = dist.df, aes(x = support, y = pert.dist)) + 
  geom_col() + 
  xlab("Element index") + 
  ylab("Probability") + 
  ggtitle("Perturbation component") + 
  theme_bw()

pdf("truncated-string-function.pdf", height = 1.8, width = 3.35)
ggplot(data = data.frame(x = numeric(0), y = numeric(0)), aes(x, y)) + 
  geom_segment(aes(x = 0.0, y = 0.0, xend = 0.75, yend = 0.0)) + 
  geom_segment(aes(x = 0.75, y = 0.0, xend = 1.0, yend = 1.0)) + 
  xlab(expression('sim'(v[1],v[2]))) + 
  ylab(expression(underline('sim')(v[1],v[2]))) + 
  scale_x_continuous(breaks = c(0.0, 0.75, 1.0), minor_breaks = NULL, labels=c("0", expression(s[cut]), expression(s[max]))) + 
  scale_y_continuous(breaks = c(0.0, 1.0), minor_breaks = NULL, labels=c("0", expression(s[max]))) +
  theme(axis.text = element_text(size=9))
dev.off()
