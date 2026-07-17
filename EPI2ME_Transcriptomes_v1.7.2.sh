#!/bin/bash
#SBATCH --account=def-lefranco
#SBATCH --time=12:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=wf-transcriptomes.sh
#SBATCH --output=wf-transcriptomes_%A_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourname@mail.mcgill.ca

module load StdEnv/2023
module load java 
module load nextflow/24.10.2
module load apptainer

export NXF_HOME=$HOME/links/scratch/nxf_cache
export NXF_SINGULARITY_CACHEDIR=$HOME/links/scratch/singularity
export NXF_SINGULARITY_AUTO_PULL=false
export NXF_OFFLINE=true
export NXF_DEFAULT_CPUS=$SLURM_CPUS_PER_TASK

# add -resume if run stops due to time limit or error (after fixing)

nextflow run ~/.nextflow/assets/epi2me-labs/wf-transcriptomes\
	--de_analysis \
	--cdna_kit SQK-PCB114 \
	--fastq /home/yourname/links/../Batch1 \
	--transcriptome_source precomputed \
	--ref_annotation /home/yourname/links/.../ncbi_dataset/data/GCF_000001405.40/genomic.gtf \
	--ref_transcriptome /home/yourname/links/.../ncbi_dataset/data/GCF_000001405.40/rna.fna \
	--ref_genome /home/yourname/links/.../ncbi_dataset/data/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna \
	--sample_sheet  /home/yourname/links/.../SampleMetaData.csv \
	--out_dir /home/yourname/links/.../Batch1_Pre \
	-profile singularity \
	-process.memory '64 GB' \
	-process.cpus 4 \
	-process.time '12h' \
	-process.executor slurm
