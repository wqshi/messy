##This version is try to used OOB pro
setwd('~/expression_var/R/')
source('s_gene_regression_fun.R')
library(stringr)
source('s_project_funcs.R')
source('s_gene_data_class.R')
library(futile.logger)
library("optparse")
library(plyr)
library(dplyr)
source('~/R/s_ggplot2_theme.R')
flog.info('In OOB')
source('s_double_cv_glmnet.R')
option_list = list(
    make_option(c("--batch_name"),      type="character", default=NULL, help="dataset file name", metavar="character"),
    make_option(c("--add_histone"), type="character", default='FALSE', help="output file name [default= %default]", metavar="character"),
    make_option(c("--add_miRNA"), type="character", default='FALSE', help="Add miRNA or not", metavar="character"),
    make_option(c("--add_TF_exp"), type="character", default='FALSE', help="Add TF expression levels into the model or not", metavar="character"),
    make_option(c("--test"), type="character", default=NULL, help="output file name [default= %default]", metavar="character"),
    make_option(c("--gene"), type="character", default='', help="The name of gene", metavar="character"),
    make_option(c("--model"), type="character", default='cv.glmnet', help="The machine learning method used, eg. enet, and rfe", metavar="character"),
    make_option(c("--add_penalty"), type="character", default='TRUE', help="Penalty factors for regression", metavar="character"),
    make_option(c("--chr_str"), type="character", default='chr22', help="Chromosome name", metavar="character"),
    make_option(c("--add_TF_exp_only"), type="character", default='FALSE', help="Add TF expression as the input features", metavar="character"),
    make_option(c("--add_predict_TF"), type="character", default='FALSE', help="Add TF predicted expression as the input features", metavar="character"),
    make_option(c("--add_YRI"), type="character", default='FALSE', help="Whether to remove YRI population ", metavar="character"),
    make_option(c("--population"), type="character", default='None', help="Whether to remove YRI population ", metavar="character"),
    make_option(c("--TF_exp_type"), type="character", default='fakeTF', help="Read TF expression, faked TF, or random miRNA", metavar="character"),
    make_option(c("--add_gm12878"), type="character", default='TRUE', help="Whether to remove the GM12878 from the TF impact matrix", metavar="character"),
    make_option(c("--new_batch"), type="character", default='', help="Change the expression data to another batch", metavar="character"),
    make_option(c("--batch_mode"), type="character", default='TF', help="Change the expression data to another batch", metavar="character"),
    make_option(c("--other_info"), type="character", default='', help="Other information wanted to add to the name of result dir", metavar="character")
);


flog.info('Before the opt parse')
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

