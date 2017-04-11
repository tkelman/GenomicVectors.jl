module TestGenomeInfo

using GenomicVectors
using Base.Test
using DataFrames

@testset begin
    
### GenomeInfo
chrs = ["chr1","chr2","chrX"]
x = GenomeInfo("hg19",chrs,Int64[3e5,2e5,1e4])
@test genome(x) == "hg19"
@test chr_lengths(x) == Int64[3e5,2e5,1e4]
@test chr_offsets(x) == Int64[0,3e5,5e5]
@test chr_ends(x) == cumsum(Int64[3e5,2e5,1e4])
@test chr_names(x) == chrs

end # testset
    
end # module