#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=hifiasm_assembly
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path to the hifiasm container
CONTAINER="/containers/apptainer/hifiasm_0.25.0.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly/hifiasm"
# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
# extract the sample name by removing the .fastq.gz extension
PREFIX=`basename "${PACBIO_FASTQ%.fastq.gz}"`
# output file basename, hifiasm will add the appropriate extensions
OUTPUT_FILE="${OUTDIR}/${PREFIX}"


# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # the -p option creates parent directories if they do not already exist
    mkdir -p "$OUTDIR"
fi 

# change to the output directory so that the results are written there
cd "$OUTDIR"

# assemble the PacBio HiFi reads using hifiasm
apptainer exec --bind "$DATA_DIR" $CONTAINER hifiasm \
    -o "$PREFIX" -t $SLURM_CPUS_PER_TASK "$PACBIO_FASTQ"

# convert the primary contig GFA output to FASTA format
awk '/^S/{print ">"$2;print $3}' ${OUTPUT_FILE}.bp.p_ctg.gfa > ${OUTPUT_FILE}.fa