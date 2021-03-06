module TestGenomicRanges

using GenomicVectors
using Base.Test
using Bio.Intervals
using DataFrames

@testset begin

# Creating
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
s = [100, 200, 300, 400]
e = [120, 240, 350, 455]
gr = GenomicRanges(chrs,s,e,chrinfo)
@test isa(gr,GenomicRanges)
@test typeof(show(gr)) == Void # At least test that show does not give error
    
@test_throws ArgumentError GenomicRanges(chrs,s,e[1:2],chrinfo)
@test_throws ArgumentError GenomicRanges(chrs,s,e,['.','.'],chrinfo)

# Indexing
@test gr[2] == (300000 + 200, 300000 + 240, STRAND_NA)
@test gr[2:3] == GenomicRanges(chrs[2:3],s[2:3],e[2:3],chrinfo)

# Creating with strand
gr = GenomicRanges(chrs,s,e,['.','.','.','.'],chrinfo)
@test isa(gr,GenomicRanges)
gr = GenomicRanges(chrs,s,e,[STRAND_NA,STRAND_NA,STRAND_NA,STRAND_NA,],chrinfo)
@test isa(gr,GenomicRanges)

# Describing
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
s = [100, 200, 300, 400]
e =  [120, 240, 350, 455]
gr = GenomicRanges(chrs,s,e,chrinfo)
@test starts(gr) == s
@test ends(gr) == e
@test widths(gr) == [21,41,51,56]
@test strands(gr) == [STRAND_NA,STRAND_NA,STRAND_NA,STRAND_NA]

# Sorting
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
s = [400, 300, 200, 150]
e = s + 20
gr = GenomicRanges(chrs,s,e,chrinfo)

@test issorted(gr) == false
gr2 = sort(gr)
@test gr2 == GenomicRanges( ["chr1","chr2","chr2","chrX"], [400,200,300,150], [420,220,320,170], chrinfo )
@test issorted(gr2) == true
sort!(gr)
@test gr == gr2

@test sort!(gr,rev=true) == GenomicRanges( ["chrX","chr2","chr2","chr1"], [150,300,200,400], [170,320,220,420], chrinfo )

gr = GenomicRanges(chrs,s,e,chrinfo)
@test sortperm(gr) == [1,3,2,4]

# Conversions
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
s = [400, 300, 200, 150]
e = s + 20
gr = GenomicRanges(chrs,s,e,chrinfo)

@test convert(DataFrame,gr) == DataFrame(Chromosome=chrs,Start=s,End=e,Strand=[STRAND_NA,STRAND_NA,STRAND_NA,STRAND_NA])
@test convert(Vector{String},gr) == ["chr1:400-420","chr2:300-320","chr2:200-220","chrX:150-170"]
ic = IntervalCollection([
                        Interval("hg19",400,420,'?',1),
                        Interval("hg19",300200,300220,'?',3),
                        Interval("hg19",300300,300320,'?',2),
                        Interval("hg19",500150,500170,'?',4)
                        ])
@test convert(IntervalCollection,gr) == ic
@test [ metadata(el) for el in ic ] == [1,3,2,4] # Another test that meta right

# Altering
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
s = [100, 200, 300, 400]
e =  [120, 240, 350, 455]
gr = GenomicRanges(chrs,s,e,chrinfo)
gr2 = GenomicRanges(chrs,s+5,e+5,chrinfo)
@test slide(gr,5) == gr2
slide!(gr,5)
@test gr == gr2

# Searching
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
gr1 = GenomicRanges( [30123,40456,40000],[30130,40500,40100],chrinfo )
gr2 = GenomicRanges( [100,30123,40000],[200,30130,40200],chrinfo )
@test findin(gr1,gr2) == [1]
@test intersect(gr1,gr2) == gr1[ [1] ]
@test setdiff(gr1,gr2) == gr1[ [2,3] ]
@test in(gr1,gr2) == BitArray([ true, false, false ])
@test overlapin(gr1,gr2) == [1,3]
@test overlap(gr1,gr2) == gr1[ [1,3] ]
@test hasoverlap(gr1,gr2) == BitArray([ true, false, true ])

# Array ops from delegate
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
s = [400, 300, 200, 150]
e = s + 20
d = [STRAND_NA,STRAND_NA,STRAND_NA,STRAND_NA]
gr = GenomicRanges(chrs,s,e,d,chrinfo)
gr2 = GenomicRanges(chrs[1:2],s[1:2],e[1:2],d[1:2],chrinfo)
gr3 = GenomicRanges(chrs[3:4],s[3:4],e[3:4],d[1:2],chrinfo)
@test size(gr) == (4,)
@test length(gr) == 4
@test endof(gr) == 4
@test issubset(gr2,gr) == true
@test issubset(gr2,gr3) == false
@test vcat(gr,gr) == GenomicRanges(vcat(chrs,chrs),vcat(s,s),vcat(e,e),vcat(d,d),chrinfo)
@test union(gr2,gr3) == gr
@test intersect(gr,gr2) == gr2
@test setdiff(gr,gr2) == gr3
gr = GenomicRanges(chrs,s,e,chrinfo)
append!(gr2,gr3)
@test gr2 == gr
gr2 = GenomicRanges(chrs[1:2],s[1:2],e[1:2],chrinfo)
prepend!(gr2,gr3)
@test gr2 == gr[ [3,4,1,2] ]

end # testset

end # module
