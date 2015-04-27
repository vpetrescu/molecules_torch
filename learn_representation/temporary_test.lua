--require 'itorch'
require 'torch'   -- torch
require 'image'   -- for image transforms
require 'nn'      -- provides all sorts of trainable modules/layers
require 'InputDropout'
require 'AtomLookupTable'

   -- Simple 2-layer neural network, with tanh hidden units
   nbr_input_size = 6
   nbr_atom_types = 6
   descriptor_length = 7
   atom_representation = torch.Tensor(nbr_atom_types, descriptor_length)

   model = nn.Sequential()
   model:add(nn.AtomLookupTable(nbr_atom_types, descriptor_length))

   model:add(nn.SplitTable(1))
     p = nn.ParallelTable()
     for i =1,nbr_input_size do
       --p2 = nn.Linear(7,3)
       p2 = nn.Sequential()
       p2:add(nn.SplitTable(1))
       p2:add(nn.DotProduct())
       p:add(p2)
     end
   model:add(p)
   model:add(nn.JoinTable(1))
   scaling_layer = nn.CMul(nbr_input_size)
   tempN = scaling_layer.weight:size()
   scaling_layer.weight = torch.Tensor(tempN):fill(0.5)
   -- -model:get(1).weight = a -- torch.Tensor(2,1,1,3)
   -- add scaling of output

    model:add(scaling_layer)

   input = torch.Tensor({{1,2},{3,4},{5,2}, {1,1}, {1,2}, {3,4}}) --,  {{5,5},{5,5},{5,2}} })
   output = model:forward(input)
   for i=1,6 do
       print(output[i])
   end
   print(output)
   print(type(output))
