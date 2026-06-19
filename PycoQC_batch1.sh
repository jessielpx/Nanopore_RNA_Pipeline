#!/bin/bash
#SBATCH --account=def-lefranco
#SBATCH --mem=64G
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=4
#SBATCH --job-name=PycoQC_run1
#SBATCH --output=PycoQC_run1_%j.out
#SBATCH --error=PycoQC_run1_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@mail.mcgill.ca

set -euo pipefail

module load mugqic/pycoQC/2.5.2

SUMMARY="/home/yourname/links/projects/rrg-lefranco/shared/Nanopore_Data/Sequencing_Summaries/sequencing_summary_run1.txt"
OUTDIR="/home/yourname/links/projects/rrg-lefranco/yourname/Nanopore/Batch1"
OUTHTML="${OUTDIR}/batch1_pycoqc.html"

cd "$OUTDIR"

pycoQC \
  -f "$SUMMARY" \
  -o "$OUTHTML" \
  --report_title "Nanopore Run1 (Batch1)"
