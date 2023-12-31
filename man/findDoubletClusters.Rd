% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/findDoubletClusters.R
\name{findDoubletClusters}
\alias{findDoubletClusters}
\alias{findDoubletClusters,ANY-method}
\alias{findDoubletClusters,SummarizedExperiment-method}
\alias{findDoubletClusters,SingleCellExperiment-method}
\title{Detect doublet clusters}
\usage{
findDoubletClusters(x, ...)

\S4method{findDoubletClusters}{ANY}(
  x,
  clusters,
  subset.row = NULL,
  threshold = 0.05,
  get.all.pairs = FALSE,
  ...
)

\S4method{findDoubletClusters}{SummarizedExperiment}(x, ..., assay.type = "counts")

\S4method{findDoubletClusters}{SingleCellExperiment}(x, clusters = colLabels(x, onAbsence = "error"), ...)
}
\arguments{
\item{x}{A numeric matrix-like object of count values,
where each column corresponds to a cell and each row corresponds to an endogenous gene.

Alternatively, a \linkS4class{SummarizedExperiment} or \linkS4class{SingleCellExperiment} object containing such a matrix.}

\item{...}{For the generic, additional arguments to pass to specific methods.

For the ANY method, additional arguments to pass to \code{\link{findMarkers}}.

For the SummarizedExperiment method, additional arguments to pass to the ANY method.

For the SingleCellExperiment method, additional arguments to pass to the SummarizedExperiment method.}

\item{clusters}{A vector of length equal to \code{ncol(x)}, containing cluster identities for all cells.
If \code{x} is a SingleCellExperiment, this is taken from \code{\link{colLabels}(x)} by default.}

\item{subset.row}{See \code{?"\link{scran-gene-selection}"}.}

\item{threshold}{A numeric scalar specifying the FDR threshold with which to identify significant genes.}

\item{get.all.pairs}{Logical scalar indicating whether statistics for all possible source pairings should be returned.}

\item{assay.type}{A string specifying which assay values to use, e.g., \code{"counts"} or \code{"logcounts"}.}
}
\value{
A \linkS4class{DataFrame} containing one row per query cluster with the following fields:
\describe{
\item{\code{source1}:}{String specifying the identity of the first source cluster.}
\item{\code{source2}:}{String specifying the identity of the second source cluster.}
\item{\code{num.de}:}{Integer, number of genes that are significantly non-intermediate
in the query cluster compared to the two putative source clusters.}
\item{\code{median.de}:}{Integer, median number of genes that are significantly non-intermediate
in the query cluster across all possible source cluster pairings.}
\item{\code{best}:}{String specifying the identify of the top gene with the lowest p-value
against the doublet hypothesis for this combination of query and source clusters.}
\item{\code{p.value}:}{Numeric, containing the adjusted p-value for the \code{best} gene.}
\item{\code{lib.size1}:}{Numeric, ratio of the median library sizes for the first source cluster to the query cluster.}
\item{\code{lib.size2}:}{Numeric, ratio of the median library sizes for the second source cluster to the query cluster.}
\item{\code{prop}:}{Numeric, proportion of cells in the query cluster.}
\item{\code{all.pairs}:}{A \linkS4class{SimpleList} object containing the above statistics
for every pair of potential source clusters, if \code{get.all.pairs=TRUE}.}
}
Each row is named according to its query cluster.
}
\description{
Identify potential clusters of doublet cells based on whether they have intermediate expression profiles,
i.e., their profiles lie between two other \dQuote{source} clusters.
}
\details{
This function detects clusters of doublet cells in a manner similar to the method used by Bach et al. (2017).
For each \dQuote{query} cluster, we examine all possible pairs of \dQuote{source} clusters,
hypothesizing that the query consists of doublets formed from the two sources.
If so, gene expression in the query cluster should be strictly intermediate
between the two sources after library size normalization.

We apply pairwise t-tests to the normalized log-expression profiles to reject this null hypothesis.
This is done by identifying genes that are consistently up- or down-regulated in the query compared to \emph{both} sources.
We count the number of genes that reject the null hypothesis at the specified FDR \code{threshold}.
For each query cluster, the most likely pair of source clusters is that which minimizes the number of significant genes.

Potential doublet clusters are identified using the following characteristics, in order of importance:
\itemize{
\item Low number of significant genes (i.e., \code{num.de}).
Ideally, \code{median.de} is also high to indicate that the absence of strong DE is not due to a lack of power.
\item A reasonable proportion of cells in the cluster, i.e., \code{prop}.
This requires some expectation of the doublet rate in the experimental protocol.
\item Library sizes of the source clusters that are below that of the query cluster, i.e., \code{lib.size*} values below unity.
This assumes that the doublet cluster will contain more RNA and have more counts than either of the two source clusters.
}

For each query cluster, the function will only report the pair of source clusters with the lowest \code{num.de}.
Setting \code{get.all.pairs=TRUE} will retrieve statistics for all pairs of potential source clusters.
This can be helpful for diagnostics to identify relationships between specific clusters.

The reported \code{p.value} is of little use in a statistical sense, and is only provided for inspection.
Technically, it could be treated as the Simes combined p-value against the doublet hypothesis for the query cluster.
However, this does not account for the multiple testing across all pairs of clusters for each chosen cluster,
especially as we are chosing the pair that is most concordant with the doublet null hypothesis.

We use library size normalization (via \code{\link{librarySizeFactors}}) even if existing size factors are present.
This is because intermediate expression of the doublet cluster is not guaranteed for arbitrary size factors.
For example, expression in the doublet cluster will be higher than that in the source clusters if normalization was performed with spike-in size factors.
}
\examples{
# Mocking up an example.
library(SingleCellExperiment)
sce <- mockDoubletSCE(c(200,300,200))

# Compute doublet-ness of each cluster:
dbl <- findDoubletClusters(counts(sce), sce$cluster)
dbl

# Narrow this down to clusters with very low 'N':
library(scuttle)
isOutlier(dbl$num.de, log=TRUE, type="lower")

# Get help from "lib.size" below 1.
dbl$lib.size1 < 1 & dbl$lib.size2 < 1

}
\references{
Bach K, Pensa S, Grzelak M, Hadfield J, Adams DJ, Marioni JC and Khaled WT (2017).
Differentiation dynamics of mammary epithelial cells revealed by single-cell RNA sequencing.
\emph{Nat Commun.} 8, 1:2128.
}
\seealso{
\code{\link{findMarkers}}, to detect DE genes between clusters.
}
\author{
Aaron Lun
}
