#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=busco_evaluation
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e


# path to the BUSCO container
CONTAINER="/containers/apptainer/busco_5.7.1.sif"

# set the paths to the working directory and data directory 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly_evaluation/busco"
#  BUSCO lineage dataset
LINEAGE="brassicales_odb10"
# BUSCO analysis modes
GENOME_MODE="genome"
TRANSCRIPTOME_MODE="transcriptome"

# absolute paths to the assemblies
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
TRINITY_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/trinity.Trinity.fasta"

# output directory names for each BUSCO evaluation
FLYE_OUTPUT="flye_evaluation"
HIFIASM_OUTPUT="hifiasm_evaluation"
LJA_OUTPUT="lja_evaluation"
TRINITY_OUTPUT="trinity_evaluation"

# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$OUTDIR"
fi 

# evaluate the assemblies with BUSCO

# evaluate the Flye genome assembly 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" busco \
    -i "$FLYE_ASSEMBLY" --out_path "$OUTDIR" --out "$FLYE_OUTPUT" --mode "$GENOME_MODE" -l "$LINEAGE" --cpu "$SLURM_CPUS_PER_TASK" 

# evaluate the hifiasm genome assembly
apptainer exec --bind "$DATA_DIR" "$CONTAINER" busco \
    -i "$HIFIASM_ASSEMBLY" --out_path "$OUTDIR" --out "$HIFIASM_OUTPUT" --mode "$GENOME_MODE" -l "$LINEAGE" --cpu "$SLURM_CPUS_PER_TASK" 

# evaluate the LJA genome assembly
apptainer exec --bind "$DATA_DIR" "$CONTAINER" busco \
    -i "$LJA_ASSEMBLY" --out_path "$OUTDIR" --out "$LJA_OUTPUT" --mode "$GENOME_MODE" -l "$LINEAGE" --cpu "$SLURM_CPUS_PER_TASK" 


# evaluate the Trinity transcriptome assembly
apptainer exec --bind "$DATA_DIR" "$CONTAINER" busco \
    -i "$TRINITY_ASSEMBLY" --out_path "$OUTDIR" --out "$TRINITY_OUTPUT" --mode "$TRANSCRIPTOME_MODE"  -l "$LINEAGE" --cpu "$SLURM_CPUS_PER_TASK" 
