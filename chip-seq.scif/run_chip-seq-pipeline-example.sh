#!/bin/bash
# this script runs the lab's chip-seq pipeline on a data set
# $1 = a directory with fastq files
# $2 = a project name
# this script should be run from the directory you wish your project folder to be found in
# this script is specifically for the hg38 genome

# usage: bash run_chip-seq-pipeline-hg38.sh </path/to/fastq/directory> <output_folder_name>

# first we set up your project directory
echo "Setting up project directory ..."
mkdir $2 && cd $2
bash /gpfs/data01/heinzlab/home/cag104/bin/setup_project_dir.sh

# we then copy fastq files and reference data to your data/raw_data directory
echo "Copying fastq files from $1 and loading hg38 reference information ..."
cp $1/*.fastq.gz data/raw_data/
cp /gpfs/data01/heinzlab/home/cag104/reference_data/Homo_sapiens/UCSC/hg38/hg38.chrom.sizes data/raw_data
cp -r /gpfs/data01/heinzlab/home/cag104/reference_data/Homo_sapiens/UCSC/hg38/Sequence/Bowtie2Index data/raw_data

# we then run the pipeline on our data using snakemake and singularity environments
echo "Starting pipeline ..."
singularity run --bind data/:/scif/data /gpfs/data01/heinzlab/home/cag104/bin/chip-seq-pipeline/chip-seq-pipeline-hg38.simg run snakemake all

# clean up files
echo "Cleaning up workspace ..."
cp data/Snakefile Snakefile
cp data/config.yaml config.yaml
rm -r data/raw_data/Bowtie2Index
rm data/raw_data/hg38.chrom.sizes
rm data/raw_data/*.fastq.gz
rm -r data/raw_data/fastp/
rm data/Snakefile
rm data/config.yaml
