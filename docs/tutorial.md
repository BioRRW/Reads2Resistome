Tutorial
--------




### Step 1 Installation
Follow steps 1-4 on [Installation page](https://github.com/BioRRW/Mixtisque/blob/master/docs/installation.md)

### Find the test data folder
```
$ cd <NAME> 
$ cd Containers/Test_Data/
```
You should see 3 directories and two files
  ```
  $ ls
  long_reads short_reads references input_nonhybrid.csv input_hybrid.csv
  ```
  long_reads folder contains one MinION .fastq file
  ```
  $ ls long_reads/
  Sample_MinION.fastq
  ```
  short_reads folder contains two paired end Illumina .fastq file
  ```
  $ ls short_reads/
  Sample_R1_Illumina.fastq Sample_R2_Illumina.fastq
  ```

