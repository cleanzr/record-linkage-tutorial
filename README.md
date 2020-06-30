# Some of Entity Resolution

## Speakers/Contributors

Rebecca C. Steorts, Assistant Professor, Duke University 
https://resteorts.github.io/

Brenda Betancourt, Assistant Professor, University of Florida
(Former Foerster-Bernstein Postdoctoral Fellow, Duke University)
https://www.brendabc.net/

Andee Kaplan, Assistant Professor, Colorado State University 
(Former Postdoctoral Scholar, Duke University)
http://andeekaplan.com/

Neil Marchant, PhD Student, University of Melbourne 
https://github.com/ngmarchant

Beidi Chen, PhD Student, Rice University
http://rush.rice.edu/team.html

Acknowledgements: We would like to thank Olivier Binette (PhD student, Duke University) for identifying typos and improving the quality of this tutorial. 

## Abstract

Very often information about social entities is scattered across multiple databases.  Combining that information into one database can result in enormous benefits for analysis, resulting in richer and more reliable conclusions.  Among the types of questions that have been, and can be, addressed by combining information include: How accurate are census enumerations for minority groups? How many of the elderly are at high risk for sepsis in different parts of the country? How many people were victims of war crimes in recent conflicts in Syria? In most practical applications, however, analysts cannot simply link records across databases based on unique identifiers, such as social security numbers, either because they are not a part of some databases or are not available due to privacy concerns.  In such cases, analysts need to use methods from statistical and computational science known as entity resolution (record linkage or de-duplication) to proceed with analysis.  Entity resolution is not only a crucial task for social science and industrial applications, but is a challenging statistical and computational problem itself. In this short course, we first provide an overview and introduction to entity resolution. Second, we provide an introduction to computational speed-ups, known as blocking or partitioning. Third, we introduce a sub-quadratic type of blocking - locality sensitive hashing - which allows one to place similar entities into blocks. Fourth, we illustrate how locality sensitive hashing can be used for unique estimating the number of documented identifiable deaths in a subset of the Syrian conflict using new methodology. Fifth, we provide an introduction to Bayesian entity resolution, which allows one to propagate the entity resolution error exactly into an subsequent process. In the workshop, demos will be given using open source software. 

Remark: This workshop is meant to be a one or two day workshop, however, it can be tailored into a shorter workshop quite easily. The full workshop is presented below as it is intended. 

## Overview of Workshop

### 0. Setup (Michigan)

In order to make sure that you are able to run all demos for the workshop, please make sure that 

