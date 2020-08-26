#!/usr/bin/env nextflow

/* Versions
    R2R-0.0.1-Assembly-QC-Ann-Only.nf
    This version takes in a pre-assembled fasta and does the following QC/Annotation steps:
    QUAST, MultiQC, Prokka, Phigaro and ABRICATE
    The user must provide an input.csv in the following format:
    <id>,</path/to/.fasta>,,,,</path/to/QUAST ref genome>,</path/to/QUAST ref genome>
*/

/* Display help message */
if (params.help){
    helpMessage()
    exit 0
}

custom_runName = params.name
if( !(workflow.runName ==~ /[a-z]+_[a-z]+/) ){
  custom_runName = workflow.runName
}

/* Set values from parameters */
InputFasta=file(params.input)
threads=params.threads
quast_ref=params.quast_ref
/* db=params.db */
mode=params.mode

/* Setup channels */
files=Channel.create()
files=extractFasta(InputFasta)

process QUAST {
	tag "$id"
	
	publishDir "${params.output}/Assembly/QUAST/${id}", mode: "symlink"

	input:
		    tuple id, file(fasta), genus, r_ref, g_ref from files
		
	output:
	        tuple id, file(fasta) into pre_phigaro
	        tuple id, genus, r_ref, g_ref, file(fasta) into (pre_sistr)
	        tuple id, genus, r_ref, g_ref, file(fasta) into (pre_prokka)
		    file("QUAST/*") into (quast_results)
		    file "${id}.report.tsv"
		    file "${id}.report.html"

	"""
        ${params.quast_path}/quast.py \
        --threads ${threads} \
        -o QUAST \
        --labels "${id}_Assembly" \
        ${fasta} \
        -r ${r_ref} \
        -g ${g_ref}
        cp QUAST/report.tsv ./${id}.report.tsv
        cp QUAST/report.html ./${id}.report.html
        cp QUAST/icarus.html ./${id}.icarus.html
	"""
	
}

process QUASTMultiQC {
        /* conda 'multiqc' */

        publishDir "${params.output}/Assembly/QUAST/MultiQC", mode: "symlink"

        input:
                file ('QUAST??/*') from quast_results.collect().ifEmpty([])
        output:
                file "*.html"

        """
        export LC_ALL=C.UTF-8
        export LANG=C.UTF-8
        /opt/miniconda/bin/multiqc .  --title "Unicycler_QUAST_Report"

        """

}


process Phigaro {
    tag "$id"

    publishDir "${params.output}/Assembly/Phigaro", mode: "symlink"

    input:
            tuple id, file(assembly_fasta) from pre_phigaro

    output:
            file "${id}.phigaro*"

        """
	phigaro \
	-f ${assembly_fasta} \
	-o "${id}.phigaro" \
        -c /opt/phigaro/config.yml \
	-e tsv html \
	--not-open \
	-d \
	-t ${threads}  
        """
}

process SISTR {
        /* conda 'sistr_cmd' */

        tag "$id"

        publishDir "${params.output}/Annotation/SISTR/${id}", mode: "symlink"

        input:
                tuple id, genus, r_ref, g_ref, file(assembly_fasta) from pre_sistr
        output:
                file "${id}-serovar.csv"
		        file "${id}-allele-results.json"
		        file "${id}-novel-alleles.fasta"
		        file "${id}-cgMLST.csv"

        when: "${genus}" == "Salmonella"

        """
	/opt/miniconda/bin/sistr \
	-t ${params.sistr_threads} \
	-f csv \
	${assembly_fasta} \
	-o ${id}-serovar.csv \
	--alleles-output ${id}-allele-results.json \
	--novel-alleles ${id}-novel-alleles.fasta \
	--qc -p ${id}-cgMLST.csv

        """

}
process Prokka {
    tag "$id"

    publishDir "${params.output}/Annotation/Prokka/${id}", mode: "symlink"

    input:
             tuple id, genus, r_ref, g_ref, file(assembly_fasta) from pre_prokka
    output:
            tuple id, file("${id}.*") into (annotated_genome_alignments)
	    tuple id, file("${id}.genome.gbk") into (pre_abricate)
            file "${id}.genome.tsv"
            file "${id}.genome.gff"

    when: "${params.prokka_run}" == "true" 
        """
        if [[ ${genus} == "default" ]]; then
		/opt/prokka/bin/prokka \
		--cpus ${params.prokka_threads} \
		--outdir Prokka \
		--force \
		--prefix ${id}.genome \
		--kingdom Bacteria \
		${assembly_fasta}
        else
                /opt/prokka/bin/prokka \
		--usegenus \
		--genus ${genus} \
                --cpus ${params.prokka_threads} \
                --outdir Prokka \
                --force \
                --prefix ${id}.genome \
                --kingdom Bacteria \
                ${assembly_fasta}
        fi
        
        mv Prokka/${id}.genome.tsv ./${id}.genome.tsv
        mv Prokka/${id}.genome.err ./${id}.genome.err
        mv Prokka/${id}.genome.ffn ./${id}.genome.ffn
        mv Prokka/${id}.genome.fsa ./${id}.genome.fsa
        mv Prokka/${id}.genome.gff ./${id}.genome.gff
        mv Prokka/${id}.genome.sqn ./${id}.genome.sqn
        mv Prokka/${id}.genome.faa ./${id}.genome.faa
        mv Prokka/${id}.genome.fna ./${id}.genome.fna
        mv Prokka/${id}.genome.gbk ./${id}.genome.gbk
        mv Prokka/${id}.genome.log ./${id}.genome.log
        mv Prokka/${id}.genome.tbl ./${id}.genome.tbl

        """

}

