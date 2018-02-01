# record-linkage-tutorial

Some of Entity Resolution

Speakers (in order of speaking): 

Rebecca C. Steorts, Assistant Professor, Duke University 
https://resteorts.github.io/

Brenda Betancourt, Berstein-Forester Fellow, Duke University
https://www.brendabc.net/

Andee Kaplan, Postdoctoral Scholar, Duke University
http://andeekaplan.com/

Beidi Chen, PhD Student, Rice University
http://rush.rice.edu/team.html

Abstract

Very often information about social entities is scattered across multiple databases.  Combining that information into one database can result in enormous benefits for analysis, resulting in richer and more reliable conclusions.  Among the types of questions that have been, and can be, addressed by combining information include: How accurate are census enumerations for minority groups? How many of the elderly are at high risk for sepsis in different parts of the country? How many people were victims of war crimes in recent conflicts in Syria? In most practical applications, however, analysts cannot simply link records across databases based on unique identifiers, such as social security numbers, either because they are not a part of some databases or are not available due to privacy concerns.  In such cases, analysts need to use methods from statistical and computational science known as entity resolution (record linkage or de-duplication) to proceed with analysis.  Entity resolution is not only a crucial task for social science and industrial applications, but is a challenging statistical and computational problem itself. In this short course, we first provide an overview and introduction to entity resolution. Second, we provide an introduction to computational speed-ups, known as blocking or partitioning. Third, we introduce a sub-quadratic type of blocking — locality sensitive hashing — which allows one to place similar entities into blocks. Fourth, we illustrate how locality sensitive hashing can be used for unique estimating the number of documented identifiable deaths in a subset of the Syrian conflict using new methodology. Fifth, we provide an introduction to Bayesian entity resolution, which allows one to propagate the entity resolution error exactly into an subsequent process. In the workshop, demos will be given using open software. 

Overview of Workshop

TODO: everyone please put an abstract on your talk please no later than Friday. 

I. Overview and introduction to record linkage  
Speaker: Beka Steorts

Very often information about social entities is scattered across multiple databases. Combining that information into one database can result in enormous benefits for analysis, resulting in richer and more reliable conclusions. Among the types of questions that have been, and can be, addressed by combining information include: How accurate are census enumerations for minority groups? How many of the elderly are at high risk for sepsis in different parts of the country ? How many people were victims of war crimes in recent conflicts in Syria? In most practical applications, however, analysts cannot simply link records across databases based on unique identifiers, such as social security numbers, either because they are not a part of some databases or are not available due to privacy concerns. In such cases, analysts need to use methods from statistical and computational science known as record linkage (also called entity resolution or de-duplication) to proceed with analysis. Record linkage is not only a crucial task for social science and industrial applications, but is a challenging statistical and computational problem itself, because many databases contain errors (noise, lies, omissions, duplications, etc.), and the number of parameters to be estimated grows with the number of records. To meet present and near-future needs, record linkage methods must be flexible and scalable to large databases; furthermore, they must be able to handle uncertainty and be easily integrated with post-linkage statistical analyses, such as logistic regression or capture recapture. All this must be done while maintaining accuracy and low error rates.

II. Introduction to blocking  
Speaker: Brenda Betancourt 

III. Introduction to locality sensitive hashing (this is a fast way of blocking).   
Speaker: Andee Kaplan

IV. Introduction to unique entity estimation (this is a way of estimating entities that uses locality sensitive hashing)  
Speaker: Beka Steorts and Beidi Chen 

Entity resolution identifies and removes duplicate entities in large, noisy databases and has grown in both usage and new developments as a result of increased data availability. Nevertheless, entity resolution has tradeoffs regarding assumptions of the data generation process, error rates, and computational scalability that make it a difficult task for real applications. In this paper, we focus on a related problem of unique entity estimation, which is the task of estimating the unique number of entities and associated standard errors in a data set with duplicate entities. Unique entity estimation shares many fundamental challenges of entity resolution, namely, that the computational cost of all-to-all entity comparisons is intractable for large databases. To circumvent this computational barrier, we propose an efficient (near-linear time) estimation algorithm based on locality sensitive hashing. Our estimator, under realistic assumptions, is unbiased and has provably low variance compared to existing random sampling based approaches. In addition, we empirically show its superiority over the state-of-the-art estimators on three real applications. The motivation for our work is to derive an accurate estimate of the documented, identifiable deaths in the ongoing Syrian conflict. Our methodology, when applied to the Syrian data set, provides an estimate of 191,874±1772 documented, identifiable deaths, which is very close to the Human Rights Data Analysis Group (HRDAG) estimate of 191,369. Our work provides an example of challenges and efforts involved in solving a real, noisy challenging problem where modeling assumptions may not hold.

V. Introduction to Bayesian record linkage  
Speaker: Brenda Betancourt and Andee Kaplan

