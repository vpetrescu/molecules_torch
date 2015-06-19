current_method = 'BoB-20-fine020';

method = {'BoB-20-fine020',... % same as Bob-20 but with 40 buckets'}; % sorted according to BoB
          'BoB-20-fine001'}
%data = load('qm7b.mat');   
%path_to_data = 'data14properties';
data = load('../../large-set/largedataset.mat');   
path_to_data = 'large-set';

%% indices are sorted according to number of atoms but are
%% not taking into account the non H ones

%% TIDI HERE IMPORTATN
for fold_nbr=1:5
    %% get train indices
    trindices = load(sprintf('../../large-set/test_indices_%d', fold_nbr));
    trindices = trindices.indices(:);
    
    %% get test indices
    teindices = trindices(:);
    n_distinct = 5;
    nbr_dist_bins = 13;
    molecule_size = 29;
    keySet   = {1,6,7,8,9};
    valueSet = [ 1,2,3,4,5];
    mr = containers.Map(keySet,valueSet);
    
    out_data = []; out_labels = [];
    if strcmp(current_method, 'BoB-20-fine020')
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_020(teindices, ...
                                                data,...
                                                n_distinct,...
                                                mr,...
                                                nbr_dist_bins,...
                                                molecule_size);
     elseif strcmp(current_method, 'BoB-20-fine001')
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_001(teindices, data);
    end
    
 %   filename_train = sprintf('../../data/train_desc_%s_fold_%d.mat', ...
 %                           current_method,fold_nbr);
    filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
    
   % save(filename_train, 'trainData');
    save(filename_test, 'testData');
end


