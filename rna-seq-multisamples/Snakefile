configfile: "config.yaml"
workdir: "/scif/data"

SAMPLES,PAIR_ID = glob_wildcards("raw_data/{sample}_{pair_id}.fastq.gz")
SAMPLES = list(set(SAMPLES))

rule all:
    input:
        expand("tag_directories/{sample}/track_info.txt",sample=SAMPLES),
        expand("tag_directories/{sample}/{sample}_Log.final.out",sample=SAMPLES),
        "aligned_files/logs/summarized_log.txt",
        "gene_exp/counts.txt",
        "gene_exp/tpm.txt"

def inputs(wildcards):
    if (config["paired_end"]):
        return expand("raw_data/{reads}_{strand}.fastq.gz", strand=["R1", "R2"], reads=wildcards.reads)
    else:
        return expand("raw_data/{reads}_R1.fastq.gz", reads=wildcards.reads)

rule star:
    input:
        inputs
    params:
        star_index="star_reference",
        logdir="aligned_files/logs/"
    output:
        bam_file="aligned_files/{reads}.bam",
        log_file="aligned_files/logs/{reads}_Log.final.out"
    threads:
        50
    run:
        if config["paired_end"]:
            shell("scif run STAR '--genomeDir $SCIF_DATA/{params.star_index} --outFileNamePrefix $SCIF_DATA/{wildcards.reads}_ --readFilesIn $SCIF_DATA/{input[0]} $SCIF_DATA/{input[1]} --runThreadN {threads} --outSAMtype BAM Unsorted --readFilesCommand zcat'")
        else:
            shell("scif run STAR '--genomeDir $SCIF_DATA/{params.star_index} --outFileNamePrefix $SCIF_DATA/{wildcards.reads}_ --readFilesIn $SCIF_DATA/{input} --runThreadN {threads} --outSAMtype BAM Unsorted --readFilesCommand zcat'")
        shell("""
              mv {wildcards.reads}_Aligned.out.bam {output.bam_file}
              mv {wildcards.reads}_Log.final.out {wildcards.reads}_Log.out {wildcards.reads}_Log.progress.out {wildcards.reads}_SJ.out.tab {params.logdir}
              """)

rule sort_bam:
    input:
        "aligned_files/{sample}.bam"
    output:
        "aligned_files/{sample}.sorted.bam"
    threads:
        50
    shell:
        """
        scif run samtools 'sort -o $SCIF_DATA/{output} -@ {threads} $SCIF_DATA/{input}'
        rm {input}
        """

rule make_tag_dir:
    input:
        "aligned_files/{sample}.sorted.bam",
    output:
        "tag_directories/{sample}"
    params:
        config["tag_dir_cmds"]
    shell:
        "scif run makeTagDirectory '$SCIF_DATA/{output} {params} $SCIF_DATA/{input}'"

rule copy_logs:
    input:
        log_file="aligned_files/logs/{sample}_Log.final.out",
        tag_dir="tag_directories/{sample}"
    output:
        "tag_directories/{sample}/{sample}_Log.final.out"
    shell:
        "cp {input.log_file} {input.tag_dir}"

rule run_kallisto:
    input:
        inputs
    output:
        "gene_exp/{reads}"
    params:
        kallisto_index="kallisto.idx",
        other_cmds=config["kallisto_cmds"]
    threads:
        5
    run:
        if config["paired_end"]:
            shell("scif run kallisto 'quant -i $SCIF_DATA/{params.kallisto_index} -o $SCIF_DATA/{output} -t {threads} {params.other_cmds} $SCIF_DATA/{input[0]} $SCIF_DATA/{input[1]}'")
        else:
            shell("scif run kallisto 'quant -i $SCIF_DATA/{params.kallisto_index} -o $SCIF_DATA/{output} -t {threads} {params.other_cmds} $SCIF_DATA/{input}'")

rule make_bigwig:
    input:
        "tag_directories/{sample}"
    output:
        "tag_directories/{sample}/track_info.txt"
    params:
        "chrom.sizes"
    shell:
        """
        scif run makeUCSCfile '$SCIF_DATA/{input} -o $SCIF_DATA/{input}/{wildcards.sample}.pos.bigWig -bigWig $SCIF_DATA/{params} -fsize 1e20 -strand + > $SCIF_DATA/{input}/pos.txt'
        scif run makeUCSCfile '$SCIF_DATA/{input} -o $SCIF_DATA/{input}/{wildcards.sample}.neg.bigWig -bigWig $SCIF_DATA/{params} -fsize 1e20 -strand - > $SCIF_DATA/{input}/neg.txt'
        cat {input}/pos.txt {input}/neg.txt > {output}
        rm {input}/pos.txt {input}/neg.txt
        """

rule summarize_logs:
    input:
        expand("aligned_files/logs/{sample}_Log.final.out",sample=SAMPLES)
    output:
        "aligned_files/logs/summarized_log.txt"
    shell:
        "python concatenate_logs.py {output} {input}"

rule summarize_gene_exp:
    input:
        expand("gene_exp/{sample}",sample=SAMPLES)
    output:
        count_name="gene_exp/counts.txt",
        tpm_name="gene_exp/tpm.txt"
    shell:
        "python summarize_gene_exp.py {output.count_name} {output.tpm_name} {input}"