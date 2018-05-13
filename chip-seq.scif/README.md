[![scif](https://img.shields.io/badge/filesystem-scientific-blue.svg)](https://sci-f.github.io)
[![snakemake](https://img.shields.io/badge/snakemake-%3E%3D%204.6.0-blue.svg)](https://snakemake.readthedocs.io/en/stable/)
[![singularity](https://img.shields.io/badge/singularity-%3E%3D%202.4.2-blue.svg)](http://singularity.lbl.gov/)

This pipeline implements a Snakemake workflow and uses the Scientific Filesystem (SCIF) + Singularity containers to provide a reproducible research environment.

## What is here? (Developers)

* **README.md**: is what you are reading, which has a complete walkthrough of building and running the container.
* **Singularity:** Includes the build recipe for the main Singularity container. Can more or less be copied over for implementation of other genomics pipelines.
* **Snakefile:** Defines the rules and steps of the workflow. Used by Snakemake.
* **config.yaml:** A placeholder config file that is used by Snakemake to define various parameters. Can be used to allow for custom output file names as well as customizing tool parameters.
* **project.scif:** This file installs all the applications/tools required using the same scientific filesystem recipe.
* **run_chip-seq-pipeline-example.sh:** Bash script that makes it incredibly easy for users to run pipeline.

## Building Singularity Container (Developers)

Singularity requires sudo access for building, thus it is suggested to build the container on your laptop/personal computer and then scp the finished container onto your cluster.

```
sudo singularity build chip-seq-pipeline.simg Singularity
```

## Running Workflow (Developers)

Examples are included for running commands inside and outside of the Singularity container.

This is for testing purposes only, in general a bash script should be built to automate this process for the user. For this please stick to the "outside container" command.

**Inside container, Singularity**

```
singularity shell --bind data/:/scif/data chip-seq-pipeline.simg
$ scif run snakemake all
```

**Outside container, Singularity**

```
singularity run --bind data/:/scif/data chip-seq-pipeline.simg run snakemake all
```

## Visualizing workflow (Developers)

Snakemake has a handy dandy tool for generating a graphical representation of the workflow as a DAG.

Here the execution plan is generated from the Snakemake file in our current working directory and the target file we specify. We create all the files specified by the all rule. The directed acyclic graph of the workflow will be saved under data/dag.svg.

```
singularity run --bind data/:/scif/data chip-seq-pipeline.simg run graph_viz_create_dag $PWD all dag.svg
```

# Usage Documentation

The pipeline combines snakemake, SCIF and singularity containers for an easy to run chip-seq pipeline that produces the following:

* sorted BAM files
* BAM index files
* bigWig files
* HOMER tag directories
* SSP quality control files
* FastQC files

## How to run the workflow

In short, we create a project directory, set up the directory using a bash script to maintain a universal structure, we then copy and bind our fastq data to the data directory provided by SCIF. SCIF itself provides the environment in which the workflow steps are executed. The workflow steps are carried out by Snakemake rules found in the Snakefile.

For quick reference, a help function can be used to bring up usage information:
```
bash /gpfs/data01/heinzlab/home/cag104/bin/chip-seq-pipeline/run_chip-seq-pipeline-hg38.sh -h
```

1. The workflow can be automatically run using a bash script.
```
bash /gpfs/data01/heinzlab/home/cag104/bin/chip-seq-pipeline/run_chip-seq-pipeline-hg38.sh -f=false -j=60 -i <directory> -o <project_name>
```

<-f> can be specified if you only want to do a 'fast' pre-processing that includes trimming, mapping, and generating tag directories. Takes no arguments. (Default: false)

<-j> is the number of cores that snakemake uses. By default this is set to 60, which means that Snakemake will make complete use of up to 60 cores. If a mapping job takes up 50 cores, then Snakemake will fill the other 10 cores with smaller jobs such as samtools index. If you use less cores than the number of threads requested in the Snakemake file then all jobs will use the number of threads specified in this option. Example: Bowtie2 mapping uses 50 cores by default, if -j 30 is set then all Bowtie2 mapping jobs will use 30 cores instead of the default 50.

<-i> is the path to the file directory where your fastq.gz files are kept (typically in /gpfs/data01/demux). Please ensure that there is no / at the end of your path. Example: `/gpfs/data01/demux/171221_NB501406_0204_AH753VBGX5/Carlos`.

<-o> is the name of the directory where all your data will be output. Example: `affinity_tags.heinz`.

In some cases (such as when aligning a large number of samples) it may be faster to run more rules/jobs at once. This can be changed by setting the -j flag in the Snakemake command. Default: -j 56.
