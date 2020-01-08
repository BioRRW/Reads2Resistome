Configuration
-------------

To modify parameters: open the nextflow.config file 

### Input Sequences
```
/* Location of forward and reverse read pairs in addition to Nanopore reads */
reads = "data/raw/input_reads.csv"
```

### Host Genome
```
/* Location of host genome file */
host = "data/genome/host/gallus.fa"
```

### Adapter Sequences
```
/* Location of adapter sequences */
adapters = "data/adapters/nextera.fa"
```

### Output Directory
```
/* Output directory */
output = "./test"
```

### Number of Threads
```
/* Number of threads */
threads = 16
```

### Trimmomatic Parameters
```
/* Trimmomatic trimming parameters */
leading = 3
trailing = 3
slidingwindow = "4:15"
minlen = 36
```

### Unicycler Parameters (add fuctionality for hybrid or nonhybrid)


