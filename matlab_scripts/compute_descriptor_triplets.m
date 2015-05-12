function [out_data, out_labels] = compute_descriptor_triplets(indices, data)
% transform molecules
M = 23;
n_data_size = size(indices,1);
out_data = zeros(n_data_size, M*(M-1)/2 * 3);
out_labels = zeros(n_data_size, 1);

% Hard coded here
for sample = 1:size(indices,1)
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  % compute the norm of every row
  row_norms = sqrt(sum(abs(data.X(indext,:,:)).^2,2));
  [~, sorted_indices] = sort(row_norms,'descend');
  onedata = [];
  for i =1:M-1
      idx1 = sorted_indices(i);
      for j=i+1:M
          idx2 = sorted_indices(j);
          
          rij = -1;
          z1 = data.Z(indext,idx1);
          z2 = data.Z(indext,idx2);
          if (z1 == 0 || z2 == 0)
              rij = 0;
              %% make both elements 0
              z1 = 0;
              z2 = 0;
          end
          if rij == -1
              rij = z1*z2/data.X(indext, idx1, idx2);
              rij = 1/rij;
          end
          onedata = [onedata, z1, z2, rij];
      end
  end
  size(out_data)
  size(onedata)
  out_data(sample,:) = onedata;
  
end


end