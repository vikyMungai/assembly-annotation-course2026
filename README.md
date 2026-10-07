# assembly-annotation-course2026

Genome assembly and annotation of Arabidopsis thaliana


## Repository structure
After running all the scripts, this will be the structure of the repository 
```text 
.
├── data/
│   └── raw_data/
│       └── fastq_folder/
│           ├── Ice-1/                         # Long-read sequencing data
│           │   └── ERR11437339.fastq.gz
│           │
│           └── RNAseq_Sha/                    # Paired-end RNA-seq reads
│               ├── ERR754081_1.fastq.gz
│               └── ERR754081_2.fastq.gz
│
├── results/
│   ├── assembly/
│   │   ├── flye/                              # Flye assembly
│   │   ├── hifiasm/                           # Hifiasm assembly
│   │   ├── lja/                               # LJA assembly
│   │   ├── trinity/                           # Trinity assembly output
│   │   ├── trinity.Trinity.fasta
│   │   └── trinity.Trinity.fasta.gene_trans_map
│   │
│   ├── assembly_evaluation/
│   │   ├── busco/                                  # BUSCO completeness assessment
│   │   ├── quast/                                  # QUAST assembly statistics
│   │   └── merqury/                                # Merqury k-mer based evaluation
│   │
│   ├── assembly_comparison/
│   │   ├── nucmer/                                 # Nucmer alignment results
│   │   └── mummerplot/                             # Dot plots from Nucmer alignments
│   │
│   ├── fastp/                                      # Read preprocessing results
│   ├── k_mer_counting/                             # K-mer analysis
│   └── reads_QC/                                   # Raw-read quality control
│
└── scripts/
    ├── 01-run_fastqc.sh                            # Quality control with FastQC
    ├── 02-run_fastp.sh                             # Read preprocessing with fastp
    ├── 03-perform_k-mer_counting.sh                # K-mer counting
    ├── 04-flye_assembly.sh                         # Flye genome assembly
    ├── 05-hifiasm_assembly.sh                      # Hifiasm genome assembly
    ├── 06-LJA_assembly.sh                          # LJA genome assembly
    ├── 07-trinity_assembly.sh                      # Trinity transcriptome assembly
    ├── 08-run_busco_assembly_evaluation.sh         # BUSCO assembly evaluation
    ├── 09-run_quast_assembly_quality_assessment.sh # QUAST assembly evaluation
    ├── 10-build_meryl_db.sh                        # Build Meryl k-mer database
    ├── 11-run_merqury.sh                           # Merqury assembly evaluation
    ├── 12-compare_assemblies.sh                    # Nucmer assembly comparisons
    └── 13-mummerplot_compare_assemblies.sh         # Generate comparison dot plots
```

