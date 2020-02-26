Tutorial
--------

### Step 1 Installation
Follow steps 1-4 on [Installation page](https://github.com/BioRRW/Mixtisque/blob/master/docs/installation.md)

### Find the test data folder
```
$ cd <NAME> 
$ cd containers/Test_Data/
```
You should see 3 directories and two files
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
```
$ cd ..
$ nano input_hybrid.csv
Sample_1_Ecoli,default,containers/Test_Data/fastq/Sample_MinION.fastq.gz,containers/Test_Data/fastq/Sample_R1_Illumina.fastq.gz,containers/Test_Data/fastq/Sample_R2_Illumina.fastq.gz,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.fna,containers/Test_Data/references/Ecoli/EcoliK12_MG1655_U00096.3.gff
```
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
  
### Move back to the < Name > install directory:
```
$ cd ~/<NAME>
```
### You can choose to test either or both below:

Default hybrid pipeline:
```
$ nextflow mixtisque.nf  --input "containers/Test_Data/input_3_Samples.csv " --output "temp/output_hybrid" -w "temp/work_hybrid"
```
Nonhybrid pipeline:
```
$ nextflow mixtisque.nf  --input "containers/Test_Data/input_3_Samples.csv " --assembly nonhybrid --output "temp/output_nonhybrid" -w "temp/work_nonhybrid"
```
Note: 
- Output (--output) directories and Nextflow working directory (-w) are kept separate.
 
### You will see the nextflow processes and their progress (nonhybrid run):
```
N E X T F L O W  ~  version 19.10.0
Launching `<NAME>` [maniac_dalembert] - revision: fc615a5471
[cb/f8b4ca] process > FastQC (TE1)   [100%] 1 of 1 ✔
[-        ] process > Nanoplot       -
[e3/4abe31] process > preMultiQC     [100%] 1 of 1 ✔
[e6/608605] process > Dedupe (TE1)   [100%] 1 of 1 ✔
[-        ] process > QualityControl -
[-        ] process > postFastQC     -
[-        ] process > postMultiQC    -
[-        ] process > Unicycler      -
[-        ] process > BAM            -
[-        ] process > QUAST          -
[-        ] process > QUASTMultiQC   -
[-        ] process > Bandage        -
[-        ] process > Phigaro        -
[-        ] process > SISTR          -
[-        ] process > Prokka         -

```
Nextflow creates random names for the runs, 'maniac_dalembert'.
Each process states the sub-woring directory, for example: [cb/f8b4ca] (ie ~/temp/work_nonhybrid/cb/f8b4ca...)

### Once complete you will see something similar to this:
```
N E X T F L O W  ~  version 19.10.0
Launching `<NAME>` [maniac_dalembert] - revision: fc615a5471
[a1/200c57] process > FastQC (TE1)         [100%] 1 of 1 ✔
[-        ] process > Nanoplot             -
[86/afce62] process > preMultiQC           [100%] 1 of 1 ✔
[20/cf1b54] process > Dedupe (TE1)         [100%] 1 of 1 ✔
[b9/6b50e4] process > QualityControl (TE1) [100%] 1 of 1 ✔
[a5/02eb57] process > postFastQC (TE1)     [100%] 1 of 1 ✔
[54/1304b4] process > postMultiQC          [100%] 1 of 1 ✔
[3d/1b407b] process > Unicycler (TE1)      [100%] 1 of 1 ✔
[a9/aed765] process > BAM (TE1)            [100%] 1 of 1 ✔
[6d/99fadd] process > QUAST (TE1)          [100%] 1 of 1 ✔
[82/4296d7] process > QUASTMultiQC         [100%] 1 of 1 ✔
[90/f2df15] process > Bandage (TE1)        [100%] 1 of 1 ✔
[-        ] process > SISTR                -
[fb/0b1341] process > Prokka (TE1)         [100%] 1 of 1 ✔
Completed at: 25-Feb-2020 20:20:32
Duration    : 32m 11s
CPU hours   : 123.7 
Succeeded   : 12
```
Processes which are not used (NanoPlot and SISTR) will show no completion or any working directory information.

### Understanding the working directory and the -resume option:
Run the exact command again and observe:
```
$ nextflow mixtisque.nf  --input "containers/Test_Data/input_3_Samples.csv " --assembly nonhybrid --output "temp/output_nonhybrid" -w "temp/work_nonhybrid"
N E X T F L O W  ~  version 19.10.0
Launching `mixtisque-4.0.1.nf` [intergalactic_engelbart] - revision: c74303a777
[a1/200c57] process > FastQC (TE1)         [100%] 1 of 1, cached: 1 ✔
[-        ] process > Nanoplot             -
[86/afce62] process > preMultiQC           [100%] 1 of 1, cached: 1 ✔
[20/cf1b54] process > Dedupe (TE1)         [100%] 1 of 1, cached: 1 ✔
[b9/6b50e4] process > QualityControl (TE1) [100%] 1 of 1, cached: 1 ✔
[a5/02eb57] process > postFastQC (TE1)     [100%] 1 of 1, cached: 1 ✔
[54/1304b4] process > postMultiQC          [100%] 1 of 1, cached: 1 ✔
[3d/1b407b] process > Unicycler (TE1)      [100%] 1 of 1, cached: 1 ✔
[a9/aed765] process > BAM (TE1)            [100%] 1 of 1, cached: 1 ✔
[6d/99fadd] process > QUAST (TE1)          [100%] 1 of 1, cached: 1 ✔
[82/4296d7] process > QUASTMultiQC         [100%] 1 of 1, cached: 1 ✔
[90/f2df15] process > Bandage (TE1)        [100%] 1 of 1, cached: 1 ✔
[-        ] process > SISTR                -
[fb/0b1341] process > Prokka (TE1)         [100%] 1 of 1, cached: 1 ✔
```
The process finished immediately because all of the processes are cached within the nextflow working directory. Even if you delete the output files (ie: rm -r /temp/output), all of the information is still retained within the working directory.
**Failure to maintain the working directory can quickly acummulate lots of data.**
