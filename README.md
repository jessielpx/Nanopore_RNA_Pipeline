#### Hi labmates, 
This workflow shows how I run the RNA-seq pipeline for Nanopore data on Rorqual.
It is not the most efficient way to run it, but it does work. Please help modify the workflow :)

#### Notes
- Batch 1 is used as an example.
- I use 'yourname' to represent the user name.

## Preparation:
1. Have a **work folder** where you run the pipeline in (e.g., /lustre09/project/6070433/yourname/Nanopore/Batch1)
2. Have a [samples.csv](samples.csv) in the work folder
3. Have a [configuration file](epi2me_rorqual.config) in the work folder

## Run PycoQC for quality check:
1. sbatch [PycoQC_batch1.sh](PycoQC_batch1.sh)

## Run Epi2me (First run):
1. sbatch [epi2me.sh](epi2me.sh) and wait for it to fail

***The epi2me transcriptomic workflow cannot be run smoothly on Rorqual. A specific step needs to be done separately.***

## Run Fastcat:
1. sbatch [fastcat.sh](fastcat.sh)

## Fix the code 1:
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/lib/ingress.nf
2. Find **process fastcat{}**
3. Replace it with the code in [ingress_fastcat](ingress_fastcat)

## Fix the code 2: 
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/main.nf
2. Find **process makeReport {}**
3. Replace it with the code in [main_make_report](main_make_report)

## Resume epi2me: 
1. sbatch [epi2me.sh](epi2me.sh)
