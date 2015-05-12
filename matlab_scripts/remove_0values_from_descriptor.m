
function [ac,bc] = remove_0values_from_descriptor(a, b)

max_values = [reshape(a,[size(a,1), size(a,4)]);reshape(b,[size(b,1), size(b,4)])];
%max_values = reshape(max_values,[size(max_values,1), size(max_values,4)]);
allindices = max(max_values);
nonzeros_values = max_values(:, allindices~=0);
ntrain = size(a,1);
ntest = size(b,1);
ac = nonzeros_values(1:ntrain,:);
ac = reshape(ac, [size(a,1),1,1, size(ac,2)]);
bc = nonzeros_values(ntrain+1:end,:);
bc = reshape(bc, [size(b,1),1,1, size(bc,2)]);
end
