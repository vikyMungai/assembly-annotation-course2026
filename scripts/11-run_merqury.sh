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
# create a directory if it does not already exist
#   Params: 
#           $1: absolute path to the directory to be created
    local DIR="$1"
    if [ ! -d "$DIR" ]; then 
        echo "directory ${DIR} created"
        # the -p option creates parent directories if they do not already exist
        mkdir -p "$DIR"
    fi 
}


# path to the Merqury container
CONTAINER="/containers/apptainer/merqury_1.3.sif"

# path to the Merqury installation inside the container
export MERQURY="/usr/local/share/merqury"

# set the paths to the working directory and data directory 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directories for the different genome assemblies
OUTDIR="${WORKDIR}/results/assembly_evaluation/merqury"
FLYE_OUTPUT="${OUTDIR}/flye_evaluation"
HIFIASM_OUTPUT="${OUTDIR}/hifiasm_evaluation"
LJA_OUTPUT="${OUTDIR}/lja_evaluation"

# path to the Meryl k-mer database
MERYL_DB="${OUTDIR}/reads.meryl"
# absolute paths to the genome assemblies
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
# output prefixes used by Merqury
FLYE_PREFIX="flye"
HIFIASM_PREFIX="hifiasm"
LJA_PREFIX="lja"

# set the number of threads available to Merqury
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# create separate output directories for each assembly to avoid filename conflicts
create_dir "$FLYE_OUTPUT"
create_dir "$HIFIASM_OUTPUT"
create_dir "$LJA_OUTPUT"

# change to the Flye output directory
cd "$FLYE_OUTPUT"
# evaluate the Flye assembly using Merqury
apptainer exec --bind "$DATA_DIR" "$CONTAINER" "$MERQURY/merqury.sh" \
    "$MERYL_DB" "$FLYE_ASSEMBLY" "$FLYE_PREFIX"


# change to the hifiasm output directory
cd "$HIFIASM_OUTPUT"
# evaluate the hifiasm assembly using Merqury
apptainer exec --bind "$DATA_DIR" "$CONTAINER" "$MERQURY/merqury.sh" \
    "$MERYL_DB" "$HIFIASM_ASSEMBLY" "$HIFIASM_PREFIX"

# change to the LJA output directory 
cd "$LJA_OUTPUT"
# evaluate the LJA assembly using Merqury
apptainer exec --bind "$DATA_DIR" "$CONTAINER" "$MERQURY/merqury.sh" \
    "$MERYL_DB" "$LJA_ASSEMBLY" "$LJA_PREFIX"
