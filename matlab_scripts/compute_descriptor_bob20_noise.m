function [out_data, out_labels] = compute_descriptor_bob20_noise(indices, data)
%% transform molecules

n_distinct = 5;
nbr_dist_bins = 20;

N = n_distinct* n_distinct * nbr_dist_bins;
n_data_size = size(indices,1);



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
%% Make x10 of data by adding small gaussian noise to the distances
NOISE = 10;
out_data = zeros(n_data_size*NOISE,1,1, N);
out_labels = zeros(n_data_size*NOISE, 1);
atoms_count = zeros(size(indices,1)*NOISE, n_distinct);

for sample = 1:size(indices,1)
    for n=1:NOISE
        indext = indices(sample) + 1;
        sample_id = (sample-1) * NOISE + n;
        out_labels(sample_id) = data.T(indext);
        Zs = data.Z(indext,:);
        Zs = reshape(Zs, [23,1]);
        Rs = data.R(indext,:,:);
        Rs = reshape(Rs, [23,3]);
        for i=1:M
            if (Zs(i) ~= 0)
                atoms_count(sample_id, mr(Zs(i))) = atoms_count(sample_id, mr(Zs(i))) + 1;
            end
            for j=i+1:M
                if (Zs(i) ~= 0 && Zs(j)~= 0)
                    %% increase count of Zs(i), Zs(j) pair
                    distanceR = sqrt(sum((Rs(i,:) - Rs(j,:)).^2)) + random('norm',0, 0.5);
                    distanceR = round(distanceR);
                    distanceR = min(distanceR, 20);
                    % find where the row of this atom type starts
                    idx_zi = mapping(Zs(i));
                    % find the index of this atom
                    mr_zi =  mr(Zs(j)) - 1;
                    
                    idx_zj = mapping(Zs(j));
                    mr_zj = mr(Zs(i)) - 1;
                    
                    out_data(sample_id,1,1,idx_zi + nbr_dist_bins*mr_zj + distanceR) = ...
                        out_data(sample_id,1,1,idx_zi + nbr_dist_bins*mr_zj + distanceR) + 1;
                    out_data(sample_id,1,1,idx_zj + nbr_dist_bins*mr_zi + distanceR) = ...
                        out_data(sample_id,1,1,idx_zj + nbr_dist_bins*mr_zi + distanceR) + 1;
                end
            end
        end % end atom 1 loop
    end %% end noise loop
end

uniq_out_data = zeros(n_data_size *NOISE, 1,1, ...
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