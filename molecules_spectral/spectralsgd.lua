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

function optim.spectralsgd(opfunc, nparameters, config, state)
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
            nparameters[i]:add(-clr, dfdx[i])
        else
            --print(dfdx[i]:size(2))
            --print(dfdx[i])
             U,S,V = torch.svd(dfdx[i])
             gsum = torch.Tensor(U:size(1),V:size(1)):zero()
             if U~=U then
                 print 'is nan U'
             end
             if V~=V then
                 print 'is nan U'
             end
             for j=1,S:size(1) do
                local temp = torch.Tensor(U:size(1), V:size(1)):zero()
                torch.addr(temp, U[{{},j}],V[{{},j}])
                gsum = gsum + temp 
            end
            collectgarbage()
            --print(collectgarbage("count")*1024)

           -- clr = clr * S:sum()
           gsum = gsum *S[1]
          -- print(i)
           nparameters[i]:add(-clr, gsum)
           -- nparameters[i]:add(-clr, dfdx[i])
        end
    end
    return nparameters,{fx}
end
