####################Using 462sample_log as base to fit the 462_peer model ####################################
#batch_name='462samples_quantile_rmNA'
#batch_name='445samples_sailfish'
batch_name='445samples_rareVar'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'

add_TF_exp_only='FALSE'
add_predict_tf='FALSE'
add_TF_exp_only='FALSE'
add_YRI='TRUE'
chr_str='chr22'
population='all'
TF_exp_type='fakeTF'
model='cv.glmnet'
add_gm12878='TRUE'
##new_batch='462samples_snyder_original'

new_batch='445samples_snyder_norm'
#new_batch='445samples_snyder_original'

#other_info='rmdup'#??
#other_info='hic8'#Filter enhacer regions with hic score 0.8
#other_info='rmCor'
other_info='normCor'
#other_info='lambda500'

test_flag='FALSE' 
 #binary
#chr_array=({22..1})
chr_array=(22 10 2)
#chr_array=(22)
add_penalty='TRUE'
for chr_num in ${chr_array[@]}
do
    chr_str='chr'$chr_num
    mode_list=('random' 'AlltfShuffle' 'SNP' 'all' 'TF' 'TFShuffle' 'SNPinTF' 'noInteract' 'fakeInteract')
    #mode_list=('All' 'SNP' 'SNPinTF' 'TF' 'AlltfShuffle' 'noInteract')
    #mode_list=('randomSNPinTF')
    #mode_list=('AlltfShuffle' 'AllsnpShuffle')
    mode_list=('All' 'TF' 'SNP')
    for new_batch_random in ${mode_list[@]}
    do
        sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_penalty $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type $add_gm12878 $new_batch $new_batch_random $other_info
    done
done

exit 0




############Compare the gm12878 corrected or not ######################
batch_name='462samples_log_quantile'
test_flag='FALSE' #binary
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'
add_predict_tf='FALSE'
add_TF_exp_only='FALSE'
add_YRI='TRUE'
chr_str='chr22'
population='all'
TF_exp_type='fakeTF'
model='glmnet'

add_gm12878='TRUE'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type $add_gm12878

add_gm12878='FALSE'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type $add_gm12878

exit 0

#####Run the GBM and randomForest ########
#batch_name='54samples_evalue'
batch_name='462samples_log_quantile'
test_flag='FALSE' #binary
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'
add_predict_tf='FALSE'
add_TF_exp_only='FALSE'
add_YRI='TRUE'
chr_str='chr22'
population='all'
TF_exp_type='fakeTF'

model='gbm'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type

model='enet'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type

model='glmnet'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type


exit 0


############Compare the performance of YRI subsets###################
#2016-03-10 10:17
test_flag='FALSE' #binary
model='glmnet'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'
add_predict_tf='FALSE'
add_YRI='TRUE'
chr_str='chr22'
model='enet'
add_miRNA='FALSE'
TF_exp_type='fakeTF'
batch_name='462samples_log_quantile'

population='29snyder'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type

population='54snyder'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type

population='29YRI'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type



exit 0
###############Run the permutated gene expression and 54 samples.###################################
#2016-03-10 10:17
test_flag='FALSE' #binary
model='enet'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'
add_predict_tf='FALSE'
add_YRI='TRUE'
chr_str='chr22'
population='all'
add_miRNA='FALSE'
TF_exp_type='fakeTF'
add_gm12878='FALSE'

batch_name='462samples_random'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type $add_gm12878


batch_name='54samples_evalue'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type

sleep 10
exit 0

##### Compare add random miRNA, random TF expression ########
#2016-03-10 10:17
batch_name='462samples_log_quantile'
test_flag='FALSE' #binary
model='glmnet'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='TRUE'
add_predict_tf='FALSE'
add_YRI='TRUE'
chr_str='chr22'
population='all'
model='glmnet'
add_miRNA='FALSE'

TF_exp_type='fakeTF'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type

TF_exp_type='miRNA'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population $TF_exp_type





##### Compare add miRNA, TF expression to the basic models ########
batch_name='462samples_log_quantile'
test_flag='FALSE' #binary
model='glmnet'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'
add_predict_tf='FALSE'
add_YRI='TRUE'
chr_str='chr22'
population='all'
model='glmnet'

add_miRNA='TRUE'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population

add_miRNA='FALSE'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population

add_miRNA='FALSE'
add_TF_exp_only='TRUE'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI $population

exit 0



#batch_name='462samples_quantile_rmNA'
batch_name='462samples_log_quantile'
test_flag='FALSE' #binary
model='glmnet'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'

add_YRI='FALSE'
chr_array=('chr22')

for chr_str in ${chr_array[@]}
do

    add_predict_tf='FALSE'
    add_TF_exp_only='FALSE'
    add_YRI='FALSE'
    sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI

    add_YRI='TRUE'
    add_predict_tf='FALSE'
    add_TF_exp_only='FALSE'
    sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI

    add_predict_tf='TRUE'
    add_TF_exp_only='FALSE'
    #sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf $add_YRI
   
done

exit 0

chr_str='chr11'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf

add_predict_tf='FALSE'
sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only $add_predict_tf

exit 0






#Compare the add_TF_exp_only options
#TRUE: the training data is TF concentration + population + gender
#FALSE: deepsea + TF interactions + TF concentration + population + gender.

batch_name='462samples_quantile_rmNA'
test_flag='FALSE' #binary
model='glmnet'
chr_str='chr22'
gene='gene'
add_miRNA='TRUE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='TRUE'

sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only



batch_name='462samples_quantile_rmNA'
test_flag='FALSE' #binary
model='glmnet'
chr_str='chr22'
gene='gene'
add_miRNA='TRUE'
add_TF_exp='FALSE'
add_permutation='FALSE'
add_TF_exp_only='FALSE'

sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation $add_TF_exp_only


exit 0

batch_name='462samples_quantile_rmNA'
test_flag='FALSE' #binary
model='glmnet'
chr_str='chr22'
gene='gene'
add_miRNA='TRUE'
add_TF_exp='TRUE'
add_permutation='FALSE'


#sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation 




batch_name='462samples_quantile_rmNA'
test_flag='FALSE' #binary
model='glmnet'
chr_str='chr22'
gene='gene'
add_miRNA='TRUE'
add_TF_exp='FALSE'
add_permutation='FALSE'


sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation 




batch_name='462samples_quantile_rmNA'
test_flag='FALSE' #binary
model='glmnet'
chr_str='chr22'
gene='gene'
add_miRNA='FALSE'
add_TF_exp='TRUE'
add_permutation='FALSE'

sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation 



batch_name='462samples_quantile_rmNA'
test_flag='FALSE' #binary
model='glmnet'
chr_str='chr22'
gene='gene'
add_miRNA='TRUE'
add_TF_exp='TRUE'
add_permutation='TRUE'


sh ./s_start_cluster_gene_job.sh $batch_name $test_flag $model $chr_str $gene $add_miRNA $add_TF_exp $add_permutation 

