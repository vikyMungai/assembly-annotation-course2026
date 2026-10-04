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

# path for the nucmer's container 
CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# reference genome 
REF_DIR="/data/courses/assembly-annotation-course/references"
REF_FASTA="${REF_DIR}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
# output directories 
OUTDIR="${WORKDIR}/results/assembly_comparison"
NUCMER_OUTPUT="${OUTDIR}/nucmer"

# assemblies absolute path 
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
# prefix for nucmer 
FLYE_PREFIX="ref_vs_flye"
HIFIASM_PREFIX="ref_vs_hifiasm"
LJA_PREFIX="ref_vs_lja"
FLYE_VS_HIFIASM_PREFIX="flye_vs_hifiasm"
FLYE_VS_LJA_PREFIX="flye_vs_lja"
LJA_VS_HIFIASM_PREFIX="lja_vs_hifiasm"


# only if the directory does not exist it will be created 
if [ ! -d "$NUCMER_OUTPUT" ]; then 
    echo "directory ${NUCMER_OUTPUT} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$NUCMER_OUTPUT"
fi 

# enter in the output directory for nucmer output 
cd "$NUCMER_OUTPUT"
# map the assembled genome with flye against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$FLYE_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$REF_FASTA" "$FLYE_ASSEMBLY"  
# map the assembled genome with hifiasm against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$HIFIASM_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$REF_FASTA" "$HIFIASM_ASSEMBLY"
# map the assembled genome with lja against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$LJA_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$REF_FASTA" "$LJA_ASSEMBLY"


# compare assemblies between eachother 
# compare flye assembly against the hifiasm assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$FLYE_VS_HIFIASM_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$FLYE_ASSEMBLY" "$HIFIASM_ASSEMBLY"
# compare flye assembly against the lja assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$FLYE_VS_LJA_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$FLYE_ASSEMBLY" "$LJA_ASSEMBLY"
# compare lja assembly against the hifiasm assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" nucmer \
    -p "$LJA_VS_HIFIASM_PREFIX" --breaklen 1000 --mincluster 1000 -t $SLURM_CPUS_PER_TASK \
    "$LJA_ASSEMBLY" "$HIFIASM_ASSEMBLY"
