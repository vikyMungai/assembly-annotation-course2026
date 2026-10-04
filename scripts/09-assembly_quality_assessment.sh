#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=quast_quality_assessment
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e


# path for the quast's container 
CONTAINER="/containers/apptainer/quast_5.2.0.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# reference genome 
REF_DIR="/data/courses/assembly-annotation-course/references"
REF_FASTA="Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
REF_FEATURES="TAIR10_GFF3_genes.gff"
# output directory 
OUTDIR="${WORKDIR}/results/assembly_evaluation/quast"
QUAST_WITH_REF="${OUTDIR}/with_reference"
QUAST_WITHOUT_REF="${OUTDIR}/without_reference"

# assemblies absolute path 
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
# reference estimated size from Genome Scope 
REF_SIZE=126836787


# only if the directory does not exist it will be created 
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$OUTDIR"
fi 

# assembly evaluation with QUAST with reference genome 
# the option --eukaryote could have been removed, as the option --large is used
apptainer exec --bind "$DATA_DIR" $CONTAINER quast.py \
    --eukaryote --large --labels "flye,hifiasm,lja" \
    -r "${REF_DIR}/${REF_FASTA}" --features "${REF_DIR}/${REF_FEATURES}" \
    --pacbio "$PACBIO_FASTQ" --no-sv \
    --output-dir "$QUAST_WITH_REF" \
    --threads $SLURM_CPUS_PER_TASK "$FLYE_ASSEMBLY" "$HIFIASM_ASSEMBLY" "$LJA_ASSEMBLY"


# assembly evaluation with QUAST without reference genome 
# the option --eukaryote could have been removed, as the option --large is used
apptainer exec --bind "$DATA_DIR" $CONTAINER quast.py \
    --eukaryote --large --labels "flye,hifiasm,lja" \
    --est-ref-size "$REF_SIZE" --pacbio "$PACBIO_FASTQ" --no-sv \
    --output-dir "$QUAST_WITHOUT_REF" \
    --threads $SLURM_CPUS_PER_TASK "$FLYE_ASSEMBLY" "$HIFIASM_ASSEMBLY" "$LJA_ASSEMBLY"
