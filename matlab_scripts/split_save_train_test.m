
special_name = 'special';
current_method = 'BoB-20-fine0125';

method = {'Coloumb', ... % Original Coloumb matrix
          'SortedColoumb', ... % Coloumb matrix sorted by row norm
          'RandomSortedColoumb',... % 10x Sorted Coloumb by noise
          'BoB-20',... % Bob with every distance binned into 20 buckets
          'BoB-20-noise',... % same as above but with small noise added to the distances
          'Bob-20-fine05',... % same as Bob-20 but with 40 buckets
          'Bob-20-fine025',... % same as Bob-20 but with 40 buckets
          'Bob-20-fine001',... % s
          'Bob-20-fine0125',... % s
          'Bob-20-fine020',... % same as Bob-20 but with distance bins with 0 elements removed
          'SemiSortedColoumb',... % BoB type of descritptor
          'Triplets',... % {{Zi,Zj,1/Rij}, {...},..} sorted according to Coloumb
          'SemiSortedTriples'}; % sorted according to BoB
      
%data = load('qm7b.mat');   
%path_to_data = 'data14properties';
data = load('qm7.mat');   
path_to_data = 'data';


for fold_nbr=1:5
    %% get train indices
    trindices = [data.P(1:(fold_nbr-1),:); data.P((fold_nbr+1):end,:)];
    trindices = trindices(:);
    
    %% get test indices
    teindices = data.P(fold_nbr,:);
    teindices = teindices(:);
    
    out_data = []; out_labels = [];
    if strcmp(current_method, 'BoB-20')
        [trainData.data, trainData.labels] = compute_descriptor_bob20_map(trindices, data);
        [testData.data, testData.labels] = compute_descriptor_bob20_map(teindices, data);
    elseif strcmp(current_method, 'BoB-20-noise')
        [trainData.data, trainData.labels] = compute_descriptor_bob20_noise(trindices, data);
        [testData.data, testData.labels] = compute_descriptor_bob20_noise(teindices, data);
    elseif strcmp(current_method, 'Coloumb')
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_coloumb(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_coloumb(teindices, data);
    elseif strcmp(current_method, 'SortedColoumb')
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_sorted_coloumb(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_sorted_coloumb(teindices, data);
    elseif strcmp(current_method, 'SemiSortedColoumb')
   %     [trainData.data, trainData.labels] = ...
   %                 compute_descriptor_semi_sorted_coloumb_map(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_semi_sorted_coloumb_map(teindices, data);
    elseif strcmp(current_method, 'Triplets')
        % for three atoms Z1,Z2,Z3, the result would be
        % the indices of the atoms are sorted according to the 
        % input
        % {Z1, Z2, 1/D12, Z1, Z3, 1/D13, Z2, Z3, 1/D23, 0,0,0}
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_triplets(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_triplets(teindices, data);
    elseif strcmp(current_method, 'SemiSortedTriplets')
      %  [trainData.data, trainData.labels] = ...
      %              compute_descriptor_semi_sorted_triplets(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_semi_sorted_triplets_map(teindices, data);
    elseif strcmp(current_method, 'BoB-20-fine05')
     %   [trainData.data, trainData.labels] = ...
     %               compute_descriptor_bob20_05(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_05(teindices, data);
   elseif strcmp(current_method, 'BoB-20-fine0125')
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_0125(teindices, data);
     elseif strcmp(current_method, 'BoB-20-fine025')
     %   [trainData.data, trainData.labels] = ...
     %               compute_descriptor_bob20_05(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_025(teindices, data);
     elseif strcmp(current_method, 'BoB-20-fine001')
     %   [trainData.data, trainData.labels] = ...
     %               compute_descriptor_bob20_05(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_001(teindices, data);
     elseif strcmp(current_method, 'BoB-20-fine020')
     %   [trainData.data, trainData.labels] = ...
     %               compute_descriptor_bob20_05(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_020(teindices, data);
                                     
     elseif strcmp(current_method, 'Bob-20-80values')
        [trainData.data, trainData.labels] = compute_descriptor_bob20(trindices, data);
        [testData.data, testData.labels] = compute_descriptor_bob20(teindices, data);
        [trainData.data, testData.data] = remove_0values_from_descriptor(trainData.data, testData.data); 
   
            
    end
    
 %   filename_train = sprintf('../../data/train_desc_%s_fold_%d.mat', ...
 %                           current_method,fold_nbr);
    filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
    
   % save(filename_train, 'trainData');
    save(filename_test, 'testData');
end