process ABRICATE {
    /* conda 'abricate' */

    tag "$id"

    publishDir "${params.output}/Annotation/ABRICATE", mode: "symlink"

    input:
	    tuple id, file(assembly_gbk) from (pre_abricate)
    output: file("${id}.abricate.summary.tab")

    when: "${params.abricate_run}" == "true"

    """
    /opt/miniconda/bin/abricate --db plasmidfinder ${assembly_gbk} > ${id}.pf.tab
    /opt/miniconda/bin/abricate --db argannot ${assembly_gbk} > ${id}.arg.tab
    /opt/miniconda/bin/abricate --db card ${assembly_gbk} > ${id}.card.tab
    /opt/miniconda/bin/abricate --db megares ${assembly_gbk} > ${id}.meg.tab
    /opt/miniconda/bin/abricate ---db resfinder ${assembly_gbk} > ${id}.rf.tab
    /opt/miniconda/bin/abricate --db vfdb ${assembly_gbk} > ${id}.vfdb.tab
    /opt/miniconda/bin/abricate --db ncbi  ${assembly_gbk} > ${id}.ncbi.tab
    /opt/miniconda/bin/abricate --summary *.tab > ${id}.abricate.summary.tab
    """

}

/* Input file functions */

def returnFile(it) {
/* Return file if it exists */
    inputFile = file(it)
    if (!file(inputFile).exists()) exit 1, "The following file from the TSV file was not found: ${inputFile}, see --help for more information"
    return inputFile
}

def extractFasta(csvFile) {
    /* Extracts Fasta  from CSV */
    Channel.from(csvFile)
    .ifEmpty {exit 1, log.info "Cannot find path file ${csvFile}"}
    .splitCsv(sep:',')
    .map { row ->
	/* Fasta QC and Annotation only */
	def id = row[0]
	def genus = row[1]
    def fasta = returnFile(row[2])
    def r_ref = returnFile(row[5])
    def g_ref = returnFile(row[6])
	[id, fasta, genus, r_ref, g_ref]  
    
   }
}

def helpMessage() {
    //log.info nfcoreHeader()
    log.info"""

usage: mixtisque [--help] [--input] [--output] [--assembly] [--help] [--leading] [--trailing] [--minlen] [--slindingwindow] [--trailing] [--mode] [--serovar] [--threads] [-resume]
    
Mixtisque: a bacterial genome assembler and resistome identification pipeline 
    
    
    Example Usage: (Hybrid assembly using an Ecoli prokka database)
    
        nextflow mixtisque.nf  --input "containers/data/raw/input_3_Samples.csv " --assembly hybrid --output "temp/output" -w "temp/work" 

    Required command line parameters
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

    List of full command line options
        General:
            --help                  This help menu

        Outputs:
            --input         STR     Path to input (.csv) file
                                        (*See Input (.csv) File Requirements for details)
            --outdir        STR     Output folder [auto] (default '')
            
        Quality Control Options:
            --leading       INT     (default: 3) cut bases off the start of a read, if below a threshold quality 
            --minlen        INT     (default: 36) drop the read if it is below a specified length 
            --slidingwindow INT:INT (default: 4:20) perform sw trimming, cutting once the average quality within the window falls below a threshold 
            --trailing      INT     (default: 3) cut bases off the end of a read, if below a threshold quality 

        Assembly: 
            --mode          STR     (default: normal)
                                    conservative = smaller contigs, lowest misassembly rate
                                    normal = moderate contig size and misassembly rate
                                    bold = longest contigs, higher misassembly rate                              
        Annotation: 
            --abricate_run  STR     (default: true)
                                    false = ABRICATE will not run
            --prokka_run    STR     (default: true)
                                    false = Prokka will not run
        Computation:
            --threads       INT     Number of CPUs to allocate to EACH process individually 
            
        Nextflow Options:
            -resume                 Pipeline will resume from previous run if terminated

     Documentation: https://github.com/BioRRW/Mixtisque


    """.stripIndent()
}


