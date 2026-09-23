#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=LJA_assembly
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path for the lja's container 
CONTAINER="/containers/apptainer/lja-0.2.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly/lja"
# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"


# only if the directory does not exist it will be created 
if [ ! -d $OUTDIR ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p $OUTDIR
fi 

# assembly the PacBio reads with lja tool 
apptainer exec --bind "$DATA_DIR" $CONTAINER lja \
    -o "$OUTDIR" -t $SLURM_CPUS_PER_TASK --reads "$PACBIO_FASTQ"