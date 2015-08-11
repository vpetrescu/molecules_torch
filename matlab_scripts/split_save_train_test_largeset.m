current_method = 'BoB-20-fine020';

method = {'BoB-20-fine020',... % same as Bob-20 but with 40 buckets'}; % sorted according to BoB
          'BoB-20-fine001'}
%data = load('qm7b.mat');   
%path_to_data = 'data14properties';
data = load('../../large-set/largedataset.mat');   
path_to_data = 'large-set';

%% indices are sorted according to number of atoms but are
%% not taking into account the non H ones
if strcmp(dataset_type, 'qm7')
    keySet   = [1,6,7,8,16]; % atom charges
    valueSet = [1,2,3,4,5];
    n_atom_types = 5; % number of distinct atoms
    nbr_dist_bins = 19;   % maximum distance in the dataset
    molecule_size = 23;   % max molecule size
    max_z_count = [16,7,3,3,1]; % max nbr of atoms of certain type in a molecule
 
elseif strcmp(dataset_type, 'qm7b')
    keySet   = [1,6,7,8,16,17];
    valueSet = [ 1,2,3,4,5, 6];
    n_atom_types = 6;
    nbr_dist_bins = 19; 
    molecule_size = 23;
    max_z_count = [16,7,3,3,1, 2];
        
elseif strcmp(dataset_type, 'largeset')
    keySet   = [1,6,7,8,9];
    valueSet = [1,2,3,4,5];
    n_atom_types = 5;
    molecule_size = 29;
    nbr_dist_bins = 13;   
end

mr = containers.Map(keySet,valueSet);
    
for fold_nbr=1:5
    %% get train indices
    trindices = load(sprintf('../../large-set/test_indices_%d', fold_nbr));
    trindices = trindices.indices(:);
    
    %% get test indices
    teindices = trindices(:);

    
    out_data = []; out_labels = [];
    if strcmp(current_method, 'BoB-20-fine020')
        quantization_level = 5;
        [testData.data, testData.labels] = ...
                    compute_descriptor_BoBHistogram(teindices, data,...    
                                     n_atom_types,...
                                     mr,...
                                     nbr_dist_bins,...
                                     quantization_level,...
                                     molecule_size);
    end
    
 %   filename_train = sprintf('../../data/train_desc_%s_fold_%d.mat', ...
 %                           current_method,fold_nbr);
    filename_test = sprintf('../../%s/descriptor_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
    
    save(filename_test, 'testData');
end