str(opt)
print(getwd())
if (is.null(opt$batch_name)){
    ##batch_name = '54samples_evalue'
    ##batch_name = '462samples_genebody'
    ##batch_name = '462samples_quantile_rmNA'
    ##batch_name = '445samples_sailfish'
    ##batch_name = '462samples_5k'
    ##batch_name = 'test'
    ##batch_name = '445samples_diff_snpOnly'
    ##batch_name = '445samples_rareVar'
    ##batch_name = '445samples_snpOnly'
    batch_name = '358samples_regionkeepLow'
    #batch_name = '358samples_regionkeepLowTss'
    #batch_name = '358samples_regionkeepLow'
    #batch_name = '358samples_regionkeepLow_rareVar'
    #batch_name = '445samples_region'
    add_histone = FALSE
    add_TF_exp = FALSE
    test_flag = TRUE
    tuneGrid = NULL
    ##train_model = 'rf'
    train_model = 'cv.glmnet'
    ##gene = 'ENSG00000235478.1'
    #gene = 'ENSG00000241973.6'# The gene with old recode and good accruacy
    ##gene='ENSG00000196576.10' : largest memory
    ##gene = 'ENSG00000093072.11' # Gene in the test dir.
    #gene = 'ENSG00000008735.10' #The first one in the chr22
    ##gene = 'ENSG00000128245.10' #gene with negative rsq in 462samples.
    ##gene = 'ENSG00000100321.10' #Gene with big difference when remove self interaction
    ##gene = 'ENSG00000184702.13' #with smaler size.
    gene = 'ENSG00000100376.7' #721Good performance with 0.6, with data in 800samples
    ##gene = 'ENSG00000243811.3' #The one with 0 TFs
    ##gene = 'ENSG00000138867.12'

    ##gene = 'ENSG00000100413.12' #max SNPinTF difference for 445samples_diff
    ##gene = 'ENSG00000244752.2' #max TF, TFsnpMatch for 445samples_region
    ##gene = 'ENSG00000025770.14'
    #gene = 'ENSG00000008735.10'
    #gene = 'ENSG00000179133.7'#The gene showing negative trad R2 (-254) in chr10.
 
    #gene = 'ENSG00000184117.7' # For plot, shows continious range of prediction socre.
    #gene = 'ENSG00000000003.10' #chrX gene
    #gene = 'ENSG00000187624.7' # chr17, best in TF
    #gene = 'ENSG00000186470.9' #chr6
    #gene = 'ENSG00000204632.7'
    #gene = 'ENSG00000124588.15' #Chr6 NQO2
    add_penalty = FALSE
    chr_str = 'chr22'
    #chr_str = 'chr6'
    add_TF_exp_only=FALSE
    add_predict_TF=FALSE
    add_YRI=FALSE
    select_pop= 'None' #'all'
    TF_exp_type = 'fakeTF'
    add_gm12878=TRUE
    ##new_batch='445samples_snyder_original'
    #new_batch='358samples_snyder_norm'
    new_batch='358samples_peer'
    #batch_mode = 'random'
    ##batch_mode = 'noInteract'
    #batch_mode = 'SNPinTF'
    ##batch_mode = 'TFsnpMatch'
    #batch_mode = 'TFaddInteract'
    ##batch_mode = 'fakeInteract'
    ##batch_mode = 'noInteract'
    #batch_mode = 'TFaddPenalty'
    #batch_mode = 'TFmiRNA'
    ##batch_mode = 'SNP'
    batch_mode = 'TF'
    #R2_method = 'traditional' #Global variable
    add_miRNA = grepl('miRNA', batch_mode)
    R2_method = 'corr' #Global variable
    #keepZero = TRUE
    #noInteract = FALSE
    nfolds = 10
    #elastic_net = FALSE
    #rmdup_flag = TRUE

    #other_info = 'corR2keepZeroPopPeerRmdupPU1'
    opt$other_info = 'corR2keepZeroPopPeerRmdup'
    
}else{
    batch_name = opt$batch_name
    add_histone = opt$add_histone == 'TRUE'
    add_miRNA = opt$add_miRNA == 'TRUE'
    add_TF_exp = opt$add_TF_exp == 'TRUE'
    add_penalty = opt$add_penalty == 'TRUE'
    test_flag = opt$test == 'TRUE'
    train_model = opt$model
    gene=opt$gene
    output_mode = opt$output_mode
    cat('Test flag :', test_flag, 'Model ', train_model, '\n')
    chr_str = opt$chr_str
    add_TF_exp_only=opt$add_TF_exp_only == 'TRUE'
    add_predict_TF= opt$add_predict_TF == 'TRUE'
    add_YRI = opt$add_YRI == 'TRUE'
    select_pop=opt$population
    TF_exp_type=opt$TF_exp_type
    add_gm12878=opt$add_gm12878 == 'TRUE'
    new_batch = opt$new_batch
    batch_mode = opt$batch_mode
    
    tuneGrid = tuneGridList[[train_model]]
    nfolds = 10
}


R2_method = ifelse( grepl('tradR2', opt$other_info), 'traditional', 'corr')
keepZero = ifelse( grepl('keepZero', opt$other_info), TRUE, FALSE) #Keep zero variance features
noInteract = ifelse( grepl('noInteract', opt$other_info), TRUE, FALSE) #Keep zero variance features
elastic_net = ifelse( grepl('Elastic', opt$other_info), TRUE, FALSE) #Keep zero variance features
rmdup_flag = ifelse( grepl('Rmdup', opt$other_info), TRUE, FALSE) #Keep zero variance features




