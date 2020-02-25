Configuration
-------------

To modify default parameters: open the nextflow.config file 

### Adapter Sequences
```
/* Location of adapter sequences */
adapters = "containers/data/adapters/nextera.fa"
```

### Output Directory
```
/* Output directory */
output = "./temp/output"
```

### Number of Threads
```
/* Number of threads */
threads = 1
```

### Trimmomatic Parameters
```
/* Trimmomatic trimming parameters */
leading = 3
trailing = 3
slidingwindow = "4:15"
minlen = 36
```

### ARIBA Parameters
**More than one thread for each ARIBA process is NOT recommnded**
/* ARIBA */
ariba_threads = 1

### Unicycler Parameters
/* Unicycler parameters */
assembly = "hybrid"
mode = "normal"

### Computation Parameters 
- Here it is important to do some quick math to estimate CPU and memory usage
  - For example: 
    - assembling 5 genomes using 1 thread = 5*1

