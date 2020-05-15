#!/usr/bin/env nextflow

/*
Author: Reed Woyda, MS Colorado State University
Abdo Lab: https://sites.google.com/site/abdocompbio/home
Contact: reed dot woyda at colostate dot edu
Documentation: https://github.com/BioRRW/Reads2Resistome
*/

/* Versions
0.0.1: Replacing ARIBA with ABRICATE and adding Phigaro
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
Inputreads=file(params.input)
assembly=params.assembly
threads=params.threads
quast_ref=params.quast_ref
/* db=params.db */
mode=params.mode

/* Setup channels */
files=Channel.create()
files=extractFastq(Inputreads)

/*
process Porechop {
        tag "$id"

        input:
                tuple id, file(long_read), file(forward_pair), file(reverse_pair), genus from files

        output:
                tuple id, genus, file("lr_porephop.fastq"), file("${forward_pair}"), file("${reverse_pair}") into (files_pre_fastqc, files_pre_trim, files_pre_nanoplot)
	"""
        if [[ ${assembly} == "hybrid" ]]; then
		cat ${long_read} > lr_porechop.fastq
		porechop -i lr_porechop.fastq -t ${threads} -o lr_porechop.fastq
	fi
	"""	

}
*/

process FastQC {
	tag "$id"
	
	publishDir "${params.output}/Quality_Control/FastQC/Pre_QC", mode: "symlink"

	input:
		tuple id, file(long_read), file(forward_pair), file(reverse_pair), genus, r_ref, g_ref from files
		
	output:
		tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${forward_pair}"), file("${reverse_pair}") into (files_pre_dedupe)
		tuple id, file("${long_read}") into (pre_nanoplot)
		file("*_fastqc.{zip,html}") into (fastqc_pre_trim_results) optional true

        """
        if [[ ${params.qc} == "true" ]]; then
                if [[ ${params.assembly} == "hybrid" ]]; then
                        fastqc -f fastq ${forward_pair} ${reverse_pair} ${long_read} -t ${threads}
                elif [[ ${params.assembly} == "nonhybrid" ]]; then
                        fastqc -f fastq ${forward_pair} ${reverse_pair} -t ${threads}
                elif [[ ${params.assembly} == "longread" ]]; then
                        fastqc -f fastq ${long_read} -t ${threads}
                fi
        fi 
	"""
}

process Nanoplot {
        tag "$id"

        publishDir "${params.output}/Quality_Control/Nanoplot", mode: "symlink"

        input:
                /* tuple id, file(long_read), file(forward_pair), file(reverse_pair) from files_pre_nanoplot */
                /* tuple id, file(long_read), file(forward_pair), file(reverse_pair), genus from files */
                tuple id, file(long_read) from pre_nanoplot

        output:
                /* tuple id, genus, file("${long_read}"), file("${forward_pair}"), file("${reverse_pair}") into (files_pre_fastqc, files_pre_trim) */
                file "${id}.NanoPlot-report.html" optional true
                file "${id}.NanoStats.txt" optional true

        when: ( "${assembly}" == "hybrid" || "${assembly}" == "longread" )  && "${params.qc}" == "true"

        """
                NanoPlot --threads ${params.nanoplot_threads} -o Nanoplot -f pdf --title "NanoPlot_${id}_MinION" --fastq ${long_read}
                mv Nanoplot/NanoPlot-report.html ./${id}.NanoPlot-report.html
                mv Nanoplot/NanoStats.txt ./${id}.NanoStats.txt
        """
}

process preMultiQC {
        /* conda 'multiqc' */

        publishDir "${params.output}/Quality_Control/MultiQC", mode: "symlink"

        input:
                file ('fastqc_pre_trim??/*') from fastqc_pre_trim_results.collect().ifEmpty([])
        output:
                file "*.html"

	when: "${params.qc}" == "true"

        """
        export LC_ALL=C.UTF-8
        export LANG=C.UTF-8
        /opt/miniconda/bin/multiqc .  --title "Pre-trimming FastQC"

        """

}

