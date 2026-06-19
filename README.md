This is how I run the pipeline on Rrorqual. It is not the most efficient way to run it, but it does work :)

Batch 1 is used as an example.

**Preparation**:
1. Have a **work folder** where you run the pipeline in
2. Have a **sample.csv** in the work folder

**Run PycoQC for quality check**:
1. sbatch PycoQC_batch1.sh

**Run Epi2me (First run)**:
1. sbatch epi2me.sh and wait for it to fail

The epi2me transcriptomic workflow cannot be run smoothly on Rorqual; a specific step needs to be done separately.

**Run Fastcat independently**:
1. 
