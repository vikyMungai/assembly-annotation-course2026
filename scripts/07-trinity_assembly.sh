#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=Trinity_assembly
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# setting path of working directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
# output directory 
OUTDIR="${WORKDIR}/results/assembly/trinity"
# Illumina's reads 
RNAseq_FASTQ1="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAseq_FASTQ2="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_2.fastq.gz"

# load the assembler tool Trinity 
module load Trinity/2.15.1-foss-2021a 

# only if the directory does not exist it will be created 
if [ ! -d $OUTDIR ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p $OUTDIR
fi 

# assembly the Illumina's reads with Trinity tool 
Trinity --seqType fq --max_memory 64G --left "$RNAseq_FASTQ1" --right "$RNAseq_FASTQ2" --output "$OUTDIR" --CPU $SLURM_CPUS_PER_TASK 