process Dedupe {
	tag "$id"

    input:
        tuple id, genus, r_ref, g_ref, file(long_read), file(forward_pair), file(reverse_pair) from files_pre_dedupe
    output:
	tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${id}_R1_dedupe.fastq"), file("${id}_R2_dedupe.fastq") into (files_pre_trim)

    """
	if [[ ${params.assembly} == "hybrid" || ${params.assembly} == "nonhybrid" ]]; then
		/opt/bbmap/dedupe.sh in1=${forward_pair} in2=${reverse_pair} out="${id}_dedupe.fq" ac=f
		/opt/bbmap/reformat.sh in="${id}_dedupe.fq" out1="${id}_R1_dedupe.fastq" out2="${id}_R2_dedupe.fastq"
	elif [[ ${params.assembly} == "longread" ]]; then
                touch ${id}_R1_dedupe.fastq
		touch ${id}_R2_dedupe.fastq
        fi

    """
}

process QualityControl {
    tag "$id"

    /* publishDir "${params.output}/Quality_Control/Trimmomatic/${id}", mode: "symlink" */

    input:
        tuple id, genus, r_ref, g_ref, file(long_read), file(forward_pair), file(reverse_pair) from files_pre_trim
    output:
        file "${id}_paired_R1.fastq" optional true
        file "${id}_paired_R2.fastq" optional true
	tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${id}_paired_R1.fastq"), file("${id}_paired_R2.fastq") into (files_pre_unicycler)
        /* tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${id}_paired_R1.fastq"), file("${id}_paired_R2.fastq") into (pre_ariba) */
        tuple id, genus, file("${long_read}"), file("${id}_paired_R1.fastq"), file("${id}_paired_R2.fastq") into files_pre_postFastQC



    """
        if [[ ${params.qc} == "true" ]]; then

                if [[ ${params.assembly} == "hybrid" || ${params.assembly} == "nonhybrid" ]]; then
                        java -jar ${TRIMMOMATIC} PE $forward_pair $reverse_pair \
                        ${id}_paired_R1.fastq \
                        ${id}_unpaired_R1.fastq \
                        ${id}_paired_R2.fastq \
                        ${id}_unpaired_R2.fastq \
                        LEADING:${params.leading} \
                        TRAILING:${params.trailing} \
                        SLIDINGWINDOW:${params.slidingwindow} \
                        MINLEN:${params.minlen}
                elif [[ ${params.assembly} == "longread" ]]; then
                        touch ${id}_paired_R1.fastq
                        touch ${id}_paired_R2.fastq

                fi
        elif [[ ${params.qc} == "false" ]]; then
            touch ${id}_paired_R1.fastq
            touch ${id}_paired_R2.fastq
	fi
    """

    /* ILLUMINACLIP:${ADAPTERS}:2:30:10:3:TRUE \ */
}
process postFastQC {
        tag "$id"

        publishDir "${params.output}/Quality_Control/FastQC/Post_QC", mode: "symlink"

        input:
                tuple id, genus, file(long_read), file(forward_pair), file(reverse_pair) from files_pre_postFastQC

        output:
                file("*_fastqc.{zip,html}") into (fastqc_post_trim_results)

	when: ( "${assembly}" == "nonhybrid" || "${assembly}" == "hybrid" ) && "${params.qc}" == "true"

        """
        if [[ ${params.assembly} == "hybrid" ]]; then
                fastqc -f fastq ${forward_pair} ${reverse_pair} ${long_read} -t ${threads}
        elif [[ ${params.assembly} == "nonhybrid" ]]; then
                fastqc -f fastq ${forward_pair} ${reverse_pair} -t ${threads}
	fi
        """

}
process postMultiQC {
        /* conda 'multiqc' */

        publishDir "${params.output}/Quality_Control/MultiQC", mode: "symlink"

        input:
                file ('fastqc_post_trim??/*') from fastqc_post_trim_results.collect().ifEmpty([])
        output:
                file "*.html"
	
        when: ( "${assembly}" == "nonhybrid" || "${assembly}" == "hybrid" ) && "${params.qc}" == "true"
        
	"""
        export LC_ALL=C.UTF-8
        export LANG=C.UTF-8
        /opt/miniconda/bin/multiqc .  --title "Post-trimming FastQC"

        """

}

