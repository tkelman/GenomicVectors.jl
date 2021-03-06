# Things I need from IntervalTree
* [ ] AbstractIntervalTree

# Features
* [ ] `show` for GenomicRanges should covert genoPos to chrPos
* [x] as.string for GenomicPositions
* [ ] as.string for GenomicRanges
* [x] get both chr and pos for GenomicPositions
* [ ] get both chr and pos for GenomicRanges
* [ ] overlap(::GenomicRanges,::GenomicPositions)
* [ ] overlap(::GenomicRanges,::GenomicRanges)
* [x] convert method: GenomicPositions to DataFrame
* [ ] convert method: GenomicRanges to DataFrame
* [x] convert method: GenomicPositions to String via DataFrame
* [ ] convert method: GenomicRanges to String via DataFrame
* [x] == for GenomicInfo
* [ ] getter for GenomeInfo chr_names hash?
* [ ] getindex for GenomicPositions should return a GenomicPositions
* [x] constructor for just genopos and chrinfo, needed for subsetting
* [x] finish indexing
* [ ] make convert to DataFrame more like chrpos and chr
* [x] use DataStructures.OrderedDict or NamedArray for GenomeInfo

# Decisions
* [x] GenomicInfo must store lengths or ends, offsets loses last length
* [x] For converting genome position to chromosome position, some kind
  of search for pos + offset positions in vector of offsets. Linear
  might be fine (or faster) since we just have ~25 values to search in.
* [ ] Maybe store GenomeInfo as an RLEVector of chr names? We'd get
some useful stuff like rwidth and length for free.
* [x] Maybe store GenomeInfo as a runend vector and a name -> index
  hash while NamedArrays sorts out their method ambiguity warnings?
* [x] Should scalar indexing give a scalar? I guess so, but genpos
  value?  Dimension dropping is weird.
* [x] Rename package to GenomicVectors?
* [ ] Make things like chromosomes, chrpos, width generator functions?
* [ ] does it make sense to take or return scalars in operations on GenomicVectors, e.g. pop! and push!  ?
* [ ] Should starts and ends for GenomicRanges be a n x 2 matrix or two vectors? Matrix is nice for
  sortrows. Also if I want to have a view, I can have just one.
* [ ] Should chromosome names be symbols rather than strings?

# Improvements
* [x] Swap GenomicPositions inner- and outer-constructors
* [ ] Genomic* constructors should do something about matching type of
keys on GenomeInfo and type of chrs
* [ ] show on GP should use convert(String,gp)
* [x] store [0 ; chr_ends] in GenomeInfo chr_ends, chr_offsets,
chr_lengths then just x[2:end], x[1:end-1], diff(x)
 * [ ] Make sure my hash and == are what AutoHashEquals would say 

# Bugs
* [x] chromosomes function contains type instability
