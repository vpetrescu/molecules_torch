function [out_data, out_labels] = compute_descriptor_bob20_05(indices, data)
%% transform molecules

n_distinct = 5;
coarseness = 2;
nbr_dist_bins = coarseness*20;

N = n_distinct* n_distinct * nbr_dist_bins;
n_data_size = size(indices,1);

out_data = zeros(n_data_size,1,1, N);
out_labels = zeros(n_data_size, 1);

mapping = zeros(16,1);
offset = n_distinct * nbr_dist_bins;
mapping(1) = 1;
mapping(6) = offset + 1;
mapping(7) = 2*offset + 1;
mapping(8) = 3*offset + 1;
mapping(16) = 4*offset + 1;

mr = zeros(16,1);
mr(1) = 1;
mr(6) = 2;
mr(7) = 3;
mr(8) = 4;
mr(16) = 5;
%% Hard coded here
M = 23;
atoms_count = zeros(size(indices,1), n_distinct);
for sample = 1:size(indices,1)
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  Zs = data.Z(indext,:);
  Zs = reshape(Zs, [23,1]);
  Rs = data.R(indext,:,:);
  Rs = reshape(Rs, [23,3]);
  for i=1:M
    if (Zs(i) ~= 0)
        atoms_count(sample, mr(Zs(i))) = atoms_count(sample, mr(Zs(i))) + 1;
    end
    for j=i+1:M   
        if (Zs(i) ~= 0 && Zs(j)~= 0)
          %% increase count of Zs(i), Zs(j) pair  
          fdistanceR = sqrt(sum((Rs(i,:) - Rs(j,:)).^2));
          distanceR = floor(fdistanceR);
          distanceR = min(distanceR, 20);
          half_bucket = 0;
          if (fdistanceR - distanceR > 0.5)
              half_bucket = 1;
          end
          % find where the row of this atom type starts 
          idx_zi = mapping(Zs(i));
          % find the index of this atom
          mr_zi =  mr(Zs(j)) - 1;
          
          idx_zj = mapping(Zs(j));
          mr_zj = mr(Zs(i)) - 1;
          temp_id = idx_zi + nbr_dist_bins*mr_zj + coarseness*distanceR + half_bucket;
          out_data(sample,1,1,temp_id) = ...
              out_data(sample,1,1,temp_id) + 1;
          temp_id = idx_zj + nbr_dist_bins*mr_zi + coarseness*distanceR + half_bucket;
          out_data(sample,1,1,temp_id) = ...
              out_data(sample,1,1,temp_id) + 1;
        end
    end
 end
end

uniq_out_data = zeros(n_data_size, 1,1, ...
                      n_distinct*(n_distinct+1)/2* nbr_dist_bins + n_distinct);
NN = n_distinct* nbr_dist_bins;
for s = 1: size(out_data,1)
    onesample = out_data(s,1,1, :);
    onesample = reshape(onesample, [NN, n_distinct]);
    onesample = onesample';
    
    for ki = 2:n_distinct
        for kj = 1:(ki-1)*nbr_dist_bins
            onesample(ki, kj) = -100;
        end    
    end
     onesample = onesample';
     onesample = onesample(:);
     onesample(onesample == -100) = [];
     uniq_out_data(s,1,1,:) = [onesample; atoms_count(s,:)'];
end

out_data = uniq_out_data;

end