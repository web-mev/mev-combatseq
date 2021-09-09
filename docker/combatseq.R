suppressMessages(suppressWarnings(library('sva')))


# args from command line:
args<-commandArgs(TRUE)

# A raw (unnormalized), integer count matrix
RAW_COUNTS_FILE <- args[1]

# A table with the first column of sample IDs, followed by columns
# annotating those samples. Required to have a column named "batch" at minimum.
# The remaining columns should be covariates which we will NOT adjust for.
ANN_FILE <- args[2]

# change the working directory to co-locate with the counts file:
working_dir <- dirname(RAW_COUNTS_FILE)
setwd(working_dir)

# Load counts
# When loading the counts, do NOT have them change to fix R's conventions (initially)
# so we can map them back at the end.
count_df = read.table(RAW_COUNTS_FILE, header=T, row.names=1, check.names=F)
orig_colnames = colnames(count_df)
new_colnames = make.names(orig_colnames)
colnames(count_df) = new_colnames
mapping_from_counts = data.frame(
    orig_names = orig_colnames,
    row.names = new_colnames,
    stringsAsFactors=F)

# Load the annotations and change the rownames according to R's convention with make.names
annotations = read.table(ANN_FILE, header=T, row.names=1)
original_samplenames = rownames(annotations)
altered_samplenames <- make.names(original_samplenames)
rownames(annotations) <- altered_samplenames
mapping_from_ann = data.frame(
    orig_names = original_samplenames,
    row.names = altered_samplenames,
    stringsAsFactors=F)

# Enforce that the annotations and the count matrix have the same sample names. ANY discrepancies
# are rejected, even if the annotation file has extra samples
if (!(setequal(new_colnames, altered_samplenames))){
    s1 = setdiff(new_colnames, altered_samplenames)
    s2 = setdiff(altered_samplenames, new_colnames)
    if(length(s1) > 0){
        s = 'There were more samples in your count matrix than your annotations:'
        remapped_s1 = paste(mapping_from_counts[s1, 'orig_names'], collapse=',')
        s = paste(s, remapped_s1)
        message(s)
    } else if(length(s2) > 0){
        s = 'There were more samples in your annotations than your count matrix:'
        remapped_s2 = paste(mapping_from_ann[s2, 'orig_names'], collapse=',')
        s = paste(s, remapped_s2)
        message(s)
    }
    quit(status=1)
}

# reorder cols and cast as a matrix
v = rownames(annotations)
count_df <- count_df[v]
mtx=data.matrix(count_df)

# We need to know which covariate corresponds with the batch, so we explicitly require a column named batch
tryCatch({
    batch_arr = annotations[,'batch']
  },
  error=function(x){
        message('To use ComBat-seq, your annotation table needs to have a column named as "batch".')
        quit(status=1)  
 }
)
# Extract out any other covariates
covars = subset(annotations, select=-c(batch))

# We wrap this in a try/catch since there are a bunch of things that could go wrong.
# Namely, we want to catch situations where there is confounding. ComBat-seq catches this
# and reports, but this try/catch may also get other violations.
tryCatch({
    adjusted_counts <- ComBat_seq(mtx, batch=batch_arr, covar_mod=covars)
}, error = function(x){
        message(x$message)
        quit(status=1)
    }
)
# and map the sample names back to the originals
remapped_names = mapping_from_counts[colnames(adjusted_counts), 'orig_names']
colnames(adjusted_counts) = remapped_names

# Write the output table
output_filename <- paste(working_dir, "combatseq_adjusted_counts.tsv", sep='/')
write.table(adjusted_counts, 'combatseq_adjusted_counts.tsv', sep='\t', quote=F)

# ...and write the required json file so MeV knows where to find the outputs
json_str = paste0(
       '{"adjusted_counts":"', output_filename, '"}'
)
output_json <- paste(working_dir, 'outputs.json', sep='/')
write(json_str, output_json)