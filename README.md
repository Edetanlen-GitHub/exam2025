Hepatitis Delta Genome Alignment Pipeline
This Nextflow pipeline automates the alignment and cleanup of Hepatitis delta virus genomes against a reference, as required for the NGS data analysis/pipelining module.

Features
Downloads a reference genome from GenBank using an accession number (default: M21012)

Combines all sample FASTA files from a specified directory with the reference

Aligns sequences using MAFFT

Cleans up the alignment with trimal (-automated1) and generates an HTML visualization

Publishes the cleaned alignment and HTML report to an output directory

Uses Conda for reproducible software environments

Requirements
Nextflow

Conda

Usage
From the project root directory, run:

bash
nextflow run main.nf --input_dir exam/hepatitis --accession_id M21012
--input_dir points to the directory containing your sample FASTA files.

--accession_id (optional) specifies the GenBank accession for the reference genome (default is M21012).

Output
The key results are published in:

text
results/trimal_results/
combined_aligned_trimmed.fasta — Cleaned alignment

trimal_report.html — HTML visualization of the alignment

Dependencies
The pipeline will automatically create Conda environments for:

entrez-direct=24.0

mafft=7.525

trimal=1.5.0