target_col = 'gene.RNASEQ'
tuneGrid = tuneGridList[[train_model]]
flog.info('Begin')
model_str = 'all'
cat('Tune Grid is NULL:', is.null(tuneGrid), '\n')

                                        #The output directory and remove the old files.
output_dir = f_p('./data/%s/', batch_name)
opt_name = f_convet_opts_to_output_dir(opt)
results_dir = f_p('%s/rnaseq/%s/%s/', output_dir, chr_str, opt_name )
dir.create(results_dir, showWarnings = FALSE)
flog.info('Results dir: %s', opt_name)
flog.info('Batch mode %s', batch_mode)
old_files=list.files(results_dir, pattern = f_p('%s.*', gene), full.names = T)
file.remove(old_files)



if (!exists("test_gene") | T){
    test_gene <- GENE(data = data.frame(), gene_name = gene, chr_str = chr_str, batch_name = batch_name)
    test_gene$read_data()
    test_gene$subset_features_to_snp_contain_region(batch_mode, debug = F)

    test_individuals = test_gene$get_validation_samples(opt$other_info)
    
    batch_size = str_replace(batch_name, 'samples.*', '')
    test_batch_name=str_replace(batch_name, batch_size, '800')
    test_data_flag=test_gene$read_test_data(test_batch = test_batch_name, test_individuals = test_individuals, debug = F)
    sample_cols = test_gene$get_samples()
    test_gene$change_expression(new_batch, batch_mode)#change when batch_mode == random
    test_gene$hic_within_1Mb()
    test_gene$subset_snps_in_tf_regions(batch_mode, debug = F) #change data when batch_mode == SNPinTF
}

expression_data = test_gene$data

colnames(expression_data)

dim(test_gene$data)
remove(test_gene)

dim(expression_data)
#colnames(expression_data)

table(expression_data$type)

#subset(expression_data, type =='promoter')[,1:10]

genes_names = c(unique(expression_data$gene))
cat('The number of investigated transcripts:', length(genes_names), '\n')

sample_info = read.table(f_p('%s/chr_vcf_files/integrated_call_samples_v3.20130502.ALL.panel', output_dir ), header = TRUE, row.names = 1)

#Read the miRNA interaction and expression data.
#miRNA_expression = read.table('./data/raw_data/miRNA/GD452.MirnaQuantCount.1.2N.50FN.samplename.resk10.txt', header = TRUE)

non_sample_cols = setdiff(colnames(expression_data), sample_cols)
#sample_cols = intersect(sample_cols, colnames(miRNA_expression))

#Read the TF expression data.
tf_gene_id = read.table('./data/raw_data/rnaseq/tf_ensemble_id.txt', header = T, stringsAsFactors = FALSE)
rownames(tf_gene_id) = tf_gene_id$tf
expression_data$feature_tf =''
expression_data$feature_tf = (tf_gene_id[as.character(expression_data$feature),'external_name'])

#tf_gene_expression = f_get_TF_expression(output_dir, type = TF_exp_type)
#rownames(tf_gene_expression) = tf_gene_id$tf
flog.info('After load the data')


