There are two datasets

qm7.mat
    5 types of atoms
    23 max molecule size
    1 property to predict (atomization energy)
    - contains data.X (NxDxD) Coloumb matrices
               data.P cross validation indices
               data.T labels
               data.Z charge Z values

qm7b.mat
    6 types of atoms
    29 max molecule size
    14 properties to predict
    - contains data.X
               data.T
    - extended file qm7bZ.mat contains also data.Z

There is code for creating 6 types of descriptors
- 2DSortedColoumb -> symmetric 2D Coloumb matrix sorted according to row norms
- SortedColoumb -> 1D matrix obtained from ignoring common elements in the symmetric 2D matrix
- BoB -> Bag of Bonds descriptor
- BoBHistogram -> Bag of Bonds Histogram
- BagOfTriplets -> (to be used with 1d convolution) (Zi,Zj, Rij) triplets to be used with conv nets

Experimental
- BoBHistogramNoisy -> noisy BobHistogram were a small noise (0,0.5) was added to the
                        distances before binning 

