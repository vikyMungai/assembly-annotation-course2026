#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=02:00:00
#SBATCH --partition=pshort_el8
#SBATCH --job-name=perform_k-mer_counting
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path for the jellyfish's container 
CONTAINER="/containers/apptainer/jellyfish-2.2.6--0.sif"

# setting path of working directory and where the data is stored to give access to the container 
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory and files 
OUTDIR="${WORKDIR}/results/k_mer_counting"
OUT_JELLYFISH="${OUTDIR}/k_mer_counts.jf"
OUT_HIST_JELLYFISH="${OUTDIR}/reads.histo"
# PacBio's reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"


# only if the directory does not exist it will be created 
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$OUTDIR"
fi 

# run jellyfish through its container 
apptainer exec --bind "$DATA_DIR" $CONTAINER jellyfish count \
    -C -m 21 \
    -s 5G \
    -t $SLURM_CPUS_PER_TASK \
    -o $OUT_JELLYFISH \
    <(zcat $PACBIO_FASTQ) 

# export the k-mer count histogram
apptainer exec --bind "$DATA_DIR" $CONTAINER jellyfish histo -t $SLURM_CPUS_PER_TASK "$OUT_JELLYFISH" > "$OUT_HIST_JELLYFISH"