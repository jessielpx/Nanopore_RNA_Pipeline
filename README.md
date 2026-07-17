# Nanopore RNA-seq Pipeline on Rorqual🐋

#### Hi labmates, 
This repository documents how I currently run the Nanopore RNA-seq pipeline on Rorqual.
It is not the most efficient way to run it, but it does work. Please help modify the workflow :)

## Workflow Outline

1. Run PycoQC for quality check

**Differential Gene Expression**: 

2. Launch the [EPI2ME transcriptome](https://github.com/epi2me-labs/wf-transcriptomes) workflow

3. Run [Fastcat](https://github.com/epi2me-labs/fastcat) separately

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
2. Always use the **real path** of the folder, to check real path, run **pwd -P** or **realpath .**
3. Have a [samples.csv](samples.csv) in the work folder, the .csv file needs to be comma-delimited
4. Have a [configuration file](epi2me_rorqual.config) in the work folder
5. Reference genome: /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.GRCh38/genome/Homo_sapiens.GRCh38.fa

## 1. Run PycoQC for quality check:
1. sbatch [PycoQC_batch1.sh](PycoQC_batch1.sh)

## 2. Run Epi2me (First run):
1. sbatch [epi2me.sh](epi2me.sh) and wait for it to fail

---

*The epi2me transcriptomic workflow cannot be finished in a single pass on Rorqual. Fastcat needs to be done separately. I run fastcat separately then put the output back into pipeline and resume. If there is an easier way to fix the issue, please let me know!*

_**Issue**: The EPI2ME workflow assumes a **Singularity**-based container environment, while Rorqual uses **Apptainer**, resulting in compatibility issue that needs manual fixes._

---

## 3. Run Fastcat:
1. sbatch [fastcat.sh](fastcat.sh)

## 3.5. Modify nextflow scripts:
**First**
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/lib/ingress.nf
2. Find **process fastcat {...}**
3. Replace it with the script in [ingress_fastcat](ingress_fastcat)

**Second**
1. nano ~/.nextflow/assets/epi2me-labs/wf-transcriptomes/main.nf
2. Find **process makeReport {...}**
3. Replace it with the script in [main_make_report](main_make_report)

## 4. Resume epi2me: 
1. sbatch [epi2me.sh](epi2me.sh)

## To be continued...




## Running EPI2ME v1.7.2 in 1 step
1.	Copy singularity folder into ~/links/scratch
2.	Prepare samples.csv
3.	Organize fastq files such that they are in a single folder in which they are separated by unique barcodes:

---
```
input_directory
├── barcode01
│   ├── reads0.fastq
│   └── reads1.fastq
├── barcode02
│   ├── reads0.fastq
│   ├── reads1.fastq
│   └── reads2.fastq
└── barcode03
    └── reads0.fastq
```
---

4.
```
cd ~/links/scratch
```

5.	Copy EPI2ME_Transcriptomes_v1.7.2.sh into ~/links/scratch
6.	Modify EPI2ME_Transcriptomes_v1.7.2.sh script :
•	Email address
•	Location of fastq files
•	Reference
•	Samples.csv
•	Out_dir
•	Remove --transcriptome_source precomputed to use default reference genome-based approach (not tested for given reference)

7. Create ~/.nextflow/assets/epi2me-labs/wf-transcriptomes:
```
module load nextflow/24.10.2
nextflow pull epi2me-labs/wf-transcriptomes -r v1.7.2
```
8. Run script:
```
sbatch EPI2ME_Transcriptomes_v1.7.2.sh
```

## Troubleshooting

Error due to image error:
1. Copy paste “pull …” and rename to end with .img (remove ending)
2. Move .img file into singularity
3. Add -resume and rerun EPI2ME_Transcriptomes_v1.7.2.sh script.

Error due to time/memory requirements:
1. Modify process.X

