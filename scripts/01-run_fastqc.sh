#!/usr/bin/env bash

#SBATCH --cpus-per-task=3
#SBATCH --mem=1G
#SBATCH --time=04:00:00
#SBATCH --partition=pshort_el8
#SBATCH --job-name=run_fastqc
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path for the FastQC container 
CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/reads_QC"
# Illumina and PacBio reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
RNAseq_FASTQ1="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAseq_FASTQ2="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_2.fastq.gz"


# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # the option -p creates the parents' folders if they do not exist
    mkdir -p "$OUTDIR"
fi 

# run FastQC on the PacBio and Illumina reads using the container
apptainer exec --bind "$DATA_DIR" "$CONTAINER" fastqc \
    --threads $SLURM_CPUS_PER_TASK -o "$OUTDIR" \
    "$PACBIO_FASTQ" "$RNAseq_FASTQ1" "$RNAseq_FASTQ2"

