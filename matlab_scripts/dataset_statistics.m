load('qm7bZ.mat');

z_values = [1,6,7,8,16, 17];
max_z_count = [0,0,0,0,0, 0];
% maximum per element type
for i=1:size(z_values, 2)
   z = sum(data.Z == z_values(i), 2);
   max_z_count(i) = max(z);  
end
% Max values in a molecule 16, 7, 3 ,3 1 

% maximum per bond type
z_count = zeros(size(data.Z,1) , 6);
N = size(data.Z, 1);
for i=1:size(z_values, 2)
   z_count(:,i) = sum(data.Z == z_values(i), 2);
end

%% only 176 elements
uniq_z_count = unique(z_count, 'rows');

% Find number of non Hidrogen atoms
z_count_non_h = z_count(:,2:end);
non_h_per_molecule = sum(z_count_non_h,2);
hist(non_h_per_molecule)
for i=1:8
    sum(non_h_per_molecule==i)
end

%% get the indices with less than 4 non H atoms
train_indices = (non_h_per_molecule < 5);
temp = 1:N;
temp(train_indices);

z_count = sum(data.Z(60:end,:)~=0, 2);
[zvalues, zind] = sort(z_count);
size(zind)
allindices = 59 +zind;

teindices1 = allindices(1:3:size(allindices,1));
teindices2 = allindices(2:3:size(allindices,1));
teindices3 = allindices(3:3:size(allindices,1));
size(teindices1)
size(teindices2)
size(teindices3)

%% Sort the other indices according to the number of atoms
%% Split it into 5 sets
current_method = 'BoB-20-fine025';

method = {'Coloumb', ... % Original Coloumb matrix
          'SortedColoumb', ... % Coloumb matrix sorted by row norm
          'RandomSortedColoumb',... % 10x Sorted Coloumb by noise
          'BoB-20',... % Bob with every distance binned into 20 buckets
          'BoB-20-noise',... % same as above but with small noise added to the distances
          'Bob-20-fine05',... % same as Bob-20 but with 40 buckets
          'Bob-20-fine025',... % same as Bob-20 but with 40 buckets
          'Bob-20-fine001',... % s
          'Bob-20-80values',... % same as Bob-20 but with distance bins with 0 elements removed
          'SemiSortedColoumb',... % BoB type of descritptor
          'Triplets',... % {{Zi,Zj,1/Rij}, {...},..} sorted according to Coloumb
          'SemiSortedTriples'}; % sorted according to BoB
       
path_to_data = 'data14properties';
%data = load('qm7b.mat');   
%path_to_data = 'data14properties';


for fold_nbr=1:1
    %% get train indices
    if fold_nbr == 1
        teindices = teindices1 - 1;
    elseif fold_nbr == 2
        teindices = teindices2;
    else
        teindices = teindices3;
    end
    teindices=teindices(:);
    out_data = []; out_labels = [];
    max(teindices)
    min(teindices)
    trindices = 1:N - 1;
    trindices = setdiff(trindices, teindices);
    trindices = trindices(:);
    if strcmp(current_method, 'BoB-20-fine025')
        [trainData.data, trainData.labels] = ...
                    compute_descriptor_bob20_025(trindices, data);
        [testData.data, testData.labels] = ...
                    compute_descriptor_bob20_025(teindices, data);
    end
     
%     a = -1;
%     b = 1;
%     abdiff = a -b;
%     max_labels = max(testData.labels);
%     max_labels(max_labels==0) = 1;
%     min_labels = min(testData.labels):
%     min_labels(min_labels==0) = 1;
%     testData.labels = testData.labels./repmat(max_labels, [size(testData.labels,1), 1]);
    
    filename_train = sprintf('../../%s/train_desc_%s_fold_%d.mat', ...
                             path_to_data,current_method,fold_nbr);
    filename_test = sprintf('../../%s/test_desc_%s_fold_%d.mat', ...
                            path_to_data,current_method,fold_nbr);
    
    save(filename_train, 'trainData');
    save(filename_test, 'testData');
end





