#!/usr/bin/env nextflow

params.accession_id = "M21012"
params.input_dir = "exam/hepatitis"
params.output_combined_file = "combined.fasta"
params.mafft_output = "combined_aligned.fasta"
params.trimal_output = "combined_aligned_trimmed.fasta"
params.trimal_report_html = "trimal_report.html"
params.outdir = "results"

// Fetch Data //
process FETCH_FASTA {
    conda 'bioconda::entrez-direct=24.0'
    input:
    val accession_id
    output:
    path "${accession_id}.fasta"
    script:
    """
    esearch -db nucleotide -query "${accession_id}" | efetch -format fasta > "${accession_id}.fasta"
    """
}

// Combine File //
process COMBINE_SEQS {
    input:
    path fasta_files
    output:
    path "${params.output_combined_file}"
    script:
    """
    cat ${fasta_files.join(' ')} > ${params.output_combined_file}
    """
}

// MAFFT Alignment Process //
process ALIGN_MAFFT {
    conda 'bioconda::mafft=7.525'
    input:
    path input_fasta
    output:
    path "${params.mafft_output}"
    script:
    """
    mafft --auto --thread -1 "${input_fasta}" > "${params.mafft_output}"
    """
}

// Trimal Process //
process TRIMAL_ALIGNMENT {
    conda 'bioconda::trimal=1.5.0'
    publishDir "${params.outdir}/trimal_results", mode: 'copy', pattern: '*'
    input:
    path input_aligned_fasta
    output:
    path "${params.trimal_output}"
    path "${params.trimal_report_html}"
    script:
    """
    trimal -in "${input_aligned_fasta}" -out "${params.trimal_output}" -automated1 -htmlout "${params.trimal_report_html}"
    """
}

// Workflow //
workflow {
    // Download reference
    ref_fasta_ch = FETCH_FASTA(params.accession_id)

    // Get sample FASTA files
    sample_fastas_ch = Channel.fromPath("${params.input_dir}/*.fasta")

    // Combine reference and sample FASTAs into a list
    all_fastas_ch = ref_fasta_ch.concat(sample_fastas_ch).collect()

    // Combine all FASTA files into one
    combined = COMBINE_SEQS(all_fastas_ch)
    aligned = ALIGN_MAFFT(combined)
    TRIMAL_ALIGNMENT(aligned)
}
