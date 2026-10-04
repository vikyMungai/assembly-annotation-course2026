#!/usr/bin/env bash

#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=nucmer_compare_assemblies
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path to the NUCmer container
CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# reference genome 
REF_DIR="/data/courses/assembly-annotation-course/references"
REF_FASTA="${REF_DIR}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
# output directories 
OUTDIR="${WORKDIR}/results/assembly_comparison"
NUCMER_OUTPUT="${OUTDIR}/nucmer"

# absolute paths to the genome assemblies
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"

# output prefixes for the NUCmer alignments
FLYE_PREFIX="ref_vs_flye"
HIFIASM_PREFIX="ref_vs_hifiasm"
LJA_PREFIX="ref_vs_lja"
FLYE_VS_HIFIASM_PREFIX="flye_vs_hifiasm"
FLYE_VS_LJA_PREFIX="flye_vs_lja"
LJA_VS_HIFIASM_PREFIX="lja_vs_hifiasm"

# create the NUCmer output directory if it does not already exist
if [ ! -d "$NUCMER_OUTPUT" ]; then 
    echo "directory ${NUCMER_OUTPUT} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$NUCMER_OUTPUT"
fi 

# change to the NUCmer output directory
cd "$NUCMER_OUTPUT"
# align the Flye assembly against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$FLYE_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$REF_FASTA" "$FLYE_ASSEMBLY"  
# align the hifiasm assembly against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$HIFIASM_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$REF_FASTA" "$HIFIASM_ASSEMBLY"
# align the LJA assembly against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$LJA_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$REF_FASTA" "$LJA_ASSEMBLY"


# compare the genome assemblies against each other

# align the Flye assembly against the hifiasm assembly
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$FLYE_VS_HIFIASM_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$FLYE_ASSEMBLY" "$HIFIASM_ASSEMBLY"
# align the Flye assembly against the LJA assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$FLYE_VS_LJA_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$FLYE_ASSEMBLY" "$LJA_ASSEMBLY"
# align the LJA assembly against the hifiasm assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$LJA_VS_HIFIASM_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$LJA_ASSEMBLY" "$HIFIASM_ASSEMBLY"
