function [out_data, out_labels] = ...
    compute_descriptor_BoB(indices,... % a subset of the sample indices in the data, Nx1 
    data, ... % contains data.X, data.Z, data.T
    map_zvalues, ... % maps the Z value to an index between 1..nbr_atoms
    init_z_values, ... % the set of Z_values present in the dataset
    max_z_count, ... % the maximum nbr of atoms of certain type in the molecules across dataset
    molecule_size,... % the maximum molecule size
    n_atom_types)   % the number of different atom types

% Hard coded here
n_samples = max(size(indices));

out_labels = zeros(size(data.T));
data2.X = zeros(n_samples, molecule_size, molecule_size);
for sample = 1:n_samples
  indext = indices(sample);
  if size(data.T,1) ~= 1
    out_labels(sample,:) = data.T(indext,:);
  else
     out_labels(sample) = data.T(indext); 
  end
  data2.X(sample,:,:) = data.X(indext,:,:);
end

N = computeSize(max_z_count);
out_data = zeros(n_samples, N);
% current fill index for the pair (i,j)
max_pairs_length = 1000;max(max_z_count);
pairs_structure = zeros(n_samples, n_atom_types, n_atom_types, max_pairs_length);
pairs_indices = ones(n_samples, n_atom_types, n_atom_types);
for s = 1:n_samples
  % The size of the descriptor 
  z_values = zeros([molecule_size,1]);
  for i=1:molecule_size
    data2.X(s,:,:);
    z_values(i) = round((2*data.X(s,i,i))^(1/2.4));
  end
  z_values = z_values(z_values ~= 0);

  % loop over non zero charges
  for z1 = 1:size(z_values,2)
    for z2 = z1+1:size(z_values,2)
        %% bin distance z1, z2
        % index of atom, can be 1..5
        i1 = map_zvalues(z_values(z1));
        i2 = map_zvalues(z_values(z2));
        mini = min(i1,i2);
        maxi = max(i1, i2);
        idx = pairs_indices(s, mini, maxi);
        pairs_structure(s,mini,maxi,idx) = data.X(s,z1,z2);
        pairs_indices(s, mini, maxi) = pairs_indices(s, mini, maxi)+1;
    end
  end
%  plot(reshape(out_data(s,1,1,:),[1,436]));
%  pause
%  close
end

for s = 1:n_samples
  % loop over non zero charges
  temp = zeros(1,N);
  idx = 1;
  for z1 = 1:n_atom_types
    for z2 = z1:n_atom_types
        %% bin distance z1, z2
        % index of atom, can be 1..5
        i1 = map_zvalues(init_z_values(z1));
        i2 = map_zvalues(init_z_values(z2));
        mini = min(i1,i2);
        maxi = max(i1, i2);
        Nsize1 = max_z_count(mini);
        Nsize2 = max_z_count(maxi);
        if mini == maxi
            Nend = nchoose2(Nsize1);
        else
            Nend = Nsize1*Nsize2;
        end
        temp(idx:idx+Nend -1)  =  sort(pairs_structure(s,mini,maxi,1:Nend));
        idx = idx + Nend - 1;
    end
  end
  out_data(s,:) = temp;
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
idx = 0;
for i =1:n_atom_types
    N = N + nchoose2(max_z_count(i));
    idx = idx + 1;
    % find the end of the first bucket
    % it contains pairs of atoms of the same type

    for j=i+1:n_atom_types
        N = N + max_z_count(i) * max_z_count(j);
        idx = idx + 1;
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