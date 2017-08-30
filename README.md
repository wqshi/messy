


## Predicting the impact of altered TF binding on gene expression based on cis-regulatory variants


###Overall structure of the code:

* ./deepsea/: scripts to calcualte the variantion impact on TF binding
* ./sailfish/: quantify the expression based on RNA-seq for each individual.
* ./python/: for each gene, collect the altered TF binding events for model training.
* ./R/: for each gene, build a regression model to predict gene expression based on the altered TF binding events
* ./results/: model performance and key features obtained from trained TF2Exp models
For more details, check the README file in each directory.
