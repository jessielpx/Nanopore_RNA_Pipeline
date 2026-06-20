#### Hi labmates, 
This repository documents how I currently run the Nanopore RNA-seq pipeline on Rorqual.
It is not the most efficient way to run it, but it does work. Please help modify the workflow :)

## Workflow Outline

1. Run PycoQC for quality check

**Differential Gene Expression**: 

2. Launch the EPI2ME transcriptome workflow

3. Run Fastcat separately

4. Resume the EPI2ME workflow

**Isoform switch**:

5. IsoformSwitchAnalyzeR (to do)

**Gene fusion**: 

6. JAFFAL (to do)

**Visualization**:

(to do)

### Notes
- Batch 1 is used as an example.
- 'yourname' = the username

## 0. Preparation:
1. Have a **work folder** where you run the pipeline in (e.g., /lustre09/project/6070433/yourname/Nanopore/Batch1)
2. Have a [samples.csv](samples.csv) in the work folder
3. Have a [configuration file](epi2me_rorqual.config) in the work folder

## 1. Run PycoQC for quality check:
1. sbatch [PycoQC_batch1.sh](PycoQC_batch1.sh)

## 2. Run Epi2me (First run):
1. sbatch [epi2me.sh](epi2me.sh) and wait for it to fail

***The epi2me transcriptomic workflow cannot be run smoothly on Rorqual. A specific step needs to be done separately.***

## 3. Run Fastcat:
1. sbatch [fastcat.sh](fastcat.sh)

## 3.5. Fix the code:
**First**
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/lib/ingress.nf
2. Find **process fastcat{...}**
3. Replace it with the code in [ingress_fastcat](ingress_fastcat)

**Second**
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/main.nf
2. Find **process makeReport {...}**
3. Replace it with the code in [main_make_report](main_make_report)

## 4. Resume epi2me: 
1. sbatch [epi2me.sh](epi2me.sh)
