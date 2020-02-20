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
        --quast_ref     STR     Path to directory containing genome reference (.fna) and genome feature file (.gff)
                                    (*Instead of supplying the path here, you may include the path in the input (.csv) file)
   
      

## Full list of command line options

    General:
        --help            This help
    Outputs:
        --input         STR     Path to input (.csv) file
        --outdir        STR     Output folder [auto] (default '')
    Quality Control Options:
        --leading       INT     cut bases off the start of a read, if below a threshold quality 
        --minlen        INT     drop the read if it is below a specified length 
        --slidingwindow INT     perform sw trimming, cutting once the average quality within the window falls below a threshold 
      --trailing        INT      cut bases off the end of a read, if below a threshold quality 

    Assembly: 
        --mode          STR     (default: normal)
                                conservative = smaller contigs, lowest misassembly rate
                                normal = moderate contig size and misassembly rate
                                bold = longest contigs, higher misassembly rate     
    Assembly Quality Assessment:
        --quast_ref     STR     Path to directory containing genome reference (.fna) and genome feature file (.gff)
                                    (*Instead of supplying the path here, you may include the path in the input (.csv) file)
    Annotation:
        --prokk_db      STR     (default: "null" will use prokka default annotation database)
                                <one of premade databases: "Campy", "Ecoli", "Efaecalis", "Salmonella", "Staph"> 
    Computation:
        --threads       INT     Number of CPUs to allocate to EACH process individually 
    Nextflow Options:
        -resume             Pipeline will resume from previous run if terminated
        
### Option: --XYZ

more details about this option


### File Inputs

#### Set custom sequence data

The `reads` parameter accepts sequence files in standard fastq and gz format.
```
$ nextflow run mixtisque.nf --reads "data/raw/*_R{1,2}.fastq"
```

### File Outputs

#### Set output directory

The `output` parameter writes output files to the desired directory.
```
$ nextflow run mixtisque.nf --reads "data/raw/*_R{1,2}.fastq" --output "test"
```

