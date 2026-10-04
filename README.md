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
In GenomeScope I have changed the "max kmer coverage" to 4000 and k-size 21

a second analysis with k-mer size is 31 and "max kmer coverage" to 1000 http://genomescope.org/genomescope2.0/analysis.php?code=4TRrvWT6O1ZDgOUkd1du 
look at the histagrams created by GenomeSpace 



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


# Questions: reads & QC
1. What are the read lengths of the different datasets?
For Illumina the read length of the forward and reverse strand is 101
For PacBio Hifi reads is 118-37335. The expected length is around 10kb and 20 kb 

2. Are the dataset of good quality?
The PacBio Hifi has a good quality as expected. While, the Illumina has a good quality at the beginning of the reads, but the quality get worse at the end of the reads. 

# Questions: Perform k-mer counting

Upload your histo file to the website, checkout the plots and answer the following questions:

1. Is the estimated genome size expected?
From the paper (https://www.nature.com/articles/s41588-024-01715-9) the assembly sizes of the 69 accessions ranged from 128 to 148 Mb, with an average length of 135 Mb. As my genome size is 126 is is quite a smaller genome. 

2. Is the percentage of heterozygousity expected?
The percentage of heterozygote is around 0, which is what we expect as they specie usually inbred. also the paper states "Sixty-nine accessions were confirmed to be inbred lines, but Lu-1, Pa-1 and Istisu-1 showed signs of heterozygosity and thus were removed from the subsequent analysis"

3. Is the coverage expected?
we aim for 30x coverage for assembly, higher it is better. 
In my case I had 34,6x, which is okay. 

4. Please add your results to following this table: DONE 

5. Bonus: Why are we using canonical k-mers?
In PacBio we sequenced double stranded DNA, so we have k-mers that belong to both strands and we cannot tell to which strand. However, we would like to consider every location of the genome once, no matter on which strand we happened to have landed.
When we read the sequence ATCGAC that is an observation for that sequence and its reverse complement GTCGAT to exist in the genome. One appears when reading the genome in one direction and the other on its opposite, we could have sequenced any of them. So for the sake of completeness we should perform all analyses by considering this sequence ATCGAC/GTCGAT.
To take into account the sequence only once, the canonical sequence of a k-mer pair is used. Only the lexicographically smaller of the two reverse complementary sequences is taken into account. In other words, the one that comes earliest in alphabetical order.


# Step assembly 

### Hifiasm 
With hifiasm we have 836 contigs

sum the lengths of the contigs and check that they sum up to the estimated genome size 

Hifiasm generates: 
- bp.p_ctg.gfa = primary contig assembly → usually the one you use when you want one representative genome assembly.
- bp.hap1.p_ctg.gfa = haplotype 1 assembly.
- bp.hap2.p_ctg.gfa = haplotype 2 assembly.
- *.noseq.gfa: contain graph structure without the actual sequence strings
- *.lowQ.bed: describe regions flagged as low quality
- *.p_utg.gfa and *.r_utg.gfa: are unitig-level graph outputs rather than the final primary-contig assembly


# Questions: assembly 

1. What is the difference between a contig and a scaffold?
Contigs are derived from the term "contiguous" and represent continuous stretches of DNA sequences. These sequences consist of only four nucleotide bases: adenine (A), cytosine (C), guanine (G), and thymine (T), with no intervening gaps. Contigs are part of the scaffold, gaps separate the contigs in the scaffold.
Scaffolds introduces a higher level of genome structure by linking contigs together. This linkage utilizes additional data about the relative position and orientation of contigs within the genome. The gaps between the contigs is indicated as epresented by a series of "N" letters, representing missing genomic information. 

2. Why can repetitive sequences make genome assembly difficult? And why is long-read sequencing paricularly useful?
Genome assembly is difficult when we have repetitive sequences because it is hard to understand where are they located, as the same sequence has different location. Long-read is partiuclar useful because it is easier to assemble the reads as the overlapping region would be larger. 

3. What happens when sequencing coverage is very low? What about extremely high coverage?
When the coverage is very low, we could have: 
- missing reads that would create gaps in the genome 
- the depth of coverage would be not enough to identify sequencing error

In case of high coverage, there would be a large amount of data that requires a large amount of resources to do the assembly. 

4. What is the role of error correction in an assembly workflow? Is it always necessary with PacBio HiFi reads?
The role of error correction in an assembly workflow is to detect sequencung errors and differentiate them between different bases due to heterozygosity. 
The error correction could be done before starting the k-mer composition, to simplify the assembly step. Otherwise can be done after the assembly to remove bubbles in the graph. In both cases short reads are used to check for sequencing reads. they are alinged to the reads to check for sequenicng error. 

In case of PacBio Hifi the error connection it is usually not needed because they are high quality reads. Nevertheless, some assemblies do the error connection in case PacBio HiFi is not specified. 

5. Why is it important to keep track of the exact command, software version and parameters used?
it is importnat in order to make the analysis reproducible. This is also why it is suggested to used git repositories and containers. 

6. If two students obtain different assemblies from the same reads, what technical reasons could explain this?
They started with the same raw files, but different factors could lead to different assemblies. 
- If the reads are not PacBio HiFi, maybe one trimmed the reads and the other not. 
- They used different assemblies 
- they used same assemblies but different version or parameters 
- If the assembly has some stocastic variables or ranomisation (for example for the start node), the random seed could be different. 

7. What is the fundamental difference between genome assembly and transcriptome assembly?
Genome assembly sequence DNA and tries to assemble reads. The contigs' amount is similar, except for heterozygote samples. The genome assembly it is double stranded, we can have more than one haplotype in case of heterozygosity. 
The Transcriptome assembly works with RNA reads. The contig's amount is not even, because the RNA transcript is not even as gene are expressed at different levels. The RNA is not double stranded. 

8. Why can transcriptome assembly be more complicated than simply assembling all RNA reads into one sequence?
The RNA trascriptome undergoes alternative splicing, so the trascriptomes could be different from each other. The k-mers from different trascripomes belonging to the same gene could have some parts that are in common but missing or additional regions due to alternative splacing. So, it is more complex than simply assembly all RNA reads. Also, sequencing errors cannot be identified by the frequency of that base in respect to other bases. 

# Questions: assembly evaluation 
- How do your genome assemblies look according to your BUSCO results? Is one genome assembly better than the other?
- How does your transcriptome assembly look? Are there many duplicated genes? Can you explain the differences with the whole genome assemblies?

### comments 
for hifiasm you should look at the "*.bp.p_utg.gfa" is the graph. this can be visualised with bondage and we can check that the contigs are correct. 

useful for interactive shell 
```shell 
srun --cpus-per-task=1 --mem-per-cpu=1G --time=02:00:00 --partition=pibu_el8 --pty bash
```
