--require 'itorch'
require 'torch'   -- torch
require 'image'   -- for image transforms
require 'nn'      -- provides all sorts of trainable modules/layers
require 'InputDropout'
require 'AtomLookupTable'

  input_dim = 10
  x = torch.Tensor(1,10):fill(1.5)
  n_bumps = 3
  dim  = 2
  n_replications = 3
  model = nn.Sequential()
  model:add(nn.Replicate(n_replications))
  model:add(nn.SplitTable(1))
  p = nn.ParallelTable()
  for i = 1, n_replications do
    p2 = nn.Sequential()
    p2:add(nn.WeightedEuclidean(input_dim, n_bumps))
    -- add -1 here
    p2:add(nn.CMul(n_bumps))
    p2:add(nn.Exp())
    ndim=2
    p2:add(nn.Sum(ndim))
    p:add(p2)
  end
  model:add(p)
  model:add(nn.JoinTable(1))
  model:add(nn.Sum(1))
  print(model:forward(x))
--  print(type(model.output))
--[[ p = nn.ParallelTable()
  for i=1,n_replications do
     p2 = nn.CMul(input_dim)
     p:add(p2)
  end
  model:add(p)
  print(model:listModules())
  model:forward(x)
  print(model.output)
  out = model.output
  for k,v in pairs(out) do
      print(k)
      print(v)
  end
  -- Simple 2-layer neural network, with tanh hidden units
   --[[nbr_input_size = 3
   nbr_atom_types = 5
   descriptor_length = 7
  -- atom_representation = torch.Tensor(nbr_atom_types, descriptor_length)

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
   model:add(nn.Tanh())
   model:add(nn.Linear(nbr_input_size, 1))
   input = torch.Tensor({{1,2},{3,4},{5,2}}) --,  {{5,5},{5,5},{5,2}} })
   inputtable = {}
   inputtable[1] = input
   inputtable[2] = input
   criterion = nn.MSECriterion()
   criterion.sizeAverage = false
   print(input)
   print(type(input))

   model:training()
   parameters, gradParameters = model:getParameters()
   gradParameters:zero()
   ltarget = torch.Tensor({100})
   type(input)
   loutput = model:forward(input)
   lerr = criterion:forward(loutput, ltarget)
   ldf_fo = criterion:backward(loutput, ltarget)

   model:backward(input, ldf_fo)
--]]

