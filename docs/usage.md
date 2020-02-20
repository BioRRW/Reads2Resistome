Usage
-----

### Quick Start Example

To run hybrid against a Ecoli database with approximately 16 threads:
```
(change and add section for non hybrid)
nextflow mixtisque.nf --input "containers/data/raw/input_reads-single.csv " --output "temp/output" -w "temp/work" -resume --threads 16 --db Ecoli
```

### Display Help Message

The `help` parameter displays the available options and commands.
```
$ nextflow run mixtisque.nf --help
```

## Required command line parameters
    Nextflow Parameters:
        -w              STR     Path to Nextflow working directory
    Input/Output:
        --input         STR     Path to input (.csv) file 
                                    (*See Input (.csv) File Requirements for details)
        --output        STR     Path to output directory
    Assembly:
        --assembly      STR     (default: hybrid)
                                    hybrid = Assembly using both Nanopore long reads and Illumina short reads
                                    nonhybrid = Assembly using Illumina short reads only
                                    long_read = Assembly using MinION long reads only (coming soon)
    Assembly Quality Assessment:
        --quast_ref     STR     Path to directory containing genome reference (.fna) and genome feature file (.gff) (version 3)
                                    (*Instead of supplying the path here, you may include the path in the input (.csv) file)
   
      
2
## Full list of command line options

    General:
        --help            This help
    Outputs:
        --input         STR     Path to input (.csv) file
                                    (*See Input (.csv) File Requirements for details)
        --outdir        STR     Output folder [auto] (default '')
        
    Quality Control Options:
        --leading       INT     cut bases off the start of a read, if below a threshold quality 
        --minlen        INT     drop the read if it is below a specified length 
        --slidingwindow INT     perform sw trimming, cutting once the average quality within the window falls below a threshold 
        --trailing      INT     cut bases off the end of a read, if below a threshold quality 

    Assembly: 
        --mode          STR     (default: normal)
                                conservative = smaller contigs, lowest misassembly rate
                                normal = moderate contig size and misassembly rate
                                bold = longest contigs, higher misassembly rate                             
    Annotation:
        --prokk_db      STR     (default: "null" will use prokka default annotation database)
                                <one of premade databases: "Campy", "Ecoli", "Efaecalis", "Salmonella", "Staph"> 
    Computation:
        --threads       INT     Number of CPUs to allocate to EACH process individually 
        
    Nextflow Options:
        -resume                 Pipeline will resume from previous run if terminated
        
### Option: --XYZ

more details about this option


### Input (.csv) File Requirements
    A user supplied input (.csv) is required.
    
    Required:
            Column 1: Sample ID 
                (must be unique, sample ID will be used to generate ALL reports for this sample)
            Column 2: Path to long read .fastq file (may update later to input fast5 files)
                    (*Leave BLANK, no spaces, if only providing short reads)
            Column 3: Path to FORWARD short read .fastq file
            Column 4: Path to REVERSE short read .fastq file
            Column 5: Path to directory containing QUAST genome reference file
            Column 6: Path to directory containing QUAST reference genome feature file
                        (.fna and .gff (version 3) files)
                        
  ### Example Input (.csv) File:

| Sample ID | Path to long read fastq file |  Path to FORWARD short read fastq file |  Path to REVERSE short read fastq file | Path to QUAST genome reference file | Path to QUAST genome feature file |
| --------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| Sample_1, | containers/data/MinION/sample1_minion_001.fq, | containers/data/illumina/sample1_R1_001.fq, | containers/data/illumina/sample1_R2_001.fq, | containers/data/quast_references/ecoli_k12.fna, | containers/data/quast_references/ecoli_k12.gff |
| Sample_2, | containers/data/MinION/sample2_minion_001.fq, | containers/data/illumina/sample2_R1_001.fq, | containers/data/illumina/sample2_R2_001.fq, | containers/data/quast_references/ecoli_k12.fna, | containers/data/quast_references/ecoli_k12.gff |
| Sample_3, | containers/data/MinION/sample3_minion_001.fq, | containers/data/illumina/sample3_R1_001.fq, | containers/data/illumina/sample3_R2_001.fq, | containers/data/quast_references/ecoli_k12.fna, | containers/data/quast_references/ecoli_k12.gff |

                    

```

