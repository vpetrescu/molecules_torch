function [out_data, out_labels] = compute_descriptor_sorted_coloumb(indices, data)
% transform molecules
M = 23;
n_data_size = size(indices,1);
out_data = zeros(n_data_size,1,1, M*M);
out_labels = zeros(n_data_size, 1);

% Hard coded here
for sample = 1:size(indices,1)
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  % compute the norm of every row
  row_norms = sqrt(sum(abs(data.X(indext,:,:)).^2,2));  
  [~, sorted_indices] = sort(row_norms,'descend');
  cmat = data.X(indext,:,:);
  cmat = reshape(cmat, [M,M]);
  sorted_cmat = cmat(sorted_indices, sorted_indices);
  out_data(sample,1,1,:) = sorted_cmat(:)';
end



uniq_out_data = zeros(n_data_size, 1,1, ...
                      M*(M+1)/2);
                  
for s = 1: size(out_data,1)
    onesample = out_data(s,1,1, :);
    onesample = reshape(onesample, [M, M]);
    onesample = onesample';
    
    for ki = 2:M
        for kj = 1:ki-1
            onesample(ki, kj) = -100;
        end    
    end
     onesample = onesample';
     onesample = onesample(:);
     onesample(onesample == -100) = [];
     uniq_out_data(s,1,1,:) = onesample;
end

out_data = uniq_out_data;

end