## Project workflow 
1. [Retrieved raw data](#1-retrieved-raw-data)
2. [QC of the reads](#2-qc-of-the-reads)
3. [K-mer counting](#3-k-mer-counting)
4. [Assembly](#4-assembly)
5. [Assembly evaluation](#5-assembly-evaluation)
6. [Assembly comparison](#6-assembly-comparison)

### 1. Retrieved raw data
Symbolic links were created to the data stored in the directory `/data/courses/assembly-annotation-course/raw_data`, which contains the sequencing datasets:

- Whole genome PacBio HiFi reads for each accession (Ice-1)
- Whole transcriptome Illumina RNA-seq for accession Sha (RNAseq_Sha)

The datasets used in this project were published in the following studies: 
- https://www.nature.com/articles/s41588-024-01715-9
- http://dx.doi.org/10.1038/s41467-020-14779-y 

```shell 
cd /data/users/vmungai/assembly-annotation-course2026/data/raw_data/fastq_folder
ln -s /data/courses/assembly-annotation-course/raw_data/Ice-1 .
ln -s /data/courses/assembly-annotation-course/raw_data/RNAseq_Sha . 
```

### 2. QC of the reads 
- `01-run_fastqc.sh`: QC was performed on both the PacBio and Illumina reads.  

- `02-run_fastp.sh`: `fastp` was used to trim and filter the Illumina reads, while for the PacBio reads it was used to obtain the total number of sequenced bases.

### 3. K-mer counting 
- `03-perform_k-mer_counting.sh`: Jellyfish was used to count k-mers and create a histogram.

Afterwards the .histo output file was uploaded on http://genomescope.org/genomescope2.0/ with k-mer size 31 and max kmer coverage 1000 (results at this link http://genomescope.org/genomescope2.0/analysis.php?code=4TRrvWT6O1ZDgOUkd1du) 

### 4. Assembly 
For whole-genome assembly, different tools were used:
- Flye (`04-flye_assembly.sh`)
- Hifiasm (`05-hifiasm_assembly.sh`)
- LJA (`06-LJA_assembly.sh`)

For whole-transcriptome assembly, Trinity was used (`07-trinity_assembly.sh`).

### 5. Assembly evaluation 
The quality of the assemblies was evaluated with different tools: 
- BUSCO (`08-run_busco_assembly_evaluation.sh`): it was used the same OrthoDB database "brassicales_odb10" as it was used in the paper  
- QUAST (`09-run_quast_assembly_quality_assessment.sh`)
- Merqury (`10-build_meryl_db.sh`, `11-run_merqury.sh`)

### 6. Assembly comparison 
- `12-compare_assemblies.sh`: the assemblies were aligned to the reference genome using `nucmer` and were also compared against each other.  
- `13-mummerplot_compare_assemblies.sh`: `mummerplot` was used to generate a dot plot from each .delta file produced by `nucmer`

The following comparisons were performed: 
- reference vs flye 
- reference vs hifiasm 
- reference vs lja 
- flye vs hifiasm
- flye vs lja
- lja vs hifiasm


## How to run the repository 
After retrieving the data (see [Retrieved raw data](#1-retrieved-raw-data)), the Bash scripts in the `scripts` directory must be run in numerical order, as indicated by the `[0-9]{2}-*.sh` naming convention. Jobs that depend on outputs from previous steps should only be submitted after the required previous job has completed successfully.
- `03-perform_k-mer_counting.sh` depends on `02-run_fastp.sh`
- `07-trinity_assembly.sh` depends on `02-run_fastp.sh` 
- `08-run_busco_assembly_evaluation.sh` depends on `04-flye_assembly.sh`, `05-hifiasm_assembly.sh`, `06-LJA_assembly.sh` and `07-trinity_assembly.sh`
- `09-run_quast_assembly_quality_assessment.sh` depends on `04-flye_assembly.sh`, `05-hifiasm_assembly.sh` and `06-LJA_assembly.sh`
- `11-run_merqury.sh` depends on `10-build_meryl_db.sh`, `04-flye_assembly.sh`, `05-hifiasm_assembly.sh` and `06-LJA_assembly.sh`
- `13-mummerplot_compare_assemblies.sh` depends on `12-compare_assemblies.sh`, `04-flye_assembly.sh`, `05-hifiasm_assembly.sh` and `06-LJA_assembly.sh`

The following commands must be executed from the repository root directory: 
```bash
sbatch scripts/01-run_fastqc.sh              
sbatch scripts/02-run_fastp.sh                          
sbatch scripts/03-perform_k-mer_counting.sh   
sbatch scripts/04-flye_assembly.sh                   
sbatch scripts/05-hifiasm_assembly.sh        
sbatch scripts/06-LJA_assembly.sh    
sbatch scripts/07-trinity_assembly.sh   
sbatch scripts/08-run_busco_assembly_evaluation.sh                
sbatch scripts/09-run_quast_assembly_quality_assessment.sh
sbatch scripts/10-build_meryl_db.sh
sbatch scripts/11-run_merqury.sh
sbatch scripts/12-compare_assemblies.sh
sbatch scripts/13-mummerplot_compare_assemblies.sh
```

The scripts have been created to be run on the IBU cluster using SLURM. 