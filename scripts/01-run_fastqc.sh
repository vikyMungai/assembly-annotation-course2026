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

# path for the fastqc's container 
CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/reads_QC"
# Illumina and PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
RNAseq_FASTQ1="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAseq_FASTQ2="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_2.fastq.gz"


# only if the directory does not exist it will be created 
if [ ! -d $OUTDIR ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p $OUTDIR
fi 

# executing the quality check on PacBio and Illumina's reads with fastqc using the container, are checked 
apptainer exec --bind "$DATA_DIR" $CONTAINER fastqc --threads $SLURM_CPUS_PER_TASK -o "$OUTDIR" "$PACBIO_FASTQ" "$RNAseq_FASTQ1" "$RNAseq_FASTQ2"

