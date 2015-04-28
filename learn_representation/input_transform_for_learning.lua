require 'math'
require 'torch'

function  transform_input_pairs(triplets_array)
--[[ The function takes as input an array of multiples of 3.
    Every triplet is of the form (Zi,Zj, Rij).
    The functions outputs two variables
        - one containing a table of pairs {{Zi,Zj}, {Zi,Zt}, ...}
        - one containing the corresponding distances {Rij, Rit, ...}
    The two array should have the same size

    Example:
        a,b = tranform_input_pairs({1,2,3, 10,20,30, 100,200,300})
        a is {{1,2}, {10,20}, {100,200}}
        b is {3,30,300}
--]]
-- Assumes the array is column oriented
N = triplets_array:size(1)
if N % 3 ~= 0 then
    print("Input size not div by 3")
    error()
end
newN = N / 3;
output_pairs = torch.Tensor(newN, 2)
output_distances = {}
charge_to_index = {}
charge_to_index[1] = 1
charge_to_index[6] = 2
charge_to_index[7] = 3
charge_to_index[8] = 4
charge_to_index[16] = 5
charge_to_index[0] = 6

for i=1,newN do
    index = 3* (i - 1) + 1
    output_pairs[{i,{1,2}}] = torch.Tensor({charge_to_index[triplets_array[index]], 
                       charge_to_index[triplets_array[index+1]]})
    output_distances[i] = triplets_array[index+2]
end

return output_pairs, output_distances
end
