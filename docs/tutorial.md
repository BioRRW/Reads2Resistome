Tutorial
--------

### Step 1 Installation
Follow steps 1-4 on [Installation page](https://github.com/BioRRW/Mixtisque/blob/master/docs/installation.md)

### Find the test data folder
```
$ cd Reads2Resistome 
$ cd containers/Test_Data/
```
You should see two directories and two files
```
$ ls
fastq references input_tutorial.csv R2R.nf
```
fastq folder contains four gzipped files
Unzip the .fastq.gz files
```
$ cd fastq/
$ ls
Illumina_Test_R1.fastq.gz  Illumina_Test_R2.fastq.gz  MinION_Test.fastq.gz  PacBio_Test.fastq.gz
$ gunzip *.fastq.gz
```
### Take a look at the references used for QUAST
```
$ ls references/
EcoliK12_MG1655_U00096.3.fna EcoliK12_MG1655_U00096.3.gff 
```

### Take a look at the input.csv file
```
$ cd ..
$ nano input_tutorial.csv
Sample_MinION_Ecoli,default,containers/Test_Data/fastq/Sample1_MinION.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R1.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R2.fastq.gz,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.fna,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.gff
Sample_PacBio_Ecoli,default,containers/Test_Data/fastq/PacBio_Test.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R1.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R2.fastq.gz,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.fna,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.gff
```
Note:
- We will be using the 'default' Prokka annotation database (column 2)
- We have set the paths to the sequence and reference files according to the [Usage](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/usage.md) docs
  - Sample ID in column 1
  - Genus choice Prokka annotation in column 2 
  - The long read file is in column 3
  - The forward short read file in column 4
  - The forward short read file in column 5
  - QUAST reference genome file in column 6
  - QUAST genome reference file in column 7 
  
### Move back to the Reads2Resistome install directory:
```
$ cd ~/Reads2Resistome
```
### You can choose to test either or both below:

Default hybrid pipeline:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --output "temp/output_hybrid" -w "temp/work_hybrid"
```
Nonhybrid pipeline:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --assembly nonhybrid --output "temp/output_nonhybrid" -w "temp/work_nonhybrid"
```
longread pipeline:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --assembly longread --output "temp/output_nonhybrid" -w "temp/work_nonhybrid"
```
Note: 
- Here we will run the default hybrid pipeline, feel free to run nonhybrid and longread assemblies as well.
- Output (--output) directories and Nextflow working directory (-w) are kept separate.
 
### You will see the nextflow processes and their progress (hybrid run):
```
N E X T F L O W  ~  version 19.10.0
Launching `<NAME>` [maniac_dalembert] - revision: fc615a5471
[22/3c9e93] process > FastQC (EC_IC4_2X_MinION)   [100%] 2 of 2 ✔
[6f/1371d1] process > Nanoplot (EC_IC4_2X_PacBio) [  0%] 0 of 1
[-        ] process > preMultiQC                  -
[de/cc10e5] process > Dedupe (EC_IC4_2X_MinION)   [  0%] 0 of 2
[-        ] process > QualityControl              -
[-        ] process > postFastQC                  -
[-        ] process > postMultiQC                 -
[-        ] process > Unicycler                   -
[-        ] process > BAM                         -
[-        ] process > QUAST                       -
[-        ] process > QUASTMultiQC                -
[-        ] process > Bandage                     -
[-        ] process > Phigaro                     -
[-        ] process > SISTR                       -
[-        ] process > Prokka                      -
[-        ] process > ABRICATE                    -
```
Nextflow creates random names for the runs, 'maniac_dalembert'.
Each process states the sub-woring directory, for example: [22/3c9e93] (ie ~/temp/work_nonhybrid/22/3c9e93...)

### Once complete you will see something similar to this:
```
N E X T F L O W  ~  version 19.10.0
Launching `R2R` [maniac_dalembert] - revision: fc615a5471
[22/3c9e93] process > FastQC (EC_IC4_2X_MinION)         [100%] 2 of 2 ✔
[7f/e88815] process > Nanoplot (EC_IC4_2X_MinION)       [100%] 2 of 2 ✔
[b3/75842a] process > preMultiQC                        [100%] 1 of 1 ✔
[27/468f3a] process > Dedupe (EC_IC4_2X_PacBio)         [100%] 2 of 2 ✔
[db/37261a] process > QualityControl (EC_IC4_2X_PacBio) [100%] 2 of 2 ✔
[5d/787b50] process > postFastQC (EC_IC4_2X_PacBio)     [100%] 2 of 2 ✔
[37/05be74] process > postMultiQC                       [100%] 1 of 1 ✔
[dd/e6d416] process > Unicycler (EC_IC4_2X_PacBio)      [100%] 2 of 2 ✔
[f2/dc38e0] process > BAM (EC_IC4_2X_PacBio)            [100%] 2 of 2 ✔
[89/eb07d4] process > QUAST (EC_IC4_2X_PacBio)          [100%] 2 of 2 ✔
[fb/5d04dd] process > QUASTMultiQC                      [100%] 1 of 1 ✔
[84/8eeab5] process > Bandage (EC_IC4_2X_PacBio)        [100%] 2 of 2 ✔
[95/ca1d47] process > Phigaro (EC_IC4_2X_PacBio)        [100%] 2 of 2 ✔
[8b/684f9d] process > SISTR (EC_IC4_2X_PacBio)          [100%] 2 of 2 ✔
[8e/4a87f6] process > Prokka (EC_IC4_2X_PacBio)         [100%] 2 of 2 ✔
[63/96b6fc] process > ABRICATE (EC_IC4_2X_PacBio)       [100%] 2 of 2 ✔
<insert completion time and info>
```

### Understanding the working directory and the -resume option:
Run the exact command again and observe:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --output "temp/output_hybrid" -w "temp/work_hybrid"
N E X T F L O W  ~  version 19.10.0
Launching `mixtisque-4.0.1.nf` [intergalactic_engelbart] - revision: c74303a777
[22/3c9e93] process > FastQC (EC_IC4_2X_MinION)         [100%] 2 of 2, cached: 2 ✔
[7f/e88815] process > Nanoplot (EC_IC4_2X_MinION)       [100%] 2 of 2, cached: 2 ✔
[b3/75842a] process > preMultiQC                        [100%] 1 of 1, cached: 1 ✔
[27/468f3a] process > Dedupe (EC_IC4_2X_PacBio)         [100%] 2 of 2, cached: 2 ✔
[db/37261a] process > QualityControl (EC_IC4_2X_PacBio) [100%] 2 of 2, cached: 2 ✔
[5d/787b50] process > postFastQC (EC_IC4_2X_PacBio)     [100%] 2 of 2, cached: 2 ✔
[37/05be74] process > postMultiQC                       [100%] 1 of 1, cached: 1 ✔
[54/73925f] process > Unicycler (EC_IC4_2X_MinION)      [100%] 2 of 2, cached: 2 ✔
[f2/dc38e0] process > BAM (EC_IC4_2X_PacBio)            [100%] 2 of 2, cached: 2 ✔
[89/eb07d4] process > QUAST (EC_IC4_2X_PacBio)          [100%] 2 of 2, cached: 2 ✔
[fb/5d04dd] process > QUASTMultiQC                      [100%] 1 of 1, cached: 1 ✔
[84/8eeab5] process > Bandage (EC_IC4_2X_PacBio)        [100%] 2 of 2, cached: 2 ✔
[95/ca1d47] process > Phigaro (EC_IC4_2X_PacBio)        [100%] 2 of 2, cached: 2 ✔
[8b/684f9d] process > SISTR (EC_IC4_2X_PacBio)          [100%] 2 of 2, cached: 2 ✔
[8e/4a87f6] process > Prokka (EC_IC4_2X_PacBio)         [100%] 2 of 2, cached: 2 ✔
[63/96b6fc] process > ABRICATE (EC_IC4_2X_PacBio)       [100%] 2 of 2, cached: 2 ✔
```
The process finished immediately because all of the processes are cached within the nextflow working directory. Even if you delete the output files (ie: rm -r /temp/output), all of the information is still retained within the working directory (ie: /temp/work).
**Failure to maintain the working directory can quickly acummulate lots of data.**
