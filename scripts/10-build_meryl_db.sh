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

# path to the Merqury container
CONTAINER="/containers/apptainer/merqury_1.3.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory and Meryl database
OUTDIR="${WORKDIR}/results/assembly_evaluation/merqury"
MERYL_OUTPUT="${OUTDIR}/reads.meryl"

# PacBio HiFi reads
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
# k-mer size, using the same value as in the GenomeScope analysis
K=31 


# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$OUTDIR"
fi 

# build a k-mer database from the original PacBio HiFi reads using Meryl
# the database stores each observed k-mer and its occurrence count
apptainer exec --bind "$DATA_DIR" "$CONTAINER" meryl \
    k=$K cpus=$SLURM_CPUS_PER_TASK memory=50g  count "$PACBIO_FASTQ" output "$MERYL_OUTPUT"