process Unicycler {
	tag "$id"
	
	publishDir "${params.output}/Assembly/Unicycler/${id}", mode: "symlink"

	input:
		tuple id, genus, r_ref, g_ref, file(long_read), file(forward), file(reverse) from files_pre_unicycler
	output:
		tuple id, genus, r_ref, g_ref, file("${id}.assembly.fasta") into (unicycler_pre_prokka, unicycler_pre_quast, pre_sistr)
		tuple id, file("${forward}"), file("${reverse}"), file("${id}.assembly.fasta") into (pre_BAM)
		tuple id, file("${id}.assembly.gfa") into (pre_bandage)
		tuple id, file("${id}.assembly.fasta") into (pre_phigaro)
		file "${id}.assembly.gfa"
		file "${id}.unicycler.log"

        """
	if [[ ${params.assembly} == "hybrid" ]]; then
		unicycler \
		-t ${threads} \
		-1 ${forward} \
		-2 ${reverse} \
		-l ${long_read} \
		-o Unicycler \
		--no_correct \
		--mode ${params.mode} \
	        --spades_path ${params.spades_path} \
	        --makeblastdb_path ${params.makeblastdb_path} \
	        --tblastn_path ${params.tblastn_path} \
	        --pilon_path ${params.pilon_path} \
	        --racon_path ${params.racon_path} \
	        --bowtie2_path ${params.bowtie2_path} \
	        --bowtie2_build_path ${params.bowtie2_build_path}
	elif [[ ${params.assembly} == "nonhybrid" ]]; then
		unicycler \
                -t ${threads} \
                -1 ${forward} \
                -2 ${reverse} \
                -o Unicycler \
                --no_correct \
                --mode ${params.mode} \
                --spades_path ${params.spades_path} \
                --makeblastdb_path ${params.makeblastdb_path} \
                --tblastn_path ${params.tblastn_path} \
                --pilon_path ${params.pilon_path} \
                --racon_path ${params.racon_path} \
                --bowtie2_path ${params.bowtie2_path} \
                --bowtie2_build_path ${params.bowtie2_build_path}
	elif [[ ${params.assembly} == "longread" ]]; then
                unicycler \
                -t ${threads} \
                -l ${long_read} \
                -o Unicycler \
                --no_correct \
                --mode ${params.mode} \
                --spades_path ${params.spades_path} \
                --makeblastdb_path ${params.makeblastdb_path} \
                --tblastn_path ${params.tblastn_path} \
                --pilon_path ${params.pilon_path} \
                --racon_path ${params.racon_path} \
                --bowtie2_path ${params.bowtie2_path} \
                --bowtie2_build_path ${params.bowtie2_build_path}
	fi

        mv Unicycler/assembly.fasta ./${id}.assembly.fasta
        mv Unicycler/assembly.gfa ./${id}.assembly.gfa
        mv Unicycler/unicycler.log ./${id}.unicycler.log

	"""
}

process BAM {
        tag "$id"

        publishDir "${params.output}/Assembly/BAM", mode: "symlink"

        input:
		tuple id, file(forward), file(reverse), file(assembly_fasta) from pre_BAM
        output:
		file "${id}.align.sorted.bam"
		file "${id}.align.sorted.bam.bai"
        
	when: "${assembly}" == "nonhybrid" || "${assembly}" == "hybrid"

	"""
	bwa index ${assembly_fasta}
	bwa mem -M -t ${threads} ${assembly_fasta} ${forward} ${reverse}  > "${id}.align.sam"
	samtools view -bS --threads ${threads} "${id}.align.sam" > "${id}.align.bam"
	samtools sort --threads ${threads} "${id}.align.bam" > "${id}.align.sorted.bam"
	samtools index -b -@ ${threads} "${id}.align.sorted.bam"

        """
}

