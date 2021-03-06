module TestGenomicPositions

using GenomicVectors
using Base.Test
using RLEVectors
using DataFrames

@testset begin
    
### GenomicPositions
## Creating
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
gpos = genopos(pos,chrs,chrinfo)
x = GenomicPositions(pos,chrs,chrinfo)
y = GenomicPositions(gpos,chrinfo)
@test x == y # chr + pos constructor same as genopos contructor
chrs = ["chr1","chr2","chrX"]
seqinfo = GenomeInfo("hg19",chrs,Int64[3e5,2e5,1e4])
pos = [ 1, 2, 3]
chromosomes=["chr2","chr2","chrX"]
x = GenomicPositions( pos, chromosomes, seqinfo )
@test x.genopos == [300001,300002,500003]
@test genostarts(x) == [300001,300002,500003]
@test genoends(x) == [300001,300002,500003]
@test x[2] == 300002
@test typeof(similar(x)) == typeof(x)
y = copy(x)
@test y == x
slide!(y, 5)
@test !(y == x)
@test typeof(show(x)) == Void # At least test that show does not give error
    
# Regression test, second half of duped positions had wrong chrpos
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
pos = vcat(pos, pos)
chrs = vcat(chrs, chrs)
y = GenomicPositions( pos, chrs, seqinfo )
@test starts(y) == pos

## Describing
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
x = GenomicPositions(pos,chrs,chrinfo)
@test starts(x) == pos
@test ends(x) == pos
@test widths(x) == RLEVector(1, length(pos))
@test chr_info(x) == chrinfo
@test genome(x) == "hg19"
@test chr_names(x) == ["chr1", "chr2", "chrX"]
@test isa(strands(x), RLEVector)

## Indexing
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
gpos = genopos(pos,chrs,chrinfo)
gp = GenomicPositions( gpos, chrinfo )

@test gp[ 2 ] == gpos[2]
@test gp[ 2:3 ] == GenomicPositions( gpos[2:3], chrinfo )
@test gp[ [3,4] ] == GenomicPositions( gpos[ [3,4] ], chrinfo )

gp[2] = 471000
@test gp == GenomicPositions( [300000, 471000, 490000, 510000], chrinfo )
gp[2:3] = [472000 489000]
@test gp == GenomicPositions( [300000, 472000, 489000, 510000], chrinfo )

## Conversions
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
gpos = genopos(pos,chrs,chrinfo)
gp = GenomicPositions( gpos, chrinfo )
@test convert(Vector,gp) == gpos
@test convert(DataFrame,gp) == DataFrame(Chromosome=chrs, Position=pos)
@test convert(Vector{String},gp) == [ "$(c):$(p)-$(p)" for (c,p) in zip(chrs,pos) ]

## Altering
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
x = GenomicPositions(pos,chrs,chrinfo)
@test starts(slide!(x, -50)) == pos - 50
x = GenomicPositions(pos,chrs,chrinfo)
@test starts(slide(x, -50)) == pos - 50
@test_throws ArgumentError slide!(x, -4000000000)
x = GenomicPositions(pos,chrs,chrinfo)
order = sortperm(genostarts(x))
y = GenomicPositions( pos[order], chrs[order], chrinfo )
@test sort(x) == y
sort!(x)
@test x == y
x = GenomicPositions([ 5, 8, 2, 1 ], ["chr2", "chr1", "chr1", "chrX"], chrinfo)
@test sortperm(x) == [3, 2, 1, 4]
@test sortperm(sort!(x, rev=true)) == [4, 3, 2, 1]
@test genostarts(vcat(x, x)) == vcat(genostarts(x), genostarts(x))
@test starts(vcat(x,x)) == [1,5,8,2,1,5,8,2]

## Searching
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
pos = Int64[3e5,1.8e5,1.9e5,1e4]
x = GenomicPositions(pos,chrs,chrinfo)
pos = Int64[2e5,1.8e5,1.8e5,1e4]
y = GenomicPositions(pos,chrs,chrinfo)
@test overlaps(x, y) == [false, true, false, true]
@test in(x, y) == [false, true, false, true]
z = GenomicPositions(Int64[1.8e5, 4, 1e4, 12], ["chr2", "chr2", "chrX", "chr2"], chrinfo)
@test in(z, x) == [true, false, true, false]
@test overlaps(z, x) == [true, false, true, false]

chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr2","chr2","chr2","chrX"]
x = GenomicPositions([10,20,30,5],chrs,chrinfo)
y = GenomicPositions([30,5,21,1000],chrs,chrinfo)
@test nearest(x, y) == [2,3,1,4]
x = GenomicPositions([30,5,21,1000],["chr1","chr2","chr2","chrX"],chrinfo)
@test nearest(x, y) == [0,2,3,4]

## Array operations
# size, length, endof, empty!, issubset, vcat, union, intersect, setdiff, symdiff, append!, prepend!, setdiff!, symdiff!, intersect!
chrinfo = GenomeInfo("hg19",["chr1","chr2","chrX"],Int64[3e5,2e5,1e4])
chrs = ["chr1","chr2","chr2","chrX"]
xpos = Int64[3e5,1.8e5,1.9e5,1e4]
ypos = Int64[2e5,1.8e5,1.8e5,1e4]
x = GenomicPositions(xpos,chrs,chrinfo)
y = GenomicPositions(ypos,chrs,chrinfo)

@test length(x) == 4
@test size(x) == (4, )
z = copy(y)
empty!(z)
@test length(z) == 0
@test length(y) == 4
z = GenomicPositions(ypos[1:2],chrs[1:2],chrinfo)
@test issubset(z,x) == false
@test issubset(z,y) == true
@test starts(vcat(y, y)) == vcat(pos, pos)
@test starts(union(x, y)) == union( Int64[3e5,1.8e5,1.9e5,1e4], Int64[2e5,1.8e5,1.8e5,1e4] )
@test starts(intersect(x, y)) == intersect( Int64[3e5,1.8e5,1.9e5,1e4], Int64[2e5,1.8e5,1.8e5,1e4] )
@test starts(setdiff(x, y)) == setdiff( Int64[3e5,1.8e5,1.9e5,1e4], Int64[2e5,1.8e5,1.8e5,1e4] )
@test starts(symdiff(x, y)) == symdiff( Int64[3e5,1.8e5,1.9e5,1e4], Int64[2e5,1.8e5,1.8e5,1e4] )
x = GenomicPositions(xpos,chrs,chrinfo)
y = GenomicPositions(ypos,chrs,chrinfo)
append!(x,y)
@test starts(x) == Int64[3e5,1.8e5,1.9e5,1e4,2e5,1.8e5,1.8e5,1e4]
x = GenomicPositions(xpos,chrs,chrinfo)
y = GenomicPositions(ypos,chrs,chrinfo)
prepend!(x,y)
@test starts(x) == Int64[2e5,1.8e5,1.8e5,1e4,3e5,1.8e5,1.9e5,1e4]

end # testset

end # module
