

#This file is based on the gene_regulatory_fragment, the output of the p_assign_fragment_id_to_regions.


from pycallgraph import PyCallGraph
from pycallgraph.output import GraphvizOutput

from p_project_metadata import *

#reload(p_region_table)



def f_add_features_to_the_regulatory_regions(feature_name, feature_matrix_file, chr_str, hic_id_file, gene_regulatory_fragment_file, delete_file = True ):

    #import ipdb; ipdb.set_trace()
    # Assign the fragment ID to feature matrix file
    feature_table = region_table(feature_matrix_file)
    feature_table.subset_one_chr(new_file_name = 'assign_hic_id_to_%s' % feature_name, chr_str = chr_str)
 
    feature_overlap_data = feature_table.overlap_with_feature_bed(hic_id_file, value_col=3, value_name='hic_fragment_id')
    print sum(feature_overlap_data.duplicated())
    log('Size of feature_overlap_data', feature_overlap_data.shape)
    #log('Head of feature_overlap_data', feature_overlap_data.head())
    log('Before feature id merge, data size', feature_table.data.shape)
    feature_table.merge_feature(feature_overlap_data)#based on the chr and start.
    log('After feature id merge, data size', feature_table.data.shape)
    feature_table.show_size()
    feature_table.data['feature'] = feature_name
    feature_table.data.shape
    feature_table.data.sort_index(axis=1, ascending=False, inplace=True)
    #print feature_table.data.ix[0:50,0:8].drop_duplicates()
    
    #print sum(feature_table.data.duplicated())
    #Merge the feature data to gene_regulatory_regions accoding to the fragment ID
    gene_regulatory_fragment_table = region_table(gene_regulatory_fragment_file)
    print os.path.basename(gene_regulatory_fragment_file) + feature_name
    print gene_regulatory_fragment_table.file_path
    gene_regulatory_fragment_table.subset_one_chr(new_file_name = os.path.basename(gene_regulatory_fragment_file) + '.' + feature_name, chr_str = chr_str)
    #log('Head of gene_regulatory_fragment_table', gene_regulatory_fragment_table.data.head())

    feature_table.data.rename(columns={'start':'feature_start','end':'feature_end'}, inplace=True)
    #log('Head of feature_data', feature_table.data.head())
    gene_regulatory_fragment_table.merge_feature(feature_table.data, expected_cols = ['chr', 'hic_fragment_id'], check_index =False)  
    #logging.debug(gene_regulatory_fragment_table.data.head())


    #Return the overlapped data.
    sample_cols = my.grep_list('(NA|HG)[0-9]+', gene_regulatory_fragment_table.data.columns)
    overlapping_selection =   ~gene_regulatory_fragment_table.data.ix[:,sample_cols[0]].isnull()
    logging.debug('Non empty overlapping values: %s out of %s transcripts' % ( sum(overlapping_selection), gene_regulatory_fragment_table.data.shape[0]))

    if delete_file == True:
        #delete the tmp file for the data.
        feature_table.delete_file()
    gene_regulatory_fragment_table.delete_file()
    return gene_regulatory_fragment_table.data[overlapping_selection]
    

def f_combine_multiple_features_to_genes(feature_path_df, chr_str, hic_id_file, gene_regulatory_fragment_file, project_dir):

    feature_data_list = []
    shared_individuals = None
    #import ipdb; ipdb.set_trace()
    
    for feature_name in feature_path_df.index.values:

        #Assign the fragment ID to histones
        #feature_matrix_file = '%s/data/histone/%s_removeBlacklist_Log10PvalueThreshold_5_DATA_MATRIX' % (project_dir, feature_name)
        feature_matrix_file = feature_path_df.ix[feature_name,'path']

        if feature_name == 'RNASEQ':
            feature_table = region_table(feature_matrix_file)
            feature_table.subset_one_chr(new_file_name = 'assign_hic_id_to_%s' % feature_name, chr_str = chr_str)
            feature_table.data['hic_fragment_id'] = '.'
            feature_table.data['feature'] = feature_name
            feature_table.data['feature_start'] = feature_table.data['start']
            feature_table.data['feature_end'] = feature_table.data['end']
            feature_table.data['type'] = 'gene'
            feature_table.data.sort_index(axis=1, ascending=False, inplace=True)
            feature_table.data['NA12878'] = 1
            gene_feature_data = feature_table.data
        else:
            logging.info('Feature: %s\n' % feature_name)
            logging.info('File name %s\n' % feature_matrix_file)
            print(feature_matrix_file)
            gene_feature_data = f_add_features_to_the_regulatory_regions(feature_name, feature_matrix_file, chr_str, hic_id_file, gene_regulatory_fragment_file )

        if shared_individuals is None:
            shared_individuals =gene_feature_data.columns.values
            combined_feature_data = gene_feature_data
        else:
            shared_individuals = list(set(shared_individuals).intersection(set(gene_feature_data.columns.values)))
            combined_feature_data = pd.concat([ combined_feature_data.ix[:, shared_individuals], gene_feature_data.ix[:, shared_individuals] ])
        logging.debug('Length of the shared columns: %s' % len(shared_individuals))
        #feature_data_list.append(gene_feature_data)

    
    sample_cols = my.grep_list('(NA|HG)[0-9]+', shared_individuals)
    sample_cols.sort()
    none_sample_cols = list(set(shared_individuals) - set(sample_cols))
    #feature_data_list_shared = [ dataset[none_sample_cols + sample_cols] for dataset in feature_data_list ]
    combined_feature_data = combined_feature_data.ix[:, none_sample_cols + sample_cols]
    #import ipdb; ipdb.set_trace()

    combined_feature_data.drop_duplicates(cols = none_sample_cols, inplace = True)
    
    combined_feature_data.to_csv('%s/rnaseq/gene_regulatory_region_feature_profile.%s' % (project_dir, chr_str), sep = '\t')
    meta_data = combined_feature_data.ix[:, none_sample_cols]
    print 'Number of duplicated lines %s' % meta_data.duplicated().sum()
    
