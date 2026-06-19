#!/bin/bash
#SBATCH --account=def-lefranco
#SBATCH --mem=128G
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --job-name=wf_nanopore
#SBATCH --output=epi2me_%j.out
#SBATCH --error=epi2me_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@mail.mcgill.ca

module purge
module load StdEnv/2023
module load java/21.0.1
module load nextflow/25.10.2
module load apptainer/1.4.5


export NXF_APPTAINER_OPTS="-B /lustre09/project/6070433/shared/Nanopore/Batch1"
export NXF_SINGULARITY_OPTS="$NXF_APPTAINER_OPTS"

# ---- Nextflow behaviour ----
export NXF_DISABLE_CHECK_LATEST=true
export NXF_ANSI_LOG=false
export NXF_DOCKER_ENABLED=false

# ---- Shared container cache (project) ----
export NXF_SINGULARITY_CACHEDIR=/project/def-lefranco/peixiliu/NXF_SINGULARITY_CACHEDIR
mkdir -p "$NXF_SINGULARITY_CACHEDIR"
export APPTAINER_CACHEDIR="$NXF_SINGULARITY_CACHEDIR"

# ---- Temp dirs (scratch) ----
export TMPDIR="$SCRATCH/tmp"
export APPTAINER_TMPDIR="$SCRATCH/apptainer_tmp"
export APPTAINERENV_TMPDIR="$SCRATCH/tmp"
mkdir -p "$TMPDIR" "$APPTAINER_TMPDIR"

# ---- Avoid legacy Singularity env injection ----
unset SINGULARITYENV_TMPDIR SINGULARITYENV_NXF_DEBUG SINGULARITYENV_NXF_TASK_WORKDIR

# ---- Avoid "too many open files" ----
ulimit -n 4096


nextflow run epi2me-labs/wf-transcriptomes \
  -c epi2me_rorqual.config \
  -work-dir $SCRATCH/nxf_work/wf_tx_Batch1 \
  --fastq /lustre09/project/6070433/shared/Nanopore/Batch1 \
  --sample_sheet /home/yourname/links/projects/rrg-lefranco/yourname/Nanopore/Batch1/samples.csv \
  --ref_genome /cvmfs/ref.mugqic/genomes/species/Homo_sapiens.GRCh38/genome/Homo_sapiens.GRCh38.fa \
  --ref_annotation /home/yourname/links/projects/rrg-lefranco/shared/genes.gtf \
  --out_dir /home/yourname/links/projects/rrg-lefranco/yourname/Nanopore/Batch1/wf_tx_out \
  --threads "${SLURM_CPUS_PER_TASK}" \
  --cdna_kit SQK-PCS114
  -resume
