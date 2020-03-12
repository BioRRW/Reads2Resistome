Installation
------------

To run the pipeline, you will need Nextflow and the appropriate Docker containers.

### Step 1 -- Download Nextflow
```
$ curl -fsSL get.nextflow.io | bash
$ ./nextflow
$ mv nextflow /usr/local/bin
```

### Step 2 -- Download Docker Containers

This `docker pull` command will download each of the required tools to run the pipeline.
```
$ docker pull rrw/R2R -a 
```

When the download is complete, you should have one Docker image.
```
$ docker images

R2R
```

### Step 3 -- Download Source Code
```
$ git clone https://github.com/BioRRW/R2R.git
$ cd auir/
```

### Step 4 -- Run a Test
```
nextflow R2R.nf --help
```
