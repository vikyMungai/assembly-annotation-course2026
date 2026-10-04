#!/usr/bin/env bash

#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=merqury_quality_assessment
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e


# path for the merqury's container 
CONTAINER="/containers/apptainer/merqury_1.3.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory for Meryl database 
OUTDIR="${WORKDIR}/results/assembly_evaluation/merqury"
MERYL_OUTPUT="${OUTDIR}/reads.meryl"

# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
# k-mers' size, same used for GenomeScope  
K=31 


# only if the directory does not exist it will be created 
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$OUTDIR"
fi 

# Build k-mer dbs with meryl
# It takes the original unassembled reads and creates a database containing the k-mers and how many times each appears
apptainer exec --bind "$DATA_DIR" "$CONTAINER" meryl \
    k=$K cpus=$SLURM_CPUS_PER_TASK memory=50g  count "$PACBIO_FASTQ" output "$MERYL_OUTPUT"
