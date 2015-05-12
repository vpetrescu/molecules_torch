function [out_data, out_labels] = ...
    compute_descriptor_semi_sorted_coloumb(indices, data)

z_values = [1,6,7,8,16];
max_z_count = [16,7,3,3,1];
map = zeros(16,1);
map(1) = 1;
map(6) = 2;
map(7) = 3;
map(8) = 4;
map(16)= 5;

% Hard coded here

out_labels = zeros(size(indices));
data2.X = zeros(size(indices,1), 23,23);
for sample = 1:size(indices,1)
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  data2.X(sample,:,:) = data.X(sample,:,:);
end

[N, bin_offsets] = computeSize(max_z_count);
n_distinct = size(z_values,2);
out_data = zeros(size(data2.X,1), 1,1, N);
% current fill index for the pair (i,j)

% 0, 0+5, 0+5+4, 0+5+4+3,0+5+4+3+2
opp = [0,5,9,12,14];
for s = 1:size(data2.X,1)
    s
  % The size of the descriptor 
  z_values = data.Z(s,:);
  z_values = z_values(z_values ~= 0);
  
  % Array that has the size equal with the number of buckets present.
  % It stores the relative offset inside the bucket.
  current_fill_index = zeros(n_distinct*(n_distinct+1)/2,1);

  % loop over non zero charges
  for z1 = 1:size(z_values,2)
    for z2 = z1+1:size(z_values,2)
        %% bin distance z1, z2
        % index of atom, can be 1..5
        i1 = map(z_values(z1));
        i2 = map(z_values(z2));
        mini = min(i1,i2);
        maxi = max(i1, i2);
        offset = opp(mini) - (mini -1) + maxi;
        %% Find bin number, add current bil fill
        index = bin_offsets(offset) + current_fill_index(offset);
        if index > 500
            fprintf(1,'error')
        end
        out_data(s,1,1,index) = data2.X(s,z1,z2);
        current_fill_index(offset) = current_fill_index(offset) + 1;
    end
  end
  for i=1:size(bin_offsets,1)-2
    t = out_data(s,1,1,bin_offsets(i):bin_offsets(i+1)-1);
    out_data(s,1,1,bin_offsets(i):bin_offsets(i+1)-1) = sort(t);
  end
%  plot(reshape(out_data(s,1,1,:),[1,436]));
%  pause
%  close
end

end

function [N, bin_offsets] = computeSize(max_z_count)
% max_z_count a 1D arrays containing at position i the
% maximum number of atoms of type i that appear in a molecule
% for this dataset
N = 0;
n_atom_types = size(max_z_count,2);
% that many pairs of (H,H), (H,C)
bin_offsets = zeros(n_atom_types*(n_atom_types+1)/2,1);
idx = 0;
for i =1:n_atom_types
    N = N + nchoose2(max_z_count(i));
    idx = idx + 1;
    % find the end of the first bucket
    % it contains pairs of atoms of the same type
    bin_offsets(idx) = N;
    for j=i+1:n_atom_types
        N = N + max_z_count(i) * max_z_count(j);
        idx = idx + 1;
        bin_offsets(idx) = N;
    end
end
bin_offsets = bin_offsets +1;
bin_offsets = [1; bin_offsets];
end

function res = nchoose2(n)
    if n==1
        res = 1;
    else
        res = n*(n-1)/2;
    end
end