This is how I run the pipeline on Rrorqual. It is not the most efficient way to run it, but it does work :)

Batch 1 is used as an example.

**Preparation**:
1. Have a **work folder** where you run the pipeline in
2. Have a [sample.csv](sample.csv) in the work folder
3. Have **epi2me_rorqual.config** in the work folder

**Run PycoQC for quality check**:
1. sbatch PycoQC_batch1.sh

**Run Epi2me (First run)**:
1. sbatch epi2me.sh and wait for it to fail

The epi2me transcriptomic workflow cannot be run smoothly on Rorqual; a specific step needs to be done separately.

**Run Fastcat independently**:
1. sbatch fastcat.sh

**Fix the code 1**:
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/lib/ingress.nf
2. Find process fastcat{}
3. Replace it with the code in ingress_fastcat

**Fix the code 2**: 
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/main.nf
2. Find process makeReport {}
3. Replace it with the code in main_make_report

**Resume epi2me**: 
1. sbatch epi2me.sh
