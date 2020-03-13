#!/usr/bin/env nextflow

/* Versions
1.0: working hybrid (tried 2 samples) w/ separate simg files
1.1: "   " w/poretools QC
1.2" "              " w/bandage graph
2.0: hybrid with single simg 18.04 (no porechop yet, need raw-er data)
2.1: hybrid assembly option added, working on help menu
2.4: meh
2.4: adding in short-read only assembly
2.5: multiqc - working for fastqc
2.6: Bandage working
2.7: SISTR functionality for Salmonella, multi-species input, multiqc (except QUAST)
2.8: beautifying output directories and (testing QUAST multiQC)
2.9: adding QUAST reference: user must supply!!! (added info to help menu)
3.0: Re-route input through fastQC first, then nanoplot, trimm and ARIBA
3.0.1: working on ARIBA issues ********* no prokka or unicycler! **************
4.0: QUAST (refs via input.csv) Prokka (working on adding in default)
4.0.1: bam alignments bamdedupe, prokka via input csv ONLY
5.0: long-read only assembly
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

/* Set Hybrid/Non-Hybrid flag */
/* Hybrid = true, Non-Hybrid = false */
/* Hybrid = checkHybrid(Inputreads) save for when have check */

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

        publishDir "${params.output}/Quality_Control/Nanoplot/${id}", mode: "symlink"

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
                NanoPlot --threads ${params.nanoplot_threads} -o Nanoplot -f pdf --title "NanoPlot_${id}_MinION" --fasta ${long_read}
                mv Nanoplot/NanoPlot-report.html ./${id}.NanoPlot-report.html
                mv Nanoplot/NanoStats.txt ./${id}.NanoStats.txt
        """
}

process preMultiQC {
        conda 'multiqc'

        publishDir "${params.output}/Quality_Control/MultiQC/Pre_QC", mode: "symlink"

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
		dedupe.sh in1=${forward_pair} in2=${reverse_pair} out="${id}_dedupe.fq" ac=f
		reformat.sh in="${id}_dedupe.fq" out1="${id}_R1_dedupe.fastq" out2="${id}_R2_dedupe.fastq"
	elif [[ ${params.assembly} == "longread" ]]; then
                touch ${id}_R1_dedupe.fastq
		touch ${id}_R2_dedupe.fastq
        fi

    """
}

