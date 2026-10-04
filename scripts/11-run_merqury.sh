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

function create_dir {
# only if the directory does not exist it will be created 
#   Params: 
#           $1: directory that has to be created (absolute path)
    local DIR="$1"
    if [ ! -d "$DIR" ]; then 
        echo "directory ${DIR} created"
        # option -p create the parents' folders if they do not exist
        mkdir -p "$DIR"
    fi 
}


# path for the merqury's container 
CONTAINER="/containers/apptainer/merqury_1.3.sif"

export MERQURY="/usr/local/share/merqury"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directories for all assemblies 
OUTDIR="${WORKDIR}/results/assembly_evaluation/merqury"
FLYE_OUTPUT="${OUTDIR}/flye_evaluation"
HIFIASM_OUTPUT="${OUTDIR}/hifiasm_evaluation"
LJA_OUTPUT="${OUTDIR}/lja_evaluation"

# absolute path for Meryl database 
MERYL_DB="${OUTDIR}/reads.meryl"
# assemblies absolute path 
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
# prefix for merqury 
FLYE_PREFIX="flye"
HIFIASM_PREFIX="hifiasm"
LJA_PREFIX="lja"

# to set the number of threads that merqury can use 
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# create the directories for the different assemblies to avoid conflicts in case the filenames are the same
create_dir "$FLYE_OUTPUT"
create_dir "$HIFIASM_OUTPUT"
create_dir "$LJA_OUTPUT"

# enter in the output directory for Flye assembly 
cd "$FLYE_OUTPUT"
# Overall k mer evaluation on Flye assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" "$MERQURY/merqury.sh" \
    "$MERYL_DB" "$FLYE_ASSEMBLY" "$FLYE_PREFIX"


# enter in the output directory for Hifiasm assembly 
cd "$HIFIASM_OUTPUT"
# Overall k mer evaluation on Hifiasm assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" "$MERQURY/merqury.sh" \
    "$MERYL_DB" "$HIFIASM_ASSEMBLY" "$HIFIASM_PREFIX"

# enter in the output directory for lja assembly 
cd "$LJA_OUTPUT"
# Overall k mer evaluation on lja assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" "$MERQURY/merqury.sh" \
    "$MERYL_DB" "$LJA_ASSEMBLY" "$LJA_PREFIX"
