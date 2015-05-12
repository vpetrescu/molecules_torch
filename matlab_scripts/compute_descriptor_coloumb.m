function [out_data, out_labels] = compute_descriptor_coloumb(indices, data)
% transform molecules
M = 23;
n_data_size = size(indices,1);
out_data = zeros(n_data_size,1,1, M*M);
out_labels = zeros(n_data_size, 1);

% Hard coded here
for sample = 1:size(indices,1)
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  cmat = data.X(indext,:,:);
  out_data(sample,1,1,:) = cmat(:)';
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