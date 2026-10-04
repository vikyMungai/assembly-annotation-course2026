#!/usr/bin/env bash

#SBATCH --cpus-per-task=10
#SBATCH --mem=4G
#SBATCH --time=12:00:00
#SBATCH --partition=pibu_el8 
#SBATCH --job-name=run_fastp
#SBATCH --mail-user=vittoria.mungai@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/vmungai/logs/assembly_annotation_course2026/output/output_%j.o
#SBATCH --error=/data/users/vmungai/logs/assembly_annotation_course2026/error/error_%j.e

# path for the fastp container
CONTAINER="/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif"

# set the paths to the working directory and data directory
WORKDIR="/data/users/vmungai/assembly-annotation-course2026"
DATA_DIR="/data"
# output directory 
OUTDIR="${WORKDIR}/results/fastp"
# PacBio and Illumina reads 
PACBIO_FASTQ="${WORKDIR}/data/raw_data/fastq_folder/Ice-1/ERR11437339.fastq.gz"
RNAseq_FASTQ1="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAseq_FASTQ2="${WORKDIR}/data/raw_data/fastq_folder/RNAseq_Sha/ERR754081_2.fastq.gz"
# extract sample names by removing the .fastq.gz extension
SAMPLE_NAME1=`basename "${RNAseq_FASTQ1%.fastq.gz}"`
SAMPLE_NAME2=`basename "${RNAseq_FASTQ2%.fastq.gz}"`
SAMPLE_NAME_PACBIO=`basename "${PACBIO_FASTQ%.fastq.gz}"`


# create the output directory if it does not already exist
if [ ! -d "$OUTDIR" ]; then 
    echo "directory ${OUTDIR} created"
    # option -p create the parents' folders if they do not exist
    mkdir -p "$OUTDIR"
fi 

# trim the paired-end Illumina reads with fastp
apptainer exec --bind "$DATA_DIR" \
                $CONTAINER fastp \
                --detect_adapter_for_pe \
                --in1 "$RNAseq_FASTQ1" --in2 "$RNAseq_FASTQ2" \
                --out1 "${OUTDIR}/${SAMPLE_NAME1}.trimmed.fastq.gz" --out2 "${OUTDIR}/${SAMPLE_NAME2}.trimmed.fastq.gz"  \
                --json "$OUTDIR/fastp.json" \
                --html "$OUTDIR/fastp.html" \
                --thread $SLURM_CPUS_PER_TASK

# run on the PacBio reads to obtain read and base statistics without trimming
apptainer exec --bind "$DATA_DIR" \
                $CONTAINER fastp \
                -i $PACBIO_FASTQ \
                -o /dev/null \
                -h "${OUTDIR}/$SAMPLE_NAME_PACBIO.fastp.html" \
                -j "${OUTDIR}/$SAMPLE_NAME_PACBIO.fastp.json" \
                --disable_adapter_trimming \
                -q 0 \
                -u 0