1. You have the latest version of R installed on your laptop. 
2. You run the following scripts, which will be needed for all `R' demos:
https://github.com/resteorts/record-linkage-tutorial/blob/master/00-setup/packages_install.R


### I. Overview and introduction to entity resolution (Michigan)
Speaker: Rebecca C. Steorts

Writer of Materials: Andee Kaplan and Rebecca C. Steorts

Very often information about social entities is scattered across multiple databases. Combining that information into one database can result in enormous benefits for analysis, resulting in richer and more reliable conclusions. Among the types of questions that have been, and can be, addressed by combining information include: How accurate are census enumerations for minority groups? How many of the elderly are at high risk for sepsis in different parts of the country ? How many people were victims of war crimes in recent conflicts in Syria? In most practical applications, however, analysts cannot simply link records across databases based on unique identifiers, such as social security numbers, either because they are not a part of some databases or are not available due to privacy concerns. In such cases, analysts need to use methods from statistical and computational science known as record linkage (also called entity resolution or de-duplication) to proceed with analysis. Record linkage is not only a crucial task for social science and industrial applications, but is a challenging statistical and computational problem itself, because many databases contain errors (noise, lies, omissions, duplications, etc.), and the number of parameters to be estimated grows with the number of records. To meet present and near-future needs, record linkage methods must be flexible and scalable to large databases; furthermore, they must be able to handle uncertainty and be easily integrated with post-linkage statistical analyses, such as logistic regression or capture recapture. All this must be done while maintaining accuracy and low error rates.

Slide deck: https://github.com/resteorts/record-linkage-tutorial/blob/master/01-intro/record-linkage-intro.pdf

Suggested reading: Christen (2012), Fellegi and Sunter (1969). 

Videos: 
- https://github.com/cleanzr/record-linkage-tutorial/blob/master/01-intro/videos/intro-to-er-part1.mp4
- https://github.com/cleanzr/record-linkage-tutorial/blob/master/01-intro/videos/intro-to-er-partII.mp4

### II. Introduction to traditional record linkage and blocking (Michigan)
Speaker: Rebecca C. Steorts 

Writer of Materials: Brenda Betancourt and Rebecca C. Steorts

There are two main types of linkage algorithms: deterministic and probabilistic. Choosing the best algorithm to use in a given situation depends on many interacting factors including time, resources, and the quantity and quality of the available data  to be able to identify an individual uniquely. With this in mind, it is important to be equipped with data linkage algorithms for varying scenarios. Deterministic algorithms determine whether record pairs agree or disagree on a given set of identifiers, and the match status for a pair of records can be assessed in a single step or in multiple steps. The deterministic approach ignores the fact that data can be noisy and certain identifiers have more discriminatory power than others do. On the other hand, probabilistic techniques assess the discriminatory power of each identifier and the likelihood that two records are a true match based on levels of agreement on the various identifiers. In this section we introduce the Fellegi-Sunter approach which is the most popular probabilistic method for record linkage and work through a example with real data using `R`. In addition, we discuss and show examples of traditional blocking techniques used to reduce computation time and memory consumption by only comparing records that agree on values for a subset of attributes, called blocking fields.

Slide deck: https://github.com/resteorts/record-linkage-tutorial/blob/master/02-blocking/blocking.pdf

Videos:

- https://github.com/cleanzr/record-linkage-tutorial/blob/master/02-blocking/videos/blocking-partI.mp4
- https://github.com/cleanzr/record-linkage-tutorial/blob/master/02-blocking/videos/blocking-partII.mp4

Suggested reading: Steorts, Ventura, Sadinle, Fienberg (2014); Steorts and Shrivastava (2018).


### III. Introduction to locality sensitive hashing (this is a fast way of blocking).   
Speaker: Andee Kaplan

Writer of Materials: Andee Kaplan 

In this section we will introduce a sub-quadratic type of blocking - locality sensitive hashing - which allows one to place similar entities into blocks. This is a fast way to create blocks of data that will allow for record linkage methods to be used in parallel for each block. We focus mainly on how to speed up block creation through the use of minwise hashing and densified one permutation hashing as an initial step in the record linkage process. In this section we will focus on understanding the basic ideas behind locality sensitive hashing as well as get some hands on experiences using the methods in `R`. The goal of this hour is to provide background on a fast way to create blocks of data, which can then be used for record linkage.

Slide deck: https://github.com/resteorts/record-linkage-tutorial/blob/master/03-lsh/03-lsh.pdf

Suggested reading: Mining Massive Datasets (http://www.mmds.org/); Steorts, Ventura, Sadinle, Fienberg (2014); Steorts and Shrivastava (2018).

### IV. Introduction to unique entity estimation (this is a way of estimating entities that uses locality sensitive hashing)  
Speaker: Beidi Chen and Rebecca C. Steorts 

Writer of Materials: Beidi Chen and Rebecca C. Steorts

Entity resolution identifies and removes duplicate entities in large, noisy databases and has grown in both usage and new developments as a result of increased data availability. Nevertheless, entity resolution has tradeoffs regarding assumptions of the data generation process, error rates, and computational scalability that make it a difficult task for real applications. In this paper, we focus on a related problem of unique entity estimation, which is the task of estimating the unique number of entities and associated standard errors in a data set with duplicate entities. Unique entity estimation shares many fundamental challenges of entity resolution, namely, that the computational cost of all-to-all entity comparisons is intractable for large databases. To circumvent this computational barrier, we propose an efficient (near-linear time) estimation algorithm based on locality sensitive hashing. Our estimator, under realistic assumptions, is unbiased and has provably low variance compared to existing random sampling based approaches. In addition, we empirically show its superiority over the state-of-the-art estimators on three real applications. The motivation for our work is to derive an accurate estimate of the documented, identifiable deaths in the ongoing Syrian conflict. Our methodology, when applied to the Syrian data set, provides an estimate of 191,874±1772 documented, identifiable deaths, which is very close to the Human Rights Data Analysis Group (HRDAG) estimate of 191,369. Our work provides an example of challenges and efforts involved in solving a real, noisy challenging problem where modeling assumptions may not hold.

Slide deck: https://github.com/resteorts/record-linkage-tutorial/blob/master/04-uee/record_linkage-unique-entity-estimation.pdf

Suggested reading: Chen, Shrivastava, Steorts (2018)

### V. Introduction to Bayesian Entity Resolution (Michigan)
Speaker: Rebecca C. Steorts

Writer of Materials: Brenda Betancourt, Andee Kaplan, and Rebecca C. Steorts

There are many methods of record linkage currently proposed in the literature and used in practice. In this section of the workshop, we introduce methods for Bayesian entity resolution. One of the benefits of using a Bayesian method is that it allows propagation of the entity resolution error exactly into an subsequent process. We will give an overview of the literature and detail a particular class of models - Bayesian graphical record linkage models. Additionally, we will work through some exercises with real datasets using an `R` package that performs this Bayesian analysis and get experience with tuning, setting prior parameters, and evaluation of the methods.

Slide deck: https://github.com/resteorts/record-linkage-tutorial/blob/master/05-bayes/05-bayes.pdf

Demo: https://github.com/resteorts/record-linkage-tutorial/blob/master/05-bayes/05-bayes.R

Videos: 

- https://github.com/cleanzr/record-linkage-tutorial/blob/master/05-bayes/videos/intro-to-bayes-part1.mp4
- https://github.com/cleanzr/record-linkage-tutorial/blob/master/05-bayes/videos/intro-to-bayes-partII.mp4

Suggested reading: Steorts, Hall, Fienberg (2014, 2016), Steorts (2015), blink package (CRAN or github). 

### VI. Distributed Bayesian Entity Resolution (Michigan)
Speaker: Rebecca C. Steorts

Writer of Materials: Neil Marchant and Rebecca C. Steorts

While there have been many Bayesian record linkage methods proposed in the literature, none of these methods scale to industrial sized data sets. In fact, none of these methods scale to data sets beyond 5,000 records. In this section of the workshop, we introduce distributed methods for Bayesian entity resolution (dblink). More specifically, we give an overview of a recent method of Marchant, et. al (2019), which proposes the first scalable and distributed end-to-end Bayesian model for entity resolution, which propagates uncertainty in blocking, matching, and merging. In addition, several contributions are made including: (i) incorporating probabilistic blocking directly into the model through auxiliary partitions; (ii) support for missing values; (iii) a partially-collapsed Gibbs samper; and (iv) a novel perturbation sampling algorithm  that enables fast updates of the entity attributes. In this workshop, we will present dblink in a more simple setting for intuition, and provide intuition for computational speed ups. Finally, we illustrate experimental results on dblink 
on five synthetic and real data, which show that d-blink can achieve significant efficiency gains—in excess of 200×—when compared to existing methodology. A short demo will be covered in Apache Spark and feedback is greatly appreciated! 

Slide deck: https://github.com/resteorts/record-linkage-tutorial/blob/master/06-dblink/06-dblink.pdf

Video: https://github.com/cleanzr/record-linkage-tutorial/blob/master/06-dblink/videos/intro-to-dblink.mp4

Suggested reading: Slide deck. (Paper and software is coming soon). 

Kaplan, Betancourt, and Steorts have been funded for this work under NSF CAREER Award. Betancourt would like to thank the Foerster-Bernstein Fellowship and Duke University for support of this work. In addition, Steorts has been funded for this work under NICHD Center Grant P2CHD041028. The ideas of this project are of the researchers and not of the funding organization. 

