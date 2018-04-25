#!/bin/bash
# this script runs the lab's chip-seq pipeline on a data set
# $1 = a directory with fastq files
# $2 = a project name
# this script should be run from the directory you wish your project folder to be found in
# this script is specifically for the hg38 genome

# usage: bash run_chip-seq-pipeline-hg38.sh -j=60 <int> </path/to/fastq/directory> <output_folder_name>

# command line arguments
jflag=60
hflag=''
input=''
output=''

while getopts 'j::hi:o:' flag; do
	case "${flag}" in
		j) jflag="$OPTARG" ;;
		h) printf "\nUSAGE: bash %s -j=%s -i </path/to/fastq/dir> -o <output_folder_name>\n" $0 $jflag
		   exit 0 ;;
		i) input="$OPTARG" ;;
		o) output="$OPTARG" ;;
		*) error "Unexpected option ${flag}"
		   exit 0 ;;
	esac
done

# output some parameter information
echo -e "Number of cores set: $jflag\n"
echo -e "Input fastq directory: $input\n"
echo -e "Output directory: $output\n"

# first we set up your project directory
echo -e "Setting up project directory ...\n"
mkdir $output && cd $output
bash /gpfs/data01/heinzlab/home/cag104/bin/setup_project_dir.sh

# we then copy fastq files and reference data to your data/raw_data directory
echo -e "Copying fastq files from $1 and loading hg38 reference information ...\n"
cp $input/*.fastq.gz data/raw_data/
cp /gpfs/data01/heinzlab/home/cag104/reference_data/Homo_sapiens/UCSC/hg38/genome.chrom.sizes data/raw_data
cp -r /gpfs/data01/heinzlab/home/cag104/reference_data/Homo_sapiens/UCSC/hg38/Sequence/Bowtie2Index data/raw_data

# we then run the pipeline on our data using snakemake and singularity environments
echo -e "Starting pipeline ...\n"
singularity run --bind data/:/scif/data /gpfs/data01/heinzlab/home/cag104/bin/chip-seq-pipeline/chip-seq-pipeline.simg run snakemake -j $jflag all

# clean up files
echo -e "Cleaning up workspace ...\n"
cp data/Snakefile Snakefile
cp data/config.yaml config.yaml
rm -r data/raw_data/Bowtie2Index
rm data/raw_data/genome.chrom.sizes
rm data/raw_data/*.fastq.gz
rm -r data/raw_data/fastp/
rm data/Snakefile
rm data/config.yaml
