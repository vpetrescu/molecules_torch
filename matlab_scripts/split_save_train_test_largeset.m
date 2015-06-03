
special_name = 'special';
current_method = 'BoB-20-fine025';

method = {'BoB-20-fine025',... % same as Bob-20 but with 40 buckets'}; % sorted according to BoB
          'BoB-20-fine001'}
%data = load('qm7b.mat');   
%path_to_data = 'data14properties';
data = load('largedataset.mat');   
path_to_data = 'large-set';


for fold_nbr=1:5
    %% get train indices
    trindices = [data.P(1:(fold_nbr-1),:); data.P((fold_nbr+1):end,:)];
    trindices = trindices(:);
    
    %% get test indices
    teindices = data.P(fold_nbr,:);
    teindices = teindices(:);
    
    out_data = []; out_labels = [];
    if strcmp(current_method, 'BoB-20-fine025')
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_025(teindices, data);
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


