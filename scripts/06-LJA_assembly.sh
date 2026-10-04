#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=LJA_assembly
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path to the LJA container
CONTAINER="/containers/apptainer/lja-0.2.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly/lja"
# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"


# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$OUTDIR"
fi 

# assemble the PacBio HiFi reads using LJA
apptainer exec --bind "$DATA_DIR" $CONTAINER lja \
    -o "$OUTDIR" -t $SLURM_CPUS_PER_TASK --reads "$PACBIO_FASTQ"
