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

### Other Parameters

#### Set custom trimming parameters

```
$ nextflow run mixtisque.nf \
    --reads "data/raw/*_R{1,2}.fastq" \
    --leading 3 \
    --trailing 3 \
    --minlen 36 \
    --slidingwindow 4 \
    --adapters "data/adapters/nextera.fa" \
    --output "test"
```

#### Set number of threads

The `threads` parameter specifies the number of threads to use for each process.
```
$ nextflow run mixtisque.nf --reads "data/raw/*_R{1,2}.fastq" --threads 16 --output "test"
```
