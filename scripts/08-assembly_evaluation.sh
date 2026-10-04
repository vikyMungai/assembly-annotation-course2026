#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=busco_evaluation_trinity
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e


# path for the busco's container 
CONTAINER="/containers/apptainer/busco_5.7.1.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly_evaluation/busco"
# lineage that BUSCO uses 
LINEAGE="brassicales_odb10"
# mode for busco 
GENOME_MODE="genome"
TRANSCRIPTOME_MODE="transcriptome"

# assemblies absolute path 
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
TRINITY_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/trinity.Trinity.fasta"


# output files' names 
FLYE_OUTPUT="flye_evaluation"
HIFIASM_OUTPUT="hifiasm_evaluation"
LJA_OUTPUT="lja_evaluation"
TRINITY_OUTPUT="trinity_evaluation"

# only if the directory does not exist it will be created 
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$OUTDIR"
fi 

# assembly evaluation with BUSCO 

# for the assembly done with trinity 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" busco \
    -i "$TRINITY_ASSEMBLY" --out_path "$OUTDIR" --out "$TRINITY_OUTPUT" --mode "$TRANSCRIPTOME_MODE"  -l "$LINEAGE" --cpu "$SLURM_CPUS_PER_TASK" 