process QualityControl {
    tag "$id"

    publishDir "${params.output}/Quality_Control/Trimmomatic/${id}", mode: "symlink"

    input:
        tuple id, genus, r_ref, g_ref, file(long_read), file(forward_pair), file(reverse_pair) from files_pre_trim
    output:
        file "${id}_paired_R1.fastq" optional true
        file "${id}_paired_R2.fastq" optional true
	/* tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${id}_paired_R1.fastq"), file("${id}_paired_R2.fastq") into (files_pre_unicycler) */
        tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${id}_paired_R1.fastq"), file("${id}_paired_R2.fastq") into (pre_ariba)
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
        conda 'multiqc'

        publishDir "${params.output}/Quality_Control/MultiQC/Post_QC", mode: "symlink"

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

process ARIBA {
        tag "$id"

        memory '10 GB'
	maxForks 1

        publishDir "${params.output}/Annotation/ARIBA/${id}", mode: "symlink"

        input:
                tuple id, genus, r_ref, g_ref, file(long_read), file(forward), file(reverse) from pre_ariba


        output:
                tuple id, genus, r_ref, g_ref, file("${long_read}"), file("${forward}"), file("${reverse}") into (files_pre_unicycler)
                tuple id, file("${id}.card.assemblies.fa.gz") into (ariba_card_assemblies) optional true
                tuple id, file("${id}.megares.assemblies.fa.gz") into (ariba_megares_assemblies) optional true
                tuple id, file("${id}.plasmidfinder.assemblies.fa.gz") into (ariba_plasmidfinder_assemblies) optional true
                tuple id, file("${id}.virulencefinder.assemblies.fa.gz") into (ariba_virulencefinder_assemblies) optional true
                file("${id}.card.report.tsv") into (ariba_card_reports) optional true
                file("${id}.megares.report.tsv") into (ariba_megares_reports) optional true
                file("${id}.plasmidfinder.report.tsv") into (ariba_plasmidfinder_reports) optional true
                file("${id}.virulencefinder.report.tsv") into (ariba_virulencefinder_reports) optional true


        """
        if [[ ${params.ariba_run} == "true" ]]; then
                ariba run \
                --threads ${params.ariba_threads} \
                /opt/card.prepareref.out \
                ${forward} \
                ${reverse} ariba_out_card
                mv ariba_out_card/assemblies.fa.gz ./${id}.card.assemblies.fa.gz
                mv ariba_out_card/report.tsv ./${id}.card.report.tsv

                ariba run \
                --threads ${params.ariba_threads} \
                /opt/megares.prepareref.out \
                ${forward} \
                ${reverse} ariba_out_megares
                mv ariba_out_megares/assemblies.fa.gz ./${id}.megares.assemblies.fa.gz
                mv ariba_out_megares/report.tsv ./${id}.megares.report.tsv

                ariba run \
                --threads ${params.ariba_threads} \
                /opt/plasmidfinder.prepareref.out \
                ${forward} \
                ${reverse} ariba_out_plasmidfinder
                mv ariba_out_plasmidfinder/assemblies.fa.gz ./${id}.plasmidfinder.assemblies.fa.gz
                mv ariba_out_plasmidfinder/report.tsv ./${id}.plasmidfinder.report.tsv

                ariba run \
                --threads ${params.ariba_threads} \
                /opt/virulencefinder.prepareref.out \
                ${forward} \
                ${reverse} ariba_out_virulencefinder
                mv ariba_out_virulencefinder/assemblies.fa.gz ./${id}.virulencefinder.assemblies.fa.gz
                mv ariba_out_virulencefinder/report.tsv ./${id}.virulencefinder.report.tsv
	fi
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

        publishDir "${params.output}/Assembly/BAM/${id}", mode: "symlink"

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
        ${assembly_fasta} \
        -r ${r_ref} \
        -g ${g_ref}
        cp QUAST/report.tsv ./${id}.report.tsv
        cp QUAST/report.html ./${id}.report.html
        cp QUAST/icarus.html ./${id}.icarus.html
	"""
	
}

process QUASTMultiQC {
        conda 'multiqc'

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
/*
process Phigaro {
    tag "$id"

    publishDir "${params.output}/Assembly/Phigaro", mode: "symlink"

    input:
            tuple id, file(assembly_fasta) from pre_phigaro

    output:
            file ""

        """
	phigaro \
	-f ${assembly_fasta} \
	-o "${id}.phigaro" \
        -c /opt/configure/phigaro/config.yml \
	-e tsv html \
	--not-open \
	-d \
	-t ${threads}  
        """
}
*/
process SISTR {
        conda 'sistr_cmd'

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

process SummarizeAribaReports {
    tag { "ARIBA Reports" }
    
    publishDir "${params.output}/Annotation/ARIBA/Summary", mode: "symlink"

	input:
		file card_reports from ariba_card_reports.toList()
		file megares_reports from ariba_megares_reports.toList()
		file plasmidfinder_reports from ariba_plasmidfinder_reports.toList()
		file virulencefinder_reports from ariba_virulencefinder_reports.toList()
    output:
		tuple file("ariba.card.summary.csv"), file("ariba.megares.summary.csv"), file("ariba.plasmidfinder.summary.csv"), file("ariba.virulencefinder.summary.csv") into (ariba_summary_files) optional true

    """
        if [[ ${params.ariba_run} == "true" ]]; then
		ariba summary ariba.card.summary $card_reports --no_tree
		ariba summary ariba.megares.summary $megares_reports --no_tree
		ariba summary ariba.plasmidfinder.summary $plasmidfinder_reports --no_tree
		ariba summary ariba.virulencefinder.summary $virulencefinder_reports --no_tree
	fi
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
            --leading       INT     cut bases off the start of a read, if below a threshold quality 
            --minlen        INT     drop the read if it is below a specified length 
            --slidingwindow INT     perform sw trimming, cutting once the average quality within the window falls below a threshold 
            --trailing      INT     cut bases off the end of a read, if below a threshold quality 

        Assembly: 
            --mode          STR     (default: normal)
                                    conservative = smaller contigs, lowest misassembly rate
                                    normal = moderate contig size and misassembly rate
                                    bold = longest contigs, higher misassembly rate                              
        Annotation: 
            --ariba_run     STR     (default: true)
                                    false = ARIBA will not run
            --prokka_run    STR     (default: true)
                                    false = Prokka will not run
        Computation:
            --threads       INT     Number of CPUs to allocate to EACH process individually 
            
        Nextflow Options:
            -resume                 Pipeline will resume from previous run if terminated

     Documentation: https://github.com/BioRRW/Mixtisque


    """.stripIndent()
}


