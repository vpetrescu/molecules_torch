There are two datasets

qm7.mat
    5 types of atoms
    1 property to predict
    - contains data.X (NxDxD) Coloumb matrices
               data.P cross validation indices
               data.T labels
               data.Z charge Z values

qm7b.mat
    6 types of atoms
    14 properties to predict
    - contains data.X
               data.T
    - extended file qm7bZ.mat contains also data.Z

There is code for creating 6 types of descriptors
- 2DSortedColoumb -> symmetric 2D Coloumb matrix sorted according to raw norms
- SortedColoumb -> 1D matrix obtained from ignoring common elements in the symmetric 2D matrix
- BoB -> Bag of Bonds descriptor
- BoBHistogram -> Bag of Bonds Histogram
Experimental
- BoBHistogramNoisy -> noisy BobHistogram were a small noise (0,0.5) was added to the
                        distances before binning 
- Triplets -> (to be used with 1d convolution) (Zi,Zj, Rij) triplets to be used with conv nets
