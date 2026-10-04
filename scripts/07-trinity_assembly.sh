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

# path to the Trinity container
CONTAINER="/containers/apptainer/trinity_2.15.2.sif"

# set the paths to the working directory and data directory
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly/trinity"
# paired-end Illumina RNA-seq reads
RNAseq_FASTQ1="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAseq_FASTQ2="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_2.fastq.gz"


# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$OUTDIR"
fi 

# assemble the paired-end Illumina RNA-seq reads using Trinity
apptainer exec --bind "$DATA_DIR" $CONTAINER Trinity \
    --seqType fq --max_memory 50G --left "$RNAseq_FASTQ1" --right "$RNAseq_FASTQ2" --output "$OUTDIR" --CPU $SLURM_CPUS_PER_TASK 