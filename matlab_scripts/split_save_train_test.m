

method = {'Coloumb', ... % Original Coloumb matrix
          'SortedColoumb', ... % Coloumb matrix sorted by row norm
           '2DSortedColoumb', ... % Coloumb matrix sorted by row norm
          'RandomSortedColoumb',... % 10x Sorted Coloumb by noise
          'BoBH-dist20-fine020',... % same as Bob-20 but with 20 buckets
           'BoBH-dist20-fine020-noisy-10',... % same as Bob-20 but with distance bins with 0 elements removed
          'BagOfBonds',... % BoB type of descritptor
          'SemiSortedTriples'}; % sorted according to BoB
      
%data = load('qm7b.mat');   
%path_to_data = 'data14properties';
data = load('qm7.mat');   
path_to_data = 'data';


%current_method = 'BoBH';%
%current_method = '2DSortedColoumb'

dataset_type = 'qm7'; %{'qm7', 'qm7b', 'largeset'};
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
    nbr_dist_bins = 19;%??? which one   
end

current_method = 'SemiSortedTriplets';
mr = containers.Map(keySet,valueSet);

for fold_nbr=1:5
    
    %% get fold indices
    teindices = data.P(fold_nbr,:);
    teindices = teindices(:) + 1;
    
    out_data = []; out_labels = [];

    
    if strcmp(current_method, 'Coloumb')
        [foldData.data, foldData.labels] = ...
                    compute_descriptor_coloumb(teindices, data);
    elseif strcmp(current_method, 'SortedColoumb')
        [foldData.data, foldData.labels] = ...
                    compute_descriptor_SortedColoumb(teindices, data, molecule_size);
    elseif strcmp(current_method, '2DSortedColoumb')
        [foldData.data, foldData.labels] = ...
                    compute_descriptor_2D_SortedColoumb(teindices, data, ...
                                            molecule_size);
    elseif strcmp(current_method, 'BoB')
        [foldData.data, foldData.labels] = ...
            compute_descriptor_BoB(teindices, data,...
            mr, ... % maps the Z value to an index between 1..nbr_atoms
            keySet, ... % the set of Z_values present in the dataset
            max_z_count, ... % the maximum nbr of atoms of certain type in the molecules across dataset
            molecule_size,... % the maximum molecule size
            n_atom_types);
    elseif strcmp(current_method, 'Triplets')
        % for three atoms Z1,Z2,Z3, the result would be
        % the indices of the atoms are sorted according to the 
        % input
        % {Z1, Z2, 1/D12, Z1, Z3, 1/D13, Z2, Z3, 1/D23, 0,0,0}
        [foldData.data, foldData.labels] = ...
                    compute_descriptor_triplets(teindices, data);
    elseif strcmp(current_method, 'SemiSortedTriplets')
        [foldData.data, foldData.labels] = ...
                    compute_descriptor_semi_sorted_triplets_map(teindices,...
                                                 data,...
                                                 mr, max_z_count,...
                                                 z_values,...
                                                 molecule_size, ...
                                                 n_atom_types);
     elseif strcmp(current_method, 'BoBH')
         quantization_level = 5;
        [foldData.data, foldData.labels] = ...
                    compute_descriptor_BoBHistogram(teindices, data,...
                                                 n_distinct, mr,...
                                                 nbr_dist_bins,...
                                                 quantization_level,...
                                                 molecule_size);
                                     
      elseif strcmp(current_method, 'BoB-20-fine020-noisy')
        [foldData.data, foldData.labels] = compute_descriptor_bob20_020_noisy(teindices, data,...
                                                 n_distinct, mr,...
                                                 nbr_dist_bins, molecule_size);
    end
    
    filename_test = sprintf('../../%s/descriptor_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
    
    save(filename_test, 'foldData');
end


