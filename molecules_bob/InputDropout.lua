local InputDropout, Parent = torch.class('nn.InputDropout', 'nn.Module')

function InputDropout:__init(special_val)
    Parent.__init(self)
    self.value_to_ignore = special_val
    self.noise = torch.Tensor()
    self.train = true
end

function InputDropout:updateOutput(input)
    self.output:resizeAs(input):copy(input)
    if self.train then
        self.noise = torch.ne(input, self.value_to_ignore)
        self.noise = self.noise:double()
--        print(self.noise)
--        print(self.output)
--        print(type(self.noise))
        self.output:cmul(self.noise)
    end
    return self.output
end

function InputDropout:updateGradInput(input, gradOutput)
    if self.train then
        self.gradInput:resizeAs(gradOutput):copy(gradOutput)
        self.gradInput:cmul(self.noise)
    else
        error('backprop only defined while training')
    end
    return self.gradInput
end

