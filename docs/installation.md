Installation
------------

To run the pipeline, you will need Nextflow, Singularity, Go and the appropriate Singularity containers.

### Step 1 -- Download Prerequisites (recommended for freshly installed Linux)
```
$ sudo apt-get install software-properties-common
$ sudo apt-get install -y openjdk-8-jre-headless
$ sudo apt-get install –y build-essential
$ sudo apt install –y python3
$ sudo apt-get install -y libarchive-dev
$ sudo apt install -y curl
$ sudp apt update
```

### Step 2 -- Download and install Nextflow
Follow the link for operating system specific installation instructions: [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)
```
$ curl -fsSL get.nextflow.io | bash
$ ./nextflow
$ mv nextflow /usr/local/bin
```

### Step 3 -- Download and install Go 
```
$ export VERSION=1.13 OS=linux ARCH=amd64
$ wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
$ sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz
$ rm go$VERSION.$OS-$ARCH.tar.gz
echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc && \ source ~/.bashrc
```

### Step 4 -- Download and install Singularity
Follow the link to find installation instructions for your specific operating system:
[Singularity](https://singularity.lbl.gov/all-releases)
```
$ sudo apt-get install -y libssl-dev
$ sudo apt-get install -y uuid-dev
$ export VERSION=3.5.2
$ wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz ​
$ tar -xzf singularity-${VERSION}.tar.gz
$ cd singularity
$ ./mconfig
$ make -C builddir
$ sudo make -C builddir install
```

### Step 3 -- Download Source Code in desired directory
```
git clone https://github.com/BioRRW/Reads2Resistome.git
```

### Step 4 -- Download Singularity Containers into the containers folder
- Navigate to /Reads2Resistome/containers/
- These images are large (4.65GB, 1.51 GB, 943.07 MB, 508 MB, 258 MB respectively)
```
cd Reads2Resistome/containers/
```
**OPTION 1:** Run install script in Reads2Resistome/containers/:
```
$ sh install.sh
```

**OPTION 2:** Run each of the following 'singularity pull' commands to download each of the required Singularity images to run the pipeline:

Main image:
```
$ singularity pull R2R_Main-0.0.2.simg library://biorrw/default/reads2resistome:sha256.03cdd22921c2adafd49790bc9fc7655dfa81ba4287950ab629986a507050df82
```
ABRICATE image:
```
$ singularity pull R2R_ABRICATE-0.0.1.simg library://biorrw/default/reads2resistome:sha256.0efeef9d0e051d42fc80e8e3edcb0ab45d69dbad836f0ac65533196d7b9fe4d9
```
Phigaro image:
```
$ singularity pull R2R_Phigaro-0.0.1.simg library://biorrw/default/reads2resistome:sha256.7315e84ee4bfb8e5cb5bfe1aa76067a2cd6efc52e642b7d5e4a3f0a8fbc006d4
```
Prokka image:
```
$ singularity pull R2R_Prokka-0.0.2.simg library://biorrw/default/reads2resistome:sha256.68f1a7396a9d61cbb5e9bec0f4911a2a0c7f920994f7d1514c843f7a18771f22
```
NanoPlot image:
```
$ singularity pull R2R_nanoplot-0.0.2.simg library://biorrw/default/reads2resistome:sha256.522aaa4b01b1bc7f4454cfe0c75ac6de069704d887bd16915383197c3352f08f
```
QUAST image:
```
$ singularity pull R2R_QUAST-0.0.2.simg library://biorrw/default/reads2resistome:sha256.a12c6d9fc0b6e7b89a2199454c5e7b1d817c82c8033ab664097d01664d44e553
```

When the download is complete, you should have three Singularity images in the containers folder.
```
ls
R2R_Main-0.0.2.simg R2R_ABRICATE-0.0.1.simg R2R_Phigaro-0.0.1.simg R2R_nanoplot-0.0.2.simg R2R_QUAST-0.0.2.simg R2R_Prokka-0.0.2.simg
```

### Step 5 -- Run a Test
```
nextflow R2R-0.0.2.nf --help
```
