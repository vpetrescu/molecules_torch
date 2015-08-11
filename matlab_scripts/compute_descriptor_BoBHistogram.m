function [out_data, out_labels] = compute_descriptor_BoBHistogram(indices, ...
                                                               data, ...
                                                               n_distinct,...
                                                               mr,...
                                                               nbr_dist_bins,...
                                                               quantization_level,...
                                                               molecule_size)


%quantization_level = 5;
n_samples = max(size(indices));
pairs_structure = zeros(n_samples, n_distinct, n_distinct, ...
                     nbr_dist_bins * quantization_level);
atoms_count = zeros(n_samples, n_distinct);

out_labels = zeros(size(data.T));


%% Hard coded here
M = molecule_size;
maxDistance = 0;
for sample = 1:n_samples
  indext = indices(sample);
  
  if (size(data.T,1)~=1)
    out_labels(sample,:) = data.T(indext,:);
  else
    out_labels(sample) = data.T(indext);
  end
  Zs = zeros([M,1]);
  Xs = data.X(indext,:,:);
  Xs = reshape(Xs, [M, M]);
  for i=1:M
    Zs(i) = round((2*Xs(i,i))^(1/2.4));
    % increase count of this molecule
    if (Zs(i) ~= 0)
       % Zs(i)
        atoms_count(sample, mr(Zs(i))) = atoms_count(sample, mr(Zs(i))) + 1;
    end
    for j=i+1:M   
        Zs(j) = round((2*Xs(j,j))^(1/2.4));
        if (Zs(i) ~= 0 && Zs(j)~= 0)
          %% increase count of Zs(i), Zs(j) pair  
          fdistanceR = Zs(i)*Zs(j)/Xs(i,j);
           if maxDistance < fdistanceR
            maxDistance = fdistanceR;
          end
          distanceR = floor(fdistanceR);
          distanceR = min(distanceR, nbr_dist_bins);
          difference = abs(distanceR - fdistanceR); % is in [0,1]
          
          half_bucket = max(1, ceil(difference* quantization_level));

          minz = min(mr(Zs(i)), mr(Zs(j)));
          maxz = max(mr(Zs(i)), mr(Zs(j)));
          pairs_structure(sample, minz,maxz, quantization_level*distanceR + half_bucket) = ...
              pairs_structure(sample, minz,maxz, quantization_level*distanceR + half_bucket) + 1;
          % find where the row of this atom type starts 
          
        end
    end
 end
end

fprintf(1,'max distance in dataset %f\n',maxDistance);
%pause
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
% 
% For 0001
%     half_bucket = abs(fdistanceR - distanceR);
%     half_bucket = floor(half_bucket*10)+1;
%    
% For 050
%         if fdistanceR - distanceR > 0.5
%               half_bucket = 2;
%           else
%               half_bucket = 1;
% %           end
%   For distance 0.25
%           if fdistanceR - distanceR > 0.75
%               half_bucket = 4;
%           elseif fdistanceR - distanceR > 0.5
%               half_bucket = 3;
%           elseif fdistanceR - distanceR > 0.25
%               half_bucket = 2;
%           else
%               half_bucket = 1;
%           end
% 
%   For distance 0125
%            if fdistanceR - distanceR > 0.875
%               half_bucket = 8;         
%            elseif fdistanceR - distanceR > 0.750
%               half_bucket = 7;
%            elseif fdistanceR - distanceR > 0.625
%               half_bucket = 6;
%            elseif fdistanceR - distanceR > 0.5
%               half_bucket = 5;
%           elseif fdistanceR - distanceR > 0.375
%               half_bucket = 4;
%           elseif fdistanceR - distanceR > 0.250
%               half_bucket = 3;
%           elseif fdistanceR - distanceR > 0.125
%               half_bucket = 2;
%           else
%               half_bucket = 1;
%           end