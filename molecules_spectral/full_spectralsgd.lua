--[[
-- A plain implementation of
ARGS:
-- 'opfunc': a function that takes a single input X, the point of evaluation
            and returns f(x) and df/dX
-- 'x' : the initial point
-- 'config' : a table with configuration parameters for the optimizer
-- 'config.learningRate' : learning rate
-- 'state'       : a table describing the state of the optimizer; after
                    each call the state is modified
-- 'state.learningRates' : vector of individual learning rates

RETURN:
-- 'x' : the new x vector
-- 'f(x) the function, evaluated before the update
--]]
require 'optim'

function optim.full_spectralsgd(opfunc, nparameters, config, state)
    local config = config or {}
    local state = state or config
    local lr = config.learningRate or 1e-3
    state.evalCounter = state.evalCounter or 0
    local fx,dfdx = opfunc(nparameters)
    local lrd = config.learningRateDecay or 0
    local nevals = state.evalCounter
    local clr = lr / (1 + nevals*lrd)

    -- normal code would be  x:add(-clr, dfdx)
    state.evalCounter = state.evalCounter + 1
    for i=1,#nparameters do
        if (dfdx[i]:dim() == 1) then
           -- nparameters[i]:add(-clr, dfdx[i])
        else
             local newdfdx = torch.Tensor(dfdx[i]:size(1), dfdx[i]:size(2)+1):zero()
             local DD = nparameters[i]:size(2)
             local indices = torch.range(1,dfdx[i]:size(2))
             newdfdx:indexCopy(2, indices:type('torch.LongTensor'), dfdx[i])
           --  local oneindex = torch.Tensor({dfdx[i]:size(2) + 1})
           --  newdfdx:indexCopy(2, oneindex:type('torch.LongTensor'), dfdx[i+1])
             for x=1,nparameters[i]:size(1) do
                newdfdx[{{x},{DD+1}}] = dfdx[i+1][x]
             end

             U,S,V = torch.svd(newdfdx)
             local gsum = torch.Tensor(U:size(1),V:size(1)):zero()
             for j=1,S:size(1) do
                temp = torch.Tensor(U:size(1), V:size(1)):zero()
                temp:addr(U[{{},j}],V[{{},j}])
                gsum = gsum + temp
            end
           gsum = gsum *S[1]
           local reshaped_bias = torch.Tensor(dfdx[i]:size(1))
           local t1 = torch.Tensor(nparameters[i]:size(1), DD)
           --t1 = gsum[{{},{indices:type('torch.LongTensor')}}]
           for x = 1,nparameters[i]:size(1) do
                for y = 1,nparameters[i]:size(2) do
                    t1[{{x},{y}}] = gsum[{{x},{y}}]
                end
                reshaped_bias[x] = gsum[{{x}, {DD + 1}}]
           end
           nparameters[i]:add(-clr, t1)
           nparameters[i+1]:add(-clr, reshaped_bias)
           collectgarbage()
        end
    end
    return nparameters,{fx}
end
