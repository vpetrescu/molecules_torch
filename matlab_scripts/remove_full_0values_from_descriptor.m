
function remove_full_0values_from_descriptor(path_to_data,current_method)   
    all_folds = [];
    for fold_nbr =1:5
        filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
         a =load(filename_test, 'testData');   
         all_folds = [all_folds; a.testData.data];
    end
    size(all_folds)
    max_values = max(all_folds);
    nonzeros_values = max_values~=0;
% ntrain = size(a,1);
% ntest = size(b,1);
% ac = nonzeros_values(1:ntrain,:);
% ac = reshape(ac, [size(a,1),1,1, size(ac,2)]);
% bc = nonzeros_values(ntrain+1:end,:);
% bc = reshape(bc, [size(b,1),1,1, size(bc,2)]);
    for fold_nbr =1:5
        filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
         load(filename_test, 'testData');   
         testData.data = testData.data(:, nonzeros_values);
         size(testData.data)
         save(filename_test, 'testData')
    end
    for fold_nbr =1:5
        filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
         load(filename_test, 'testData');   
         testData.data = testData.data(:, nonzeros_values);
         size(testData.data)
         save(filename_test, 'testData')
    end
end
