#!/usr/bin/env bash

# one CPU is sufficient because mummerplot does not provide a multithreading option 
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=02:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=mummerplot_draw_dotplot
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path to the mummerplot container
CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# reference genome 
REF_DIR="/data/courses/assembly-annotation-course/references"
REF_FASTA="${REF_DIR}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
# output directories 
OUTDIR="${WORKDIR}/results/assembly_comparison"
MUMMERPLOT_OUTPUT="${OUTDIR}/mummerplot"

# NUCmer output directory containing the .delta files used as input by mummerplot
NUCMER_OUTPUT="${OUTDIR}/nucmer"
# absolute paths to the genome assemblies
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"

# output prefixes used by mummerplot 
FLYE_PREFIX="ref_vs_flye"
HIFIASM_PREFIX="ref_vs_hifiasm"
LJA_PREFIX="ref_vs_lja"
FLYE_VS_HIFIASM_PREFIX="flye_vs_hifiasm"
FLYE_VS_LJA_PREFIX="flye_vs_lja"
LJA_VS_HIFIASM_PREFIX="lja_vs_hifiasm"

# create the mummerplot output directory if it does not already exist
if [ ! -d "$MUMMERPLOT_OUTPUT" ]; then 
    echo "directory ${MUMMERPLOT_OUTPUT} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$MUMMERPLOT_OUTPUT"
fi

# change to the mummerplot output directory
cd "$MUMMERPLOT_OUTPUT"
# generate a dot plot for the Flye assembly aligned against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$REF_FASTA" -Q "${FLYE_ASSEMBLY}" -p "$FLYE_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${FLYE_PREFIX}.delta"
# generate a dot plot for the hifiasm assembly aligned against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$REF_FASTA" -Q "${HIFIASM_ASSEMBLY}" -p "$HIFIASM_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${HIFIASM_PREFIX}.delta"
# generate a dot plot for the LJA assembly aligned against the reference genome
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$REF_FASTA" -Q "${LJA_ASSEMBLY}" -p "$LJA_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${LJA_PREFIX}.delta"

# generate a dot plot comparing the Flye and hifiasm assemblies
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$FLYE_ASSEMBLY" -Q "${HIFIASM_ASSEMBLY}" -p "$FLYE_VS_HIFIASM_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${FLYE_VS_HIFIASM_PREFIX}.delta"
# generate a dot plot comparing the Flye and LJA assemblies
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$FLYE_ASSEMBLY" -Q "${LJA_ASSEMBLY}" -p "$FLYE_VS_LJA_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${FLYE_VS_LJA_PREFIX}.delta"
# generate a dot plot comparing the LJA and hifiasm assemblies  
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "${LJA_ASSEMBLY}" -Q "$HIFIASM_ASSEMBLY" -p "$LJA_VS_HIFIASM_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${LJA_VS_HIFIASM_PREFIX}.delta"
