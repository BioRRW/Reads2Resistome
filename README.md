:shield: :pill: R2R : Reads2Resistome :crossed_swords: :dna:
---------
Hybrid and non-hybrid whole genome assembler with resistome identification for Illumina, Nanopore and PacBio reads.

Introduction
------------
R2R is a bioinformatics pipeline for quality control, assembly, annotation and resistome characterization of bacterial genomes. Assembly can be done by either a hybrid approach or a non-hybrid approach. Illumina paired-end reads along with Oxford Nanopore or PacBio long reads are acceptable for hybrid assembly. Non-hybrid assembly can be preformed with Illumina paired-end reads or Oxford Nanopore or PacBio long reads. Resistome characterization includes identification of virulence factors and genes, antimicrobial resistance genes, serotype, plasmid replicons, antigen genes, and cgMLST gene alleles. R2R provides multiple output files: 1) MultiQC-aggregated quality control and assembly reports (.html), 2) Individual FastQC reports 3) assembled, annotated contigs (.gfa), and 4) resistome report (.csv). There are additional output files, see documentation for details. 

Overview
------------
<img src="https://github.com/BioRRW/Reads2Resistome/blob/master/docs/images/R2R_Flow_Diagram-0.0.2.png" width="500" height="700">
  
Additional analysis options
-------------
If you already have contigs and only want to run annotation and resistome characterizaion, see R2R-0.0.1-Fasta-QC-Ann-Only.nf for details. An explanation of the input is at the top of the R2R-0.0.1-Fasta-QC-Ann-Only.nf file. 

Citation
-------------
Preprint: doi: https://doi.org/10.1101/2020.05.18.102715

Documentation
-------------
  - [Tutorial](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/tutorial.md)
  - [Software Requirements](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/requirements.md)
  - [Process Overview](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/process.md)
  - [Installation](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/installation.md)
  - [Usage](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/usage.md)
  - [Configuration](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/configuration.md)
  - [Output](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/output.md)
  - [Dependencies](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/dependencies.md)
  - [Contact](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/contact.md)
  - [Acknowledgements](https://github.com/BioRRW/Reads2Resistome/blob/master/docs/acknowledgements.md)

Acknowledgements
----------------

- [nf-core] for pipeline adaption 
  - https://nf-co.re/
- StaPH-B for some dockerfiles
  - https://github.com/StaPH-B
- USDA-ARS/ORISE for funding 
  - https://orise.orau.gov/usda-ars/
- [@lakinsm] for repository structure adaption
  - https://github.com/lakinsm/bear-wgs
  
Support and Contact
-------------------
Reads2Resistome is developed at Colorado State University within the Abdo Lab.
For any issues or concerns, please contact us at reedrich [at] colostate [dot] edu

Developers
----------
Reed Woyda 
