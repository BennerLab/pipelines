[![scif](https://img.shields.io/badge/filesystem-scientific-blue.svg)](https://sci-f.github.io)
[![snakemake](https://img.shields.io/badge/snakemake-%3E%3D%204.6.0-blue.svg)](https://snakemake.readthedocs.io/en/stable/)
[![singularity](https://img.shields.io/badge/singularity-%3E%3D%202.4.2-blue.svg)](http://singularity.lbl.gov/)

This pipeline implements a Snakemake workflow and uses the Scientific Filesystem (SCIF) + Singularity containers to provide a reproducible research environment.

## What is here?

* **README.md**: is what you are reading, which has a complete walkthrough of building and running the container.
* **Singularity:** Includes the build recipe for the main Singularity container. Can more or less be copied over for implementation of other genomics pipelines.
* **Snakefile:** Defines the rules and steps of the workflow. Used by Snakemake.
* **config.yaml:** A placeholder config file that is used by Snakemake to define various parameters. Can be used to allow for custom output file names as well as customizing tool parameters.
* **project.scif:** This file installs all the applications/tools required using the same scientific filesystem recipe.

## Building Singularity Container

Singularity requires sudo access for building, thus it is suggested to build the container on your laptop/personal computer and then scp the finished container onto your cluster.

```
sudo singularity build chip-seq-pipeline.simg Singularity
```

## Running Workflow

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

## Visualizing workflow

Snakemake has a handy dandy tool for generating a graphical representation of the workflow as a DAG.

Here the execution plan is generated from the Snakemake file in our current working directory and the target file we specify. We create all the files specified by the all rule. The directed acyclic graph of the workflow will be saved under data/dag.svg.

```
singularity run --bind data/:/scif/data chip-seq-pipeline.simg run graph_viz_create_dag $PWD all dag.svg
```
