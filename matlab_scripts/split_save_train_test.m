
special_name = 'special';
current_method = 'Bob-20-80values';

method = {'Coloumb', ...
          'SortedColoumb', ...
          'RandomSortedColoumb',...
          'BoB-20',...
          'BoB-20-noise',...
          'Bob-20-fine05',...
          'Bob-20-80values',...
          'SemiSortedColoumb',...
          'Triplets',...
          'SemiSortedTriples'};
      
data = load('qm7.mat');      
for fold_nbr=1:5
    %% get train indices
    trindices = [data.P(1:(fold_nbr-1),:); data.P((fold_nbr+1):end,:)];
    trindices = trindices(:);
    
    %% get test indices
    teindices = data.P(fold_nbr,:);
    teindices = teindices(:);
    
    out_data = []; out_labels = [];
    if strcmp(current_method, 'BoB-20')
        [trainData.data, trainData.labels] = compute_descriptor_bob20(trindices, data);
        [testData.data, testData.labels] = compute_descriptor_bob20(teindices, data);
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
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_semi_sorted_coloumb(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_semi_sorted_coloumb(teindices, data);
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
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_semi_sorted_triplets(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_semi_sorted_triplets(teindices, data);
    elseif strcmp(current_method, 'Bob-20-fine05')
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_bob20_05(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_05(teindices, data);
                
     elseif strcmp(current_method, 'Bob-20-80values')
        [trainData.data, trainData.labels] = compute_descriptor_bob20(trindices, data);
        [testData.data, testData.labels] = compute_descriptor_bob20(teindices, data);
        [trainData.data, testData.data] = remove_0values_from_descriptor(trainData.data, testData.data); 
   
            
    end
    
    filename_train = sprintf('train_desc_%s_fold_%d.mat', ...
                            current_method,fold_nbr);
    filename_test = sprintf('test_desc_%s_fold_%d.mat', ...
                            current_method,fold_nbr);
    
    save(filename_train, 'trainData');
    save(filename_test, 'testData');
end


