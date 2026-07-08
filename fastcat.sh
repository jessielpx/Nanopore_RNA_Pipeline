#!/bin/bash
#SBATCH --account=def-lefranco
#SBATCH --mem=64G
#SBATCH --time=05:00:00
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastcat_fastq_batch
#SBATCH --output=fastcat_%j.out
#SBATCH --error=fastcat_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@mail.mcgill.ca


set -euo pipefail

module load java nextflow
module load StdEnv/2023 apptainer

IMG_PATH="/scratch/yourname/ontresearch-wf-common-sha72f3517dd994984e0e2da0b97cb3f23f8540be4b.img"
BASE_INPUT="/lustre09/project/6070433/shared/Nanopore_Data/batch1-8"
CSV_FILE="/lustre09/project/6070433/yourname/Nanopore/Batch1/samples.csv"

CHUNK_SIZE=1000000
LINES_PER_CHUNK=$((CHUNK_SIZE * 4))

OUT_ROOT="/lustre09/project/6070433/yourname/Nanopore/Batch1/fastcat_out"
mkdir -p "$OUT_ROOT"

tail -n +2 "$CSV_FILE" | while IFS=',' read -r BC ALIAS CONDITION || [[ -n "$BC" ]]; do
  BC="${BC//$'\r'/}"
  ALIAS="${ALIAS//$'\r'/}"
  CONDITION="${CONDITION//$'\r'/}"

  if [[ -z "$BC" || -z "$ALIAS" ]]; then
    echo "Skipping invalid line: BC='$BC' ALIAS='$ALIAS'" >&2
    continue
  fi

  INPUT_DIR="${BASE_INPUT}/${BC}"
  if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Skipping: input dir not found: $INPUT_DIR" >&2
    continue
  fi

  SAMPLE_DIR="${OUT_ROOT}/${BC}"
  mkdir -p "$SAMPLE_DIR"
  cd "$SAMPLE_DIR"

  mkdir -p fastcat_stats fastq_chunks
  rm -rf histograms

  apptainer exec --bind "$SAMPLE_DIR":"$SAMPLE_DIR" --bind /lustre09:/lustre09 "$IMG_PATH" bash -c "
    set -euo pipefail
    cd '$SAMPLE_DIR'

    fastcat \
      -s '$ALIAS' \
      -f fastcat_stats/per-file-stats.tsv \
      -i fastcat_stats/per-file-runids.tsv \
      -l fastcat_stats/per-file-basecallers.tsv \
      --histograms histograms \
      -x \
      '$INPUT_DIR' | \
    if [ \"$CHUNK_SIZE\" = \"0\" ]; then
      bgzip -@ 2 > fastq_chunks/seqs.fastq.gz
    else
      split -l $LINES_PER_CHUNK -d --additional-suffix=.fastq.gz \
        --filter='bgzip -@ 2 -c > \$FILE' - fastq_chunks/seqs_
    fi
  "

  apptainer exec --bind "$SAMPLE_DIR":"$SAMPLE_DIR" --bind /lustre09:/lustre09 "$IMG_PATH" bash -c "
    set -euo pipefail
    cd '$SAMPLE_DIR'

    mv histograms/* fastcat_stats/ 2>/dev/null || true

    if [ -f fastcat_stats/per-file-stats.tsv ]; then
      awk 'NR==1{for (i=1; i<=NF; i++) {ix[\$i] = i}} NR>1 {c+=\$ix[\"n_seqs\"]} END{print c}' \
        fastcat_stats/per-file-stats.tsv > fastcat_stats/n_seqs
    else
      echo 0 > fastcat_stats/n_seqs
    fi

    if [ -f fastcat_stats/per-file-runids.tsv ]; then
      awk -F \"\\t\" 'NR==1 {for (i=1; i<=NF; i++) {ix[\$i] = i}} NR>1 && \$ix[\"run_id\"] != \"\" {print \$ix[\"run_id\"]}' \
        fastcat_stats/per-file-runids.tsv | sort | uniq > fastcat_stats/run_ids
    else
      : > fastcat_stats/run_ids
    fi

    if [ -f fastcat_stats/per-file-basecallers.tsv ]; then
      awk -F \"\\t\" 'NR==1 {for (i=1; i<=NF; i++) {ix[\$i] = i}} NR>1 && \$ix[\"basecaller\"] != \"\" {print \$ix[\"basecaller\"]}' \
        fastcat_stats/per-file-basecallers.tsv | sort | uniq > fastcat_stats/basecallers
    else
      : > fastcat_stats/basecallers
    fi
  "

  echo "Done: $BC -> $SAMPLE_DIR"
done