for (i in 1:length(genes_names)){
    
    transcript_id = genes_names[i]

    if (str_replace(transcript_id, pattern = '[.][0-9]+', replacement = '') %in% tf_gene_id$ensembl_gene_id){
        cat('Skip TF gene', transcript_id, '\n')
    }

    cat('\n','============',i, transcript_id, '==============','\n')
    transcript_data = expression_data[expression_data$gene == transcript_id,]
    head(transcript_data)
    dim(expression_data)
    #remove(expression_data)
    
    f_ASSERT(all(!duplicated(transcript_data[,1:30])), 'Duplicated features')

    dim(transcript_data)

    if (rmdup_flag){
        duplicated_rows=f_duplicated_rows(transcript_data[,c('feature', 'feature_start', 'feature_end', 'gene')])
        transcript_data[duplicated_rows,1:100]
        transcript_data <- transcript_data %>% dplyr::arrange(gene, -cor ) %>% distinct(feature, feature_start, feature_end, gene, .keep_all = T) %>% as.data.frame
        
    }
    
    table(transcript_data$type)
    rownames(transcript_data) = make.names(paste0(transcript_data$type, '-',transcript_data$feature), unique = T)
    transcript_data[is.na(transcript_data)]=0 #Some TF regions don't have variations 

    
    
    if(add_gm12878 == FALSE){
        transcript_data = f_correct_gm12878_bias(transcript_data, 'NA12872')
        flog.info('Remove NA12872 bias.')
        head10(transcript_data)
    }
    
    #######Add the TF concentration data#########
    if (add_TF_exp == TRUE){
        transcript_data_tf_concentration = transcript_data
        tmp=tf_gene_expression[as.character(transcript_data$feature),sample_cols]
        tmp[is.na(tmp)]=1 #Set the non-TF rows to 1
        scaled_tmp=t(apply(tmp, MARGIN = 1, FUN = function(X) (X - min(X))/diff(range(X))) + 1)
        scaled_tmp[is.na(scaled_tmp)] = 1 #For the DNASE regions.
        
        #transcript_data = transcript_data[!duplicated(transcript_data[, non_sample_cols[1:8]]),]
        transcript_data_tf_concentration = transcript_data
        transcript_data_tf_concentration[, sample_cols] = transcript_data[, sample_cols] * scaled_tmp[, sample_cols]
    }
    
    ##Add TF-TF interactions
    #change when batch mode == noInteract, and fakeInteract
    #train_data_raw <- f_add_tf_interactions_old2(transcript_data, batch_mode = batch_mode, debug = F) #only for fakeInteraction
    
    #train_data_raw <- f_add_tf_interactions_old2(transcript_data, batch_mode = batch_mode, debug = F)
    if (noInteract){
        train_data_raw = transcript_data
    }else{
        train_data_raw <- f_add_tf_interactions(transcript_data, batch_mode = batch_mode, hic_thres = NA, debug = F)
    }
    
    table(train_data_raw$type)

    
    colnames(train_data_raw[,1:20])
    train_data = f_sort_by_col(train_data_raw, 'cor', decr_flag = T)[,sample_cols]
    train_data[is.na(train_data)] = 0
    
    #train_data_rmdup = train_data[!duplicated(train_data),]
    train_data_rmdup = train_data
    flog.info('Remove duplicated features: before %s now %s', nrow(train_data), nrow(train_data_rmdup))
    
    
    if (FALSE){
        ##write.table(train_data, 'train_data', quote = F, sep='\t')
        ##write.table(train_data_rmdup, 'train_data_rmdup', quote = F, sep='\t')
        debug_train = read.table('train_data', sep='\t', header = T)
        debug_rmdup = read.table('train_data_rmdup', sep='\t', header = T)

        input_data =train_data
        row_index = "enhancer.POL2.7"

        diff_rows = f_find_identical_rows(input_data, input_data[row_index,] )
        diff_row_names = names(diff_rows)[diff_rows]
        print(diff_row_names)

        f_find_identical_rows(train_data[diff_row_names,], train_data[row_index,])
        f_find_identical_rows(debug_train[diff_row_names,], debug_train[row_index,])

        rowSums(train_data[diff_row_names,] == 0)
        rowSums(debug_train[diff_row_names,] == 0)

        train_data_raw[row_index,1:30]
    
        dim(debug_train)
        dim(train_data)
        dim(debug_rmdup)
        dim(train_data_rmdup)
    
        setdiff(rownames(debug_rmdup) , rownames(train_data_rmdup))
        setdiff(rownames(train_data_rmdup), rownames(debug_rmdup) )
    }
    
    
    
    removed_data = train_data[duplicated(train_data), ]
    f_input_stats(t(removed_data), batch_mode = batch_mode)
    
    
    train_data2 = as.data.frame(t(train_data_rmdup))
    dim(train_data2)
    
    if (add_histone == FALSE){
        none_histone_cols = grep('H3K',colnames(train_data2), value = TRUE, invert = TRUE)
        final_train_data = train_data2[, none_histone_cols]
    }else{
        final_train_data  = train_data2
    }
    dim(final_train_data)
    colnames(final_train_data)
    if(add_miRNA == TRUE){
        final_train_data = f_add_related_miRNAs(transcript_id, final_train_data, debug = F)
        sample_cols = rownames(final_train_data)
    }
    ##Make a TF concentration only model.
    dim(final_train_data)
    #str(tf_expression)
    if (add_TF_exp_only == TRUE){
        tf_expression = data.frame(t(tmp[, rownames(final_train_data) ]))
        tf_expression = tf_expression[,!duplicated(t(tf_expression))]
        cat('======== TF expression only========\n')
        tf_expression$gene.RNASEQ = final_train_data[rownames(tf_expression), 'gene.RNASEQ']
        final_train_data_bak= final_train_data
        final_train_data = tf_expression
        colnames(tf_expression)
    }else if(add_TF_exp == TRUE){
        #tf_expression = data.frame(t(tmp[, rownames(final_train_data) ]))
        cat('======== add TF expression========\n')
        final_train_data_bak= final_train_data
        #final_train_data= final_train_data_bak
        final_train_data = cbind(final_train_data, tf_expression)
    }else{
        final_train_data = final_train_data
    }

    
    dim(final_train_data)
    #Add predicted TF expression
    f_input_stats(final_train_data, batch_mode)
    grep('enhancer',colnames(final_train_data), value = T)
    f_input_stats(train_data2, batch_mode)
    final_train_data_TFexp = f_add_predicted_TF_expression(add_predict_TF, batch_name, final_train_data)
    final_train_data_filter <- f_filter_training_features(final_train_data_TFexp, batch_mode, target_col, debug = F)
    dim(final_train_data_TFexp)
    #AlltfShuffle <- f_filter_training_features(final_train_data_TFexp, 'AlltfShuffle', target_col, debug = F)
    #TF <- f_filter_training_features(final_train_data_TFexp, 'TF', target_col, debug = F)   

    
    #rownames(AlltfShuffle)
    
    #TF$gene.RNASEQ != AlltfShuffle$gene.RNASEQ
    
    flog.info('After add other feature data')
    f_ASSERT(all(final_train_data_filter[target_col] == final_train_data_TFexp[target_col]), 'Expression Altered')
    #final_train_data_filter <- f_filter_training_features(final_train_data_bak, 'SNP', target_col, debug = F )
    #final_train_data_filter <- f_filter_training_features(final_train_data_bak, 'TF', target_col, debug = F )
    #final_train_data_filter <- f_filter_training_features(final_train_data_bak, 'All', target_col, debug = F )
    #final_train_data_filter <- f_filter_training_features(final_train_data_bak, 'SNPinTF', target_col, debug = F )
    remove(final_train_data_TFexp)

    
    #Add population information
    obj<-f_get_test_data(empty_data = TRUE)
    obj$data = final_train_data_filter
    final_train_data_pop <- f_add_population_and_gender(obj, add_YRI, select_pop, debug = F)
    final_data = f_change_category_data(final_train_data_pop, target_col)
    dim(final_train_data_pop)
    
    train_samples = grep('^t_', rownames(final_train_data_pop), invert = T, value = T)
    test_samples = grep('^t_', rownames(final_train_data_pop), invert = F, value = T)
    flog.info('Train sample size: %s', length(train_samples))
    final_train_data = final_data[intersect(train_samples, rownames(final_data)),]
    #f_plot_cor_heatmap(final_train_data[, grep('SNP', colnames(final_train_data), invert = T, value =T)], 'heatmap.noSNP.tif')
    
    additional_cols  =grep('gender|hsa-miR|population', colnames(final_train_data), value = TRUE)
    additional_data =transcript_data[rep('gene.RNASEQ', length(additional_cols)),]
    rownames(additional_data) = additional_cols
    additional_data[,sample_cols] = t(final_train_data[sample_cols, additional_cols])
    transcript_data = rbind(transcript_data, additional_data)

    
    dim(train_data_raw)
    #For TF interactions, it will add penalty as well accoding to the cor value of the interaction terms.
    penalty_factors = f_add_penalty_factor(final_train_data, train_data_raw, add_penalty|batch_mode == 'TFaddPenalty', debug = FALSE)
    flog.info('Penalty factors %s', length(penalty_factors))
    print(head(penalty_factors))
    f_ASSERT(all(!is.infinite(penalty_factors) & !is.na(penalty_factors)), 'Penalty error')
    
    library(gplots)
    dim(final_train_data)
    #heatmap.2(as.matrix(abs(final_train_data)), Rowv = TRUE, Colv =TRUE, trace='none', scale = 'none' )

    f_input_stats(final_train_data, batch_mode)
    
    dim(final_train_data)
    output_figure_path = f_p('%s/%s.learn.curve.tiff',  results_dir, gene)
    

    result <- try(
        fit  <- f_caret_regression_return_fit(my_train = final_train_data, target_col = 'gene.RNASEQ', learner_name = train_model, tuneGrid, output_figure_path,
                                              penalty_factors = penalty_factors, nfolds = nfolds, rm_high_cor = FALSE, keepZero = keepZero, lasso = !elastic_net, debug = F)
       ,silent=TRUE)

    #ear_zero_columns = colnames(final_train_data)[abs(apply(final_train_data, 2, mean)) < 0.01]
    #pply(final_train_data[, near_zero_columns], 2, mean)
    #plot(fit$finalModel$glmnet.fit)
    #inal_train_data[, 'enhancer.PAX5.C20.4']
    if (class(result) == "try-error"){
        print(result)
        
        cat('Error in ', transcript_id, '\n')
        next
    }

    #plot(fit$finalModel)
        
    mean_prediction <- as.data.frame(fit$pred %>% group_by(as.factor(rowIndex)) %>% dplyr::summarise(pred = mean(pred), obs = mean(obs)))
    rownames(mean_prediction) = rownames(final_train_data)
    mean_prediction$population = final_train_data_pop[train_samples, 'population']
    colnames(mean_prediction)
    head(mean_prediction)
    # don't work because scale in side of the
    #f_ASSERT(all(final_train_data$gene.RNASEQ == mean_prediction$obs), 'Error in retrieve gene expression') 

    
    grep('promoter', colnames(final_train_data), value = TRUE)
    #Write the mean prediction for each TF genes.
    if (chr_str == 'chrTF'){
        cat('load TF predictions \n')
        pred_file = f_p('%s/%s.enet.pred',  results_dir, gene)
        pred = t(mean_prediction['pred'])
        write.table(cbind(transcript_id, pred), file = pred_file, sep = '\t', quote=FALSE, row.names = FALSE)
    }

    if (fit$max_performance > 0.4){
        a=f_plot_model_data(mean_prediction, plot_title = f_p('%s \n R-squared: %.2f', transcript_id, fit$max_performance),
                            save_path = f_p('%s/%s.enet.tif', results_dir, transcript_id), debug = T)
        if (gene == "ENSG00000186470.9"){
            high_gene_plot <-ggplot(mean_prediction, aes(x = pred, y = obs)) + geom_point() + xlim(range(mean_prediction$obs)) +
        theme_Publication(base_size = 14) + xlab('Predicted gene expression by TF2Exp') + ylab('Observed gene expression')
        }
        
    
        
    }

    external_list = f_test_in_other_pop(fit, final_data, test_samples, train_samples, batch_name, debug = T)


    cor_nums = external_list$cor_stats
    cor_nums
    f_parse_key_features_report_performance(fit, transcript_data, transcript_id, results_dir, transcript_id, cor_nums, debug = F)

}


#key_features = data.frame(feature = names(fit$key_features), coef = fit$key_features) %>% filter(coef != 0 , feature != '(Intercept)')


print(warnings())
f_debug <-function(){
    source('s_gene_regression_fun.R')
    result <- try(
        fit  <- f_caret_regression_return_fit(my_train = final_train_data, target_col = 'gene.RNASEQ', learner_name = train_model, tuneGrid, output_figure_path,
                                              penalty_factors = penalty_factors, nfolds = nfolds, rm_high_cor = FALSE, keepZero = keepZero, debug = T)
       ,silent=TRUE)
}


# data <-transcript_data %>% filter( type %in% c('promoter', 'enhancer') ) %>% select( matches('NA.*') ) %>% as.data.frame
#
#
#
# a = as.numeric(as.vector(as.matrix(data)))
#hist(  log(abs(a[a>0])))


