# assembly-annotation-course2026

Genome assembly and annotation of Arabidopsis thaliana


# Project workflow 

## 1. Retreive raw data
It was created a softlink with the data stored in the directory `/data/courses/assembly-annotation-course/raw_data`, which contains the sequencing datasets:

- Whole genome PacBio HiFi reads for each accession (Ice-1)
- Whole transcriptome Illumina RNA-seq for accession Sha (RNAseq_Sha)

```shell 
cd /data/users/vmungai/assembly-annotation-course2026/data/raw_data/fastq_folder
ln -s /data/courses/assembly-annotation-course/raw_data/Ice-1 .
ln -s /data/courses/assembly-annotation-course/raw_data/RNAseq_Sha . 
```

## 2. QC of the reads 
For both the PacBio and Illumina reads the QC was done. 
This is done by the script `01-run_fastqc.sh`

## 3. perform k-mer counting 

the reads.histo has two columns 
- 1°: multiplicity 
- 2°: "how_many_k_mers have this multiplicity"

the results of GenomeSPace are in http://genomescope.org/genomescope2.0/analysis.php?code=q0QLKrgFLfWVwCl4jxgU
In GenomeScope I have changed the "max kmer coverage" to 4000
look at the histagrams greated by GenomeSpace 

- the left plot does not show a second peak (this indicate that there is no heterozyosity). The low heterozygosity is due to the fact that it self ferlaise itself. 
- the right histogram is for high multiplciity k-mers. The high peaks after the black peak are due to cloroplast 

we are missing the ultra long reads to 


#### Calculation from the histogram of Jelly fish and the GenomeSpace's graphs 
we needed to fill the table: "https://docs.google.com/spreadsheets/d/1bW604fD_akvAf6YwgywqkcfWYYrleMvczDe0BdACSo0/edit?gid=0#gid=0" 
**coverage**
IMPORTANT: the coverage can be calculated by looking at the left plot and calculate `kcov*2`. 
in my case 17.3*2 = 34,6 
**genome size**
For the genome size we have to look at the value "len" above in the graph 
`len:126,836,772bp`
**Heterozygosity**
we look in the graph the value "ab"
ab:0.0334%
**unique sequence%**
uniq:82.3%


# Interactive shell on IBU cluster 

To check a tool inside a container 
```shell
srun -p pibu_el8 apptainer exec /containers/apptainer/fastqc-0.12.1.sif fastqc --help
```

Schedule a job from a script 
```shell 
sbatch 01-run_fastqc.sh
```

# Check tools options in container 
```shell 
apptainer exec --bind /data /containers/apptainer/fastqc-0.12.1.sif fastqc --help

apptainer exec --bind /data "/containers/apptainer/jellyfish-2.2.6--0.sif" jellyfish count --help
```




## fastqc comments 
pacbio is 10/20 kb length and the quality should be quite high. 
we should also look at the row data and don't trust the tool only. 
## k-mer counting 
31 should be the right k-mer size 
we aim for 30x coverage for assembly, higher it is better. 

The main peak is is at kcov*2, and you obtain the depth of coverage. 

The genome size should be okay 135-145Mb is the size, the normal 


#### plot genome scale 
the plot on the right is on the lograitmich scale, the one on left is on a normal scale. 
teh peaks could be mitocondrial or cloroplast. 

- the peak on the most right are propbably cloroplast so we remove them. 
the other peak cannot be remove because we would have remove the k-mers in between the peaks. In the genome there are also high copy numbers regions, but this we want to include them 

#### heterozygosity 
The heterozygosity should be around 0 because usually this specie imbrate itself. in the paper they also remove some samples where heterozygosity was too high. 

Very high heterozygosity is good to obtain 2 assembly and obtain so 2 haplotypes (this is possible only with very long and high quality reads). Very low heterozygosity help to create one single assembly. in the middle is not good. 



- see a k-mer plot. you have to interpret like in here 

(not sure about my answer?) bonus question: how sequencing was random, we have both reverse and forward strand. So, we need to use canonical k-mers so that the corresepctive forward and reverse reads are counted once and not twice. 
For example 
```
ATG
TAC
```
The all reads TAC will be counted as ATG and not counted twice. 