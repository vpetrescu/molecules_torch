local ConstantMul, parent = torch.class('nn.ConstantMul', 'nn.Module')

function ConstantMul:__init(...)
   parent.__init(self)
   
   local arg = {...}

   self.size = torch.LongStorage()
   local n = #arg
   if n == 1 and torch.type(arg[1]) == 'torch.LongStorage' then
      self.size:resize(#arg[1]):copy(arg[1])
   else
      self.size:resize(n)
      for i=1,n do
         self.size[i] = arg[i]
      end
   end
  
   self.scalable_weight = torch.Tensor(self.size)
   
   self.output:resize(self.size) 

   self:reset()
end
 
function ConstantMul:reset()
   self.scalable_weight:fill(0)
end

function ConstantMul:updateOutput(input)
   -- lazy-initialize
   self._output = self._output or input.new()
   self._scalable_weight = self._scalable_weight or input.new()
   self._expand = self._expand or input.new()
   self._repeat = self._repeat or input.new()

   self.output:resizeAs(input):copy(input)
   if input:nElement() == self.scalable_weight:nElement() then
      self._output:view(self.output, -1)
      self._scalable_weight:view(self.scalable_weight, -1)
      self._output:cmul(self._scalable_weight)
    else
         error('not of same size')
    end
   return self.output
end

function ConstantMul:updateGradInput(input, gradOutput)
   if not self.gradInput then
      return
   end
   
   self._gradOutput = self._gradOutput or input.new()
   self._gradInput = self._gradInput or input.new()

   self.gradInput:resizeAs(input):zero()
   if self.scalable_weight:nElement() == gradOutput:nElement() then
      self.gradInput:addcmul(1, self.scalable_weight, gradOutput)
   else
      error('not of same size')
   end
   
   return self.gradInput
end

function ConstantMul:type(type)
   if type then
      self._input = nil
      self._output = nil
      self._scalable_weight = nil
      self._expand = nil
      self._repeat = nil
      self._sum = nil
   end
   return parent.type(self, type)
end
