Tutorial
--------

### Step 1 Installation
Follow steps 1-4 on [Installation page](https://github.com/BioRRW/Mixtisque/blob/master/docs/installation.md)

### Find the test data folder
```
$ cd <NAME> 
$ cd containers/Test_Data/
```
### You should see 3 directories and two files
```
$ ls
fastq references input_nonhybrid.csv input_hybrid.csv
```
fastq folder contains three gzipped files
Unzip the .fastq.gz files
```
$ cd fastq/
$ ls
Sample_R1_Illumina.fastq.gz Sample_R2_Illumina.fastq.gz Sample_MinION.fastq.gz
$ gunzip *.fastq.gz
```
### Take a look at the references used for QUAST
```
$ ls references/
EcoliK12_MG1655_U00096.3.fna EcoliK12_MG1655_U00096.3.gff 
```

### Take a look at the input.csv file
Note:
- We will be using the 'default' Prokka annotation database (column 2)
- We have set the paths to the sequence and reference files according to the [Usage](https://github.com/BioRRW/Mixtisque/blob/master/docs/usage.md) docs
  - Sample ID in column 1
  - Genus choice Prokka annotation in column 2 
  - The long read file is in column 3
  - The forward short read file in column 4
  - The forward short read file in column 5
  - QUAST reference genome file in column 6
  - QUAST genome reference file in column 7 
```
$ cd ..
$ nano input_hybrid.csv
Sample_1_Ecoli,default,containers/Test_Data/fastq/Sample_MinION.fastq.gz,containers/Test_Data/fastq/Sample_R1_Illumina.fastq.gz,containers/Test_Data/fastq/Sample_R2_Illumina.fastq.gz,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.fna,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.gff
```

```
