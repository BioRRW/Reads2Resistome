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
  - For example setting all 'cpus = 1' and all 'maxForks = 1' 
    - assembling 5 genomes: 5 genomes * 1 cpus * 1 fork = 5 total cpus possible **for EACH process**
  - Another example all 'cpus = 1' and all 'maxForks = 1' except for setting Unicycler to 4 threads
    - Same 5 total cpus **and** 5 genomes * 1 cpus * 4 forks = 20 total cpus possible for **Unicycler alone**
- It is recommended to leave all 'cpus = 1' and all 'maxFork = 1' until you have become familiar with the scale of your project
- **Further development on mitigating total cpu and memory usage is coming soon...**