process QUAST {
	tag "$id"
	
	publishDir "${params.output}/Assembly/QUAST/${id}", mode: "symlink"

	input:
		tuple id, genus, r_ref, g_ref, file(assembly_fasta) from unicycler_pre_quast
		
	output:
		file("QUAST/*") into (quast_results)
		file "${id}.report.tsv"
		file "${id}.report.html"

	"""
        ${params.quast_path}/quast.py \
        --threads ${threads} \
        -o QUAST \
        --labels "${id}_Assembly" \
        ${assembly_fasta} 
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

process Bandage {
    tag "$id"

    publishDir "${params.output}/Assembly/Bandage_graphs", mode: "symlink"

    input:
	    tuple id, file(assembly_gfa) from pre_bandage

    output:
	    file "${id}.graph.svg"

	"""
	/opt/Bandage image ${assembly_gfa} ${id}.graph.svg
    
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
                tuple id, genus, r_ref, g_ref, file (assembly_fasta) from pre_sistr
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
             tuple id, genus, r_ref, g_ref, file(assembly_fasta) from unicycler_pre_prokka
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
        
	mv Prokka/${id}.genome.txt ./${id}.genome.txt
        mv Prokka/${id}.genome.tsv ./${id}.genome.tsv
        mv Prokka/${id}.genome.err ./${id}.genome.err
        mv Prokka/${id}.genome.gff ./${id}.genome.gff
        mv Prokka/${id}.genome.sqn ./${id}.genome.sqn
        mv Prokka/${id}.genome.faa ./${id}.genome.faa
        mv Prokka/${id}.genome.gbk ./${id}.genome.gbk
        mv Prokka/${id}.genome.log ./${id}.genome.log

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
    /opt/miniconda/bin/abricate --threads ${threads} --db plasmidfinder ${assembly_gbk} > ${id}.pf.tab
    /opt/miniconda/bin/abricate --threads ${threads} --db argannot ${assembly_gbk} > ${id}.arg.tab
    /opt/miniconda/bin/abricate --threads ${threads} --db card ${assembly_gbk} > ${id}.card.tab
    /opt/miniconda/bin/abricate --threads ${threads} --db megares ${assembly_gbk} > ${id}.meg.tab
    /opt/miniconda/bin/abricate --threads ${threads} --db resfinder ${assembly_gbk} > ${id}.rf.tab
    /opt/miniconda/bin/abricate --threads ${threads} --db vfdb ${assembly_gbk} > ${id}.vfdb.tab
    /opt/miniconda/bin/abricate --threads ${threads} --db ncbi  ${assembly_gbk} > ${id}.ncbi.tab
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

def extractFastq(tsvFile) {
    /* Extracts Read Files from TSV */
    Channel.from(tsvFile)
    .ifEmpty {exit 1, log.info "Cannot find path file ${tsvFile}"}
    .splitCsv(sep:',')
    .map { row ->
    if(params.assembly == "hybrid") {
	/* Hybrid */
	def id = row[0]
	def forward_pair = returnFile(row[3])
	def reverse_pair = returnFile(row[4])
	def long_read = returnFile(row[2])
	def genus = row[1]
        def r_ref = returnFile(row[5])
        def g_ref = returnFile(row[6])
	[id, long_read, forward_pair, reverse_pair, genus, r_ref, g_ref]  
    } else if (params.assembly == "nonhybrid") {
	/* Non-Hybrid */
	def id = row[0]
	def forward_pair = returnFile(row[3])
	def reverse_pair = returnFile(row[4])
        def genus = row[1]
	def r_ref = returnFile(row[5])
	def g_ref = returnFile(row[6])
	def long_read = ""
        [id, long_read, forward_pair, reverse_pair, genus, r_ref, g_ref]
    } else if (params.assembly == "longread") {
        /* Long-Read Only */
        def id = row[0]
	def long_read = returnFile(row[2])
        def genus = row[1]
        def r_ref = returnFile(row[5])
        def g_ref = returnFile(row[6])
        def forward_pair = ""
	def reverse_pair = ""
        [id, long_read, forward_pair, reverse_pair, genus, r_ref, g_ref]

    }
   }
}

def helpMessage() {
    //log.info nfcoreHeader()
    log.info"""

usage: R2R.nf [--help] [--input] [--output] [--assembly] [--help] [--leading] [--trailing] [--minlen] [--slindingwindow] [--trailing] [--mode] [--serovar] [--threads] [-resume] [--name]
    
Reads2Resistome: a bacterial genome assembler and resistome identification pipeline 
    
    
    Example Usage: (Hybrid assembly using an Ecoli Prokka database)
    
        nextflow R2R.nf --input "containers/data/raw/input_3_Samples.csv " --assembly hybrid --output "temp/output" -w "temp/work" --name Hybrid_Test

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
                                        long_read = Assembly using MinION long reads only
	Nextflow:
	    --name	    STR	    Name of current run

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

     Documentation: https://github.com/BioRRW/Reads2Resistome


    """.stripIndent()
}


