Installation
------------

To run the pipeline, you will need Nextflow and the appropriate Singularity containers.

### Step 1 -- Download and install Nextflow
Follow the link for operating system specific installation instructions: [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)
```
$ curl -fsSL get.nextflow.io | bash
$ ./nextflow
$ mv nextflow /usr/local/bin
```

### Step 2 -- Download and install Singularity
Follow the link to find installation instructions for your specific operating system:
[Singularity](https://singularity.lbl.gov/all-releases)
```
VERSION=2.5.2
wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz
tar xvf singularity-$VERSION.tar.gz
cd singularity-$VERSION
./configure --prefix=/usr/local
make
sudo make install
```

### Step 3 -- Download Source Code
```
git clone https://github.com/BioRRW/Reads2Resistome.git
```

### Step 4 -- Download Singularity Containers into the containers folder
Navigate to /Reads2Resistome/containers: 
```
cd Reads2Resistome/containers
```
Run each of the following 'singularity pull' commands to download each of the required Singularity images to run the pipeline:

Main image:
```
singularity pull R2R_Main-0.0.1.simg library://biorrw/default/reads2resistome:sha256.696b51e39c9790316009728a5f26500aafa5d03331afaf3c96fe119909d8ed95
```
ABRICATE image:
```
singularity pull R2R_ABRICATE-0.0.1.simg  library://biorrw/default/reads2resistome:sha256.0efeef9d0e051d42fc80e8e3edcb0ab45d69dbad836f0ac65533196d7b9fe4d9
```
Phigaro image:
```
singularity pull R2R_Phigaro-0.0.1.simg library://biorrw/default/reads2resistome:sha256.7315e84ee4bfb8e5cb5bfe1aa76067a2cd6efc52e642b7d5e4a3f0a8fbc006d4
```

When the download is complete, you should have three Singularity images in the containers folder.
```
ls
R2R_Main-0.0.1.simg R2R_ABRICATE-0.0.1.simg R2R_Phigaro-0.0.1.simg
```

### Step 5 -- Run a Test
```
nextflow R2R-0.0.1.nf --help
```
