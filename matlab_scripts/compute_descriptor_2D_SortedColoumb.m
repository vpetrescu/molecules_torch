function [out_data, out_labels] = compute_descriptor_2D_SortedColoumb(indices, ...
                                                                        data,...
                                                                        molecule_size)
% transform molecules
M = molecule_size;
n_data_size = max(size(indices));
out_data = zeros(n_data_size, M, M);
out_labels = zeros(size(data.T));

% Hard coded here
for sample = 1:n_data_size
  indext = indices(sample);
  if (size(data.T,1) ~= 1)
    out_labels(sample,:) = data.T(indext,:);
  else
      out_labels(sample) = data.T(indext);
  end
  % compute the norm of every row
  row_norms = sqrt(sum(abs(data.X(indext,:,:)).^2,2));  
  [~, sorted_indices] = sort(row_norms,'descend');
  cmat = data.X(indext,:,:);
  cmat = reshape(cmat, [M,M]);
  sorted_cmat = cmat(sorted_indices, sorted_indices);
  out_data(sample,:,:) = sorted_cmat;
end

end