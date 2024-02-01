# mev-combatseq

This repository contains a WebMeV-compatible tool for performing batch adjustment for RNA-seq data using ComBat-Seq (https://academic.oup.com/nargab/article/2/3/lqaa078/5909519) 

The output from this tool is a batch-adjusted integer-based RNA-seq count matrix. Note that this does *not* create a normalized count matrix. Instead, it creates a new, unnormalized/raw count matrix based on the distribution of the original counts *after* removal of batch effects.

See below for more information on input arguments.

---

### To run external of WebMeV:

Either:
- build the Docker image using the contents of the `docker/` folder (e.g. `docker build -t myuser/combatseq:v1 .`) 
- pull the docker image from the GitHub container repository (see https://github.com/web-mev/mev-combatseq/pkgs/container/mev-combatseq)

To run, we assume you are located in a directory where you have both of the required files (a raw count matrix and an annotation file). Then run:
```
docker run -it -v $PWD:/work <IMAGE> Rscript /usr/local/bin/combatseq.R \
    /work/<raw counts filename>
    /work/<annotation filename>
```
(here, we mount the current directory to `/work` inside the container so your files are located in the `/work` directory)

The call to the script assumes the following:
- The first argument provides the path to an input file of expression counts which has tab-delimited format and contains only integer entries.
- The second argument is an annotation file (tab-delimited) which has the sample names in the first column (required for WebMeV's "annotation" file type) and **must contain a column named "batch"** which lets the tool identify which samples correspond to which batch. Additional columns should include covariates you *need* to keep (treatment groups, phenotype, etc). **If you do not include those covariate columns, you risk that ComBat-seq will remove expression signal related to your experimental perturbation of interest.** Of course, if your experiment was designed such that your batches and experimental groups are confounded, ComBat-seq will not work.


