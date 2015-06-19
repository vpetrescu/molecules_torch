
function [ac,bc] = remove_0values_from_descriptor(path_to_data, current_method)

for fold_nbr =1:5
    filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
     a =load(filename_test)    
end

% max_values = [reshape(a,[size(a,1), size(a,4)]);reshape(b,[size(b,1), size(b,4)])];
% %max_values = reshape(max_values,[size(max_values,1), size(max_values,4)]);
% allindices = max(max_values);
% nonzeros_values = max_values(:, allindices~=0);
% ntrain = size(a,1);
% ntest = size(b,1);
% ac = nonzeros_values(1:ntrain,:);
% ac = reshape(ac, [size(a,1),1,1, size(ac,2)]);
% bc = nonzeros_values(ntrain+1:end,:);
% bc = reshape(bc, [size(b,1),1,1, size(bc,2)]);
end
