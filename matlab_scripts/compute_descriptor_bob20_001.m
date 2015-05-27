function [out_data, out_labels] = compute_descriptor_bob20_001(indices, data)
%% transform molecules
% number of distinct atoms H,O,C,S,N
n_distinct = 5;
% the binning of the distances
nbr_dist_bins = 20;
quantization_level = 10;
n_samples = size(indices,1);
pairs_structure = zeros(n_samples, n_distinct, n_distinct, ...
                     nbr_dist_bins * quantization_level);
atoms_count = zeros(n_samples, n_distinct);

n_samples = size(indices,1);

out_labels = zeros(n_samples, 1);


keySet   = {1,6,7,8,16};
valueSet = [ 1,2,3,4,5];
mr = containers.Map(keySet,valueSet);

%% Hard coded here
M = 23;
for sample = 1:n_samples
  indext = indices(sample) + 1;
  out_labels(sample) = data.T(indext);
  Zs = data.Z(indext,:);
  Zs = reshape(Zs, [23,1]);
  Rs = data.R(indext,:,:);
  Rs = reshape(Rs, [23,3]);
  for i=1:M
    % increase count of this molecule
    if (Zs(i) ~= 0)
        atoms_count(sample, mr(Zs(i))) = atoms_count(sample, mr(Zs(i))) + 1;
    end
    for j=i+1:M   
        if (Zs(i) ~= 0 && Zs(j)~= 0)
          %% increase count of Zs(i), Zs(j) pair  
          fdistanceR = sqrt(sum((Rs(i,:) - Rs(j,:)).^2));
          distanceR = floor(fdistanceR);
          distanceR = min(distanceR, nbr_dist_bins);
          half_bucket = abs(fdistanceR - distanceR);
          half_bucket = floor(half_bucket*10)+1;
          
          minz = min(mr(Zs(i)), mr(Zs(j)));
          maxz = max(mr(Zs(i)), mr(Zs(j)));
          pairs_structure(sample, minz,maxz, quantization_level*distanceR + half_bucket) = ...
              pairs_structure(sample, minz,maxz, quantization_level*distanceR + half_bucket) + 1;
          % find where the row of this atom type starts 
          
        end
    end
 end
end

NN = n_distinct*(n_distinct+1)/2* nbr_dist_bins * quantization_level + n_distinct;
uniq_out_data = zeros(n_samples, NN);

for s = 1: n_samples
     onesample = zeros(1, NN);
     idx = 1;
     for i=1:n_distinct
         onesample(idx) = atoms_count(s,i);
         idx = idx + 1;
         for j=i:n_distinct
             for d = 1:nbr_dist_bins*2
                onesample(idx) = pairs_structure(s, i,j, d);
                idx = idx +1;
             end
         end
     end
     uniq_out_data(s,:) = onesample;
   %  plot(onesample)
   %  pause
   %  close
end

out_data = uniq_out_data;

end