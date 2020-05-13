Usage
-----

### Quick Start Example

To hybrid-assemble the tutorial sample data against a Ecoli database with approximately 16 threads:
```
nextflow R2R-0.0.1.nf  --input "containers/data/raw/input_tutorial.csv " --assembly hybrid --threads 16 --output "temp/output" -w "temp/work" --name R2R_Sample_Hybrid_Assembly
```

### Display Help Message

The `help` parameter displays the available options and commands.
```
$ nextflow R2R-0.0.1.nf --help
```

## Required command line parameters
    Nextflow Parameters:
        -w              STR     Path to Nextflow working directory
        --name          STR     Name of current Nextflow run
    Input/Output:
        --input         STR     Path to input (.csv) file 
                                    (*See Input (.csv) File Requirements for details)
        --output        STR     Path to output directory
   
## Full list of command line options
    usage: nextflow R2R-0.0.1.nf [--help] [--input] [--output] [--assembly] [--help] [--leading] [--trailing] [--minlen] [--slindingwindow] [--trailing] [--mode] [--threads] [--Name] [-resume]

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
        --abricate_run     STR  (default: true)
                                false = ABRICATE will not run
        --prokka_run    STR     (default: true)
                                false = Prokka will not run
                                    
    Computation:
        --threads       INT     Number of CPUs to allocate to EACH process individually 
        
    Nextflow Options: 
        -resume                 Pipeline will resume from previous run if terminated
        -with-report            A single document which includes many useful metrics about a workflow execution
        -with-trace             Creates an execution tracing file that contains some useful information about each process.executed in your pipeline script
        -with-timeline          Render an HTML timeline for all processes executed in your pipeline
        -with-dag               creates a file containing a textual representation of the pipeline execution graph in the DOT format     
[see nextflow documentation for additional details](https://www.nextflow.io/docs/latest/tracing.html)

### Input (.csv) File Requirements
    A user supplied input (.csv) is required.
    
    Required:
            Column 1: Sample ID 
                (must be unique, sample ID will be used to generate ALL reports for this sample)
            Column 2: Prokka_Database
                (If not using custom database enter "default")
            Column 3: Path to long read .fastq file (may update later to input fast5 files)
                    (*Leave BLANK, no spaces, if only providing short reads)
            Column 4: Path to FORWARD short read .fastq file
            Column 5: Path to REVERSE short read .fastq file
            Column 6: Path to directory containing QUAST genome reference file
            Column 7: Path to directory containing QUAST reference genome feature file
                        (.fna and .gff (version 3) files)

### Serovar pridictions via SISTR
- To enable SISTR serovar prediction for *Salmonella* samples you must set the Prokka_Database = "Salmonella" 
    - see example below (Sample_3_Salmonella)

  ### Example Input (.csv) File:

| Sample ID | Prokka_Database | Path to long read fastq file |  Path to FORWARD short read fastq file |  Path to REVERSE short read fastq file | Path to QUAST genome reference file | Path to QUAST genome feature file |
| --------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| Sample_1_Ecoli, | Ecoli, | containers/data/MinION/sample1_minion_001.fq, | containers/data/illumina/sample1_R1_001.fq, | containers/data/illumina/sample1_R2_001.fq, | containers/data/quast_references/ecoli_k12.fna, | containers/data/quast_references/ecoli_k12.gff |
| Sample_2, | default, | containers/data/MinION/sample2_minion_001.fq, | containers/data/illumina/sample2_R1_001.fq, | containers/data/illumina/sample2_R2_001.fq, | containers/data/quast_references/ecoli_k12.fna, | containers/data/quast_references/ecoli_k12.gff |
| Sample_3_Salmonella, | Salmonella, | containers/data/MinION/sample3_minion_001.fq, | containers/data/illumina/sample3_R1_001.fq, | containers/data/illumina/sample3_R2_001.fq, | containers/data/quast_references/ecoli_k12.fna, | containers/data/quast_references/ecoli_k12.gff |

                    

```

