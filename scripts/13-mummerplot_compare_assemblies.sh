#!/usr/bin/env bash

# it was given 1 cpu per task because mummerplot does not have a thread option 
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=02:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=mummerplot_compare_assemblies
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path for the mummerplot's container 
CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# reference genome 
REF_DIR="/data/courses/assembly-annotation-course/references"
REF_FASTA="${REF_DIR}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
# output directories 
OUTDIR="${WORKDIR}/results/assembly_comparison"
MUMMERPLOT_OUTPUT="${OUTDIR}/mummerplot"

# output from nucmer that will be used as input by mummerplot
NUCMER_OUTPUT="${OUTDIR}/nucmer"
# assemblies absolute path 
FLYE_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/flye/assembly.fasta"
HIFIASM_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/hifiasm/ERR11437339.fa"
LJA_ASSEMBLY="/data/users/vmungai/assembly-annotation-course2026/results/assembly/lja/assembly.fasta"
# prefix for mummerplot 
FLYE_PREFIX="ref_vs_flye"
HIFIASM_PREFIX="ref_vs_hifiasm"
LJA_PREFIX="ref_vs_lja"
FLYE_VS_HIFIASM_PREFIX="flye_vs_hifiasm"
FLYE_VS_LJA_PREFIX="flye_vs_lja"
LJA_VS_HIFIASM_PREFIX="lja_vs_hifiasm"

# only if the directory does not exist it will be created 
if [ ! -d "$MUMMERPLOT_OUTPUT" ]; then 
    echo "directory ${MUMMERPLOT_OUTPUT} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$MUMMERPLOT_OUTPUT"
fi

# enter in the output directory for mummerplot assembly 
cd "$MUMMERPLOT_OUTPUT"
# draw a dotplot from the generated .delta file for Flye  
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$REF_FASTA" -Q "${FLYE_ASSEMBLY}" -p "$FLYE_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${FLYE_PREFIX}.delta"
# draw a dotplot from the generated .delta file for Hifiasm 
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$REF_FASTA" -Q "${HIFIASM_ASSEMBLY}" -p "$HIFIASM_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${HIFIASM_PREFIX}.delta"
# draw a dotplot from the generated .delta file for Lja  
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$REF_FASTA" -Q "${LJA_ASSEMBLY}" -p "$LJA_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${LJA_PREFIX}.delta"

# draw a dotplot from the generated .delta file for Flye vs Hifiasm
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$FLYE_ASSEMBLY" -Q "${HIFIASM_ASSEMBLY}" -p "$FLYE_VS_HIFIASM_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${FLYE_VS_HIFIASM_PREFIX}.delta"
# draw a dotplot from the generated .delta file for Flye vs Lja
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "$FLYE_ASSEMBLY" -Q "${LJA_ASSEMBLY}" -p "$FLYE_VS_LJA_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${FLYE_VS_LJA_PREFIX}.delta"
# draw a dotplot from the generated .delta file for Lja vs Hifiasm  
apptainer exec --bind "$DATA_DIR" "$CONTAINER" mummerplot \
    -R "${LJA_ASSEMBLY}" -Q "$HIFIASM_ASSEMBLY" -p "$LJA_VS_HIFIASM_PREFIX" --filter -t png --large --layout --fat "${NUCMER_OUTPUT}/${LJA_VS_HIFIASM_PREFIX}.delta"
