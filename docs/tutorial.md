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
fastq references input_tutorial.csv R2R-0.0.1.nf
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

### Take a look at the input_tutorial.csv file
```
$ cd ..
$ nano input_tutorial.csv
Tutorial_MinION_Ecoli,default,containers/Test_Data/fastq/MinION.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R1.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R2.fastq.gz,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.fna,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.gff
Tutorial_PacBio_Ecoli,default,containers/Test_Data/fastq/PacBio_Test.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R1.fastq.gz,containers/Test_Data/fastq/Illumina_Test_R2.fastq.gz,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.fna,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.gff
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
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --output "temp/output_hybrid" -w "temp/work_hybrid" --name Tutorial_Hybrid
```
Nonhybrid pipeline:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --assembly nonhybrid --output "temp/output_nonhybrid" -w "temp/work_nonhybrid" --name Tutorial_Nonhybrid
```
longread pipeline:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --assembly longread --output "temp/output_nonhybrid" -w "temp/work_nonhybrid" --name Tutorial_Long_Read
```
Note: 
- Here we will run the default hybrid pipeline, feel free to run nonhybrid and longread assemblies as well.
- Output (--output) directories and Nextflow working directory (-w) are kept separate.
 
### You will see the nextflow processes and their progress (hybrid run):
```
N E X T F L O W  ~  version 19.10.0
Launching `<NAME>` [maniac_dalembert] - revision: fc615a5471
[34/847094] process > FastQC (Tutorial_MinION_Ecoli)         [100%] 1 of 1 ✔
[75/ff5360] process > Nanoplot (Tutorial_MinION_Ecoli)       [100%] 1 of 1 ✔
[85/bac168] process > preMultiQC                             [100%] 1 of 1 ✔
[d7/56b848] process > Dedupe (Tutorial_MinION_Ecoli)         [100%] 1 of 1 ✔
[fc/a86da7] process > QualityControl (Tutorial_MinION_Ecoli) [100%] 1 of 1 ✔
[7f/75cfc9] process > postFastQC (Tutorial_MinION_Ecoli)     [100%] 1 of 1 ✔
[e3/9a1a33] process > postMultiQC                            [100%] 1 of 1 ✔
[bd/6c005a] process > Unicycler (Tutorial_MinION_Ecoli)      [  0%] 0 of 1
[-        ] process > BAM                                    -
[-        ] process > QUAST                                  -
[-        ] process > QUASTMultiQC                           -
[-        ] process > Bandage                                -
[-        ] process > Phigaro                                -
[-        ] process > SISTR                                  -
[-        ] process > Prokka                                 -
[-        ] process > ABRICATE                               -
```
Nextflow creates random names for the runs, 'maniac_dalembert'.
Each process states the sub-woring directory, for example: [34/847094] (ie ~/temp/work_nonhybrid/34/847094...)

### Once complete you will see something similar to this:
```
N E X T F L O W  ~  version 19.10.0
Launching `R2R` [maniac_dalembert] - revision: fc615a5471
[34/847094] process > FastQC (Tutorial_MinION_Ecoli)         [100%] 1 of 1 ✔
[75/ff5360] process > Nanoplot (Tutorial_MinION_Ecoli)       [100%] 1 of 1 ✔
[85/bac168] process > preMultiQC                             [100%] 1 of 1 ✔
[d7/56b848] process > Dedupe (Tutorial_MinION_Ecoli)         [100%] 1 of 1 ✔
[fc/a86da7] process > QualityControl (Tutorial_MinION_Ecoli) [100%] 1 of 1 ✔
[7f/75cfc9] process > postFastQC (Tutorial_MinION_Ecoli)     [100%] 1 of 1 ✔
[e3/9a1a33] process > postMultiQC                            [100%] 1 of 1 ✔
[bd/6c005a] process > Unicycler (Tutorial_MinION_Ecoli)      [100%] 1 of 1 ✔
[09/e29955] process > BAM (Tutorial_MinION_Ecoli)            [100%] 1 of 1 ✔
[96/501e21] process > QUAST (Tutorial_MinION_Ecoli)          [100%] 1 of 1 ✔
[e8/561be2] process > QUASTMultiQC                           [100%] 1 of 1 ✔
[08/b6ff9a] process > Bandage (Tutorial_MinION_Ecoli)        [100%] 1 of 1 ✔
[60/aaf649] process > Phigaro (Tutorial_MinION_Ecoli)        [100%] 1 of 1 ✔
[-        ] process > SISTR                                  -
[c1/267702] process > Prokka (Tutorial_MinION_Ecoli)         [100%] 1 of 1 ✔
[8e/bef6ce] process > ABRICATE (Tutorial_MinION_Ecoli)       [100%] 1 of 1 ✔
Completed at: 16-Apr-2020 18:55:52
Duration    : 2h 51m 56s
CPU hours   : 2.1
Succeeded   : 15
```
Note: SISTR only runs when analyzing a *Salmonella* genome

### Understanding the working directory and the -resume option:
Run the exact command again and observe:
```
$ nextflow R2R-0.0.1.nf  --input "containers/Test_Data/input_tutorial.csv " --output "temp/output_hybrid" -w "temp/work_hybrid"
N E X T F L O W  ~  version 19.10.0
Launching `mixtisque-4.0.1.nf` [intergalactic_engelbart] - revision: c74303a777
[34/847094] process > FastQC (Tutorial_MinION_Ecoli)         [100%] 1 of 1, cached: 1 ✔
[75/ff5360] process > Nanoplot (Tutorial_MinION_Ecoli)       [100%] 1 of 1, cached: 1 ✔
[85/bac168] process > preMultiQC                             [100%] 1 of 1, cached: 1 ✔
[d7/56b848] process > Dedupe (Tutorial_MinION_Ecoli)         [100%] 1 of 1, cached: 1 ✔
[fc/a86da7] process > QualityControl (Tutorial_MinION_Ecoli) [100%] 1 of 1, cached: 1 ✔
[7f/75cfc9] process > postFastQC (Tutorial_MinION_Ecoli)     [100%] 1 of 1, cached: 1 ✔
[e3/9a1a33] process > postMultiQC                            [100%] 1 of 1, cached: 1 ✔
[bd/6c005a] process > Unicycler (Tutorial_MinION_Ecoli)      [100%] 1 of 1, cached: 1 ✔
[09/e29955] process > BAM (Tutorial_MinION_Ecoli)            [100%] 1 of 1, cached: 1 ✔
[96/501e21] process > QUAST (Tutorial_MinION_Ecoli)          [100%] 1 of 1, cached: 1 ✔
[e8/561be2] process > QUASTMultiQC                           [100%] 1 of 1, cached: 1 ✔
[08/b6ff9a] process > Bandage (Tutorial_MinION_Ecoli)        [100%] 1 of 1, cached: 1 ✔
[60/aaf649] process > Phigaro (Tutorial_MinION_Ecoli)        [100%] 1 of 1, cached: 1 ✔
[-        ] process > SISTR                                  -
[c1/267702] process > Prokka (Tutorial_MinION_Ecoli)         [100%] 1 of 1, cached: 1 ✔
[8e/bef6ce] process > ABRICATE (Tutorial_MinION_Ecoli)       [100%] 1 of 1, cached: 1 ✔
```
The process finished immediately because all of the processes are cached within the nextflow working directory. Even if you delete the output files (ie: rm -r /temp/output), all of the information is still retained within the working directory (ie: /temp/work).
**Failure to maintain the working directory can quickly acummulate lots of data.**
