function [out_data_triplets, out_labels] = ...
    compute_descriptor_semi_sorted_triplets_map(indices, data)

% max count of atom type in a molecule
max_z_count = [16,7,3,3,1];

% atom charges
keySet   = {1,6,7,8,16};
% atom tyep index
valueSet = [1,2,3,4,5];
% map charges to atom type index
mr = containers.Map(keySet,valueSet);

n_samples = size(indices, 1);

out_labels = zeros(n_samples, 1);
data2.X = zeros(n_samples, 23,23);
for sample = 1:n_samples
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  data2.X(sample,:,:) = data.X(indext,:,:);
end

% compute size of the output descriptor
nbr_triplets = computeSize(max_z_count);
% multiply with 3 to account for (zi,zj,1/Rij) triplets
out_data_triplets = zeros(n_samples, 3*nbr_triplets);

n_atom_types = 5;
max_pairs_length = nchoose2(max(max_z_count));
pairs_structure = zeros(n_samples, n_atom_types, n_atom_types, max_pairs_length);
pairs_indices = ones(n_samples, n_atom_types, n_atom_types);
for s = 1:n_samples
    s
  % keep only the non zero values
  z_values = zeros([23,1]);
  Xs = data.X2(s,:,:);
  Xs = reshape(Xs, [23, 23]);
  for i=1:23
    z_values(i) = round((2*Xs(i,i))^(1/2.4));
  end
  z_values = z_values(z_values ~= 0);
  % loop over non zero charges
  for z1 = 1:size(z_values,2)
    for z2 = z1+1:size(z_values,2)
        %% bin distance z1, z2
        % index of atom, can be 1..5
        i1 = mr(z_values(z1));
        i2 = mr(z_values(z2));
        mini = min(i1,i2);
        maxi = max(i1, i2);
        idx = pairs_indices(s, mini, maxi);
        pairs_structure(s,mini,maxi,idx) = data2.X(s,z1,z2)/(z_values(z1)*z_values(z2));
        pairs_indices(s, mini, maxi) = pairs_indices(s, mini, maxi)+1;
    end
  end
%  plot(reshape(out_data(s,1,1,:),[1,436]));
%  pause
%  close
end

for s = 1:n_samples
    s
  % loop over non zero charges
  temp = zeros(1,3*nbr_triplets);
  idx = 1;
  for z1 = 1:n_atom_types
    for z2 = z1:n_atom_types
        %% bin distance z1, z2
        % index of atom, can be 1..5
        i1 = mr(z_values(z1));
        i2 = mr(z_values(z2));
        mini = min(i1,i2);
        maxi = max(i1, i2);
        Nsize1 = max_z_count(mini);
        Nsize2 = max_z_count(maxi);
        if mini == maxi
            max_nbr_triplets = nchoose2(Nsize1);
        else
            max_nbr_triplets = Nsize1*Nsize2;
        end
        Length = max_nbr_triplets;
        Length = Length*3;
        tempvalues = pairs_structure(s,mini,maxi,1:max_nbr_triplets);
        tempvalues = tempvalues(:);
        nonzeros = sum(tempvalues~=0);
        
        temp(idx:3:idx + Length -1) = [min(z_values(z1),z_values(z2))*ones([1,nonzeros]),...
                                       zeros([1,max_nbr_triplets-nonzeros])];
        temp(idx+1:3:idx +Length-1) = [max(z_values(z1),z_values(z2))*ones([1,nonzeros]),...
                                       zeros([1,max_nbr_triplets-nonzeros])];
        temp(idx+2:3:idx+ Length-1)  =  sort(pairs_structure(s, mini, maxi, ...
                                           1:max_nbr_triplets), 'descend');
        idx = idx + Length;
    end
  end
  out_data_triplets(s,:) = temp;
%  plot(reshape(out_data(s,1,1,:),[1,436]));
%  pause
%  close
end
end

function [N] = computeSize(max_z_count)
% max_z_count a 1D arrays containing at position i the
% maximum number of atoms of type i that appear in a molecule
% for this dataset
N = 0;
n_atom_types = size(max_z_count,2);
% that many pairs of (H,H), (H,C)
for i =1:n_atom_types
    N = N + nchoose2(max_z_count(i));
    % find the end of the first bucket
    % it contains pairs of atoms of the same type

    for j=i+1:n_atom_types
        N = N + max_z_count(i) * max_z_count(j);
    end
end
end

function res = nchoose2(n)
    if n==1
        res = 1;
    else
        res = n*(n-1)/2;
    end
end