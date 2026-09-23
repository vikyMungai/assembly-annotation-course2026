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

# path for the hifiasm's container 
CONTAINER="/containers/apptainer/hifiasm_0.25.0.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/assembly/hifiasm"
# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
# remove extension
PREFIX=`basename "${PACBIO_FASTQ%.fastq.gz}"`
# output file basename, the extension will be add by hifiasm
OUTPUT_FILE="${OUTDIR}/${PREFIX}"


# only if the directory does not exist it will be created 
if [ ! -d $OUTDIR ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p $OUTDIR
fi 

# change of directory to save the results in the output file
cd "$OUTDIR"

# assembly the PacBio reads with hifiasm tool 
apptainer exec --bind "$DATA_DIR" $CONTAINER hifiasm \
    -o "$PREFIX" -t $SLURM_CPUS_PER_TASK "$PACBIO_FASTQ"


awk '/^S/{print ">"$2;print $3}' ${OUTPUT_FILE}.bp.p_ctg.gfa > ${OUTPUT_FILE}.fa