import random
import unittest
class TestDatabaseTable(unittest.TestCase):
    def setUp(self):
        a = 0
        
    def test_one_feature(self):
        feature_name = 'H3K27AC'
        feature_matrix_file = '%s/data/raw_data/histone/%s_removeBlacklist_Log10PvalueThreshold_5_DATA_MATRIX' % (project_dir, feature_name)
        chr_str = 'chr22'

        gene_regulatory_fragment_file = '%s/data/54samples_evalue/rnaseq/gene_regulatory_fragment.%s'  % (project_dir, chr_str)
        gene_regulatory_fragment_table = region_table(gene_regulatory_fragment_file)
        log('Head of gene_regulatory_fragment_table', gene_regulatory_fragment_table.head())

        #with PyCallGraph(output=GraphvizOutput()):
        combined_df = f_add_features_to_the_regulatory_regions(feature_name, feature_matrix_file, chr_str, hic_id_file, gene_regulatory_fragment_file, delete_file = False)
        print 'Finish the profile'
        
        combined_df.reset_index(inplace = True, drop = True)
        print combined_df.iloc[:,1:10].head()
        feature_df = pd.read_csv('%s/assign_hic_id_to_%s.%s'% ( os.path.dirname(feature_matrix_file), feature_name, chr_str ), sep = '\t', dtype = {'hic_fragment_id': object})
        i = 20379
        for i in random.sample(combined_df.index, 10):
        
            fragment_id = combined_df.ix[i, 'hic_fragment_id']
            transcript_id = combined_df.ix[i, 'gene']
        
            combined_subset = combined_df[(combined_df.gene == transcript_id) & (combined_df.hic_fragment_id == fragment_id)]
        
            print sum(feature_df.hic_fragment_id == fragment_id)
            
            feature_subset = feature_df[feature_df.hic_fragment_id == fragment_id]
            gene_df = gene_regulatory_fragment_table.data
            #log("gene_df", gene_df.head())
            gene_subset = gene_df[(gene_df.gene == transcript_id) & (gene_df.hic_fragment_id == fragment_id)]
            logging.info("Row %s, Combined %s = Gene %s * feature %s" %(i, combined_subset.shape[0], gene_subset.shape[0], feature_subset.shape[0]))
            assert combined_subset.shape[0] == gene_subset.shape[0] * feature_subset.shape[0]

               
if __name__ == "__main__":

    suite = unittest.TestLoader().loadTestsFromTestCase( TestDatabaseTable )
    unittest.TextTestRunner(verbosity=1,stream=sys.stderr).run( suite )

    parser = argparse.ArgumentParser(description='Extract the deepsea predictions of one tf.Deepsea prediction is sample based. The output of this script is TF based.')
    print '==========',__doc__

    if __doc__ is None:
        parser.add_argument("--chr",     help="The chr wanted to compute", default="chr22")
        parser.add_argument("--mode", help="Output type: test(only first 1000 variants); all(all the variants)", default="all")
        parser.add_argument('--batch_name', help = "462samples or 54samples", default = '462samples' )
        args = parser.parse_args()
        chr_num = args.chr
        mode_str = args.mode
        batch_name = args.batch_name
    else:
        chr_num = 'chr22'
        mode_str = 'all'
        #batch_name = '462samples_sailfish'
        #batch_name = '54samples'
        batch_name = 'test'
    chr_str = chr_num
    
    print "<--------------%s, %s, %s" % ( chr_str, batch_name, mode_str)
    
    batch_output_dir = f_get_batch_output_dir(batch_name)
    data_path_df = pd.read_csv('%s/output/data_path.csv'%batch_output_dir, sep = ' ', index_col = 0)
   
    tf_path_df = pd.read_csv('%s/output/tf_variation/%s/%s/data_path.csv'%(batch_output_dir, mode_str, chr_str), sep = ' ', index_col = 0)

    data_path_merge = pd.concat([data_path_df, tf_path_df])
    if batch_name == 'test':
        data_path_merge = data_path_merge.ix[0:6,:]
    print data_path_merge.head()
    gene_regulatory_fragment_file = '%s/rnaseq/gene_regulatory_fragment.%s'  % (batch_output_dir, chr_str)
    f_combine_multiple_features_to_genes(data_path_merge, chr_str, hic_id_file, gene_regulatory_fragment_file, batch_output_dir)





