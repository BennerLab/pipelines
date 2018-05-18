'''
Quick script to summarize gene expression.
'''
import sys
import pandas as pd
import functools

'''
Define a function  that can condense kallisto outputs into a single output file.
'''
def condense_gene_exp(output_dirs):
    count_dfs = []
    tpm_dfs = []
    for count_dir in output_dirs:
        #Load and format dataframes.
        df = pd.read_csv(count_dir + '/abundance.tsv', sep='\t')
        df.target_id = df.target_id.apply(lambda x: x.split('|')[0])

        colname = count_dir[9:]

        count_df = df[['target_id', 'est_counts']].copy()
        count_df.columns = ['Gene', colname]
        count_dfs.append(count_df)

        tpm_df = df[['target_id', 'tpm']].copy()
        tpm_df.columns = ['Gene', colname]
        tpm_dfs.append(tpm_df)

    count_df = functools.reduce(lambda left, right: pd.merge(left, right, on='Gene'), count_dfs)
    tpm_df = functools.reduce(lambda left, right: pd.merge(left, right, on='Gene'), tpm_dfs)

    return count_df,tpm_df

def main():

    #Grab output file names and the desired gene expression directories.
    count_name = sys.argv[1]
    tpm_name = sys.argv[2]
    gene_exp_dirs = sys.argv[3:]

    #Condense gene expression into dataframes.
    count_df,tpm_df = condense_gene_exp(gene_exp_dirs)
    count_df.to_csv(count_name, index=False, sep='\t')
    tpm_df.to_csv(tpm_name, index=False, sep='\t')

if __name__ == '__main__':
    main()