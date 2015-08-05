 load('qm7bZ.mat');

z_values = [1,6,7,8,16, 17];
max_z_count = [0,0,0,0,0, 0];
% maximum per element type
for i=1:size(z_values, 2)
   z = sum(data.Z == z_values(i), 2);
   max_z_count(i) = max(z);  
end
% Max values in a molecule 16, 7, 3 ,3 1 

% maximum per bond type
z_count = zeros(size(data.Z,1) , 6);
for i=1:size(z_values, 2)
   z_count(:,i) = sum(data.Z == z_values(i), 2);
end

%% only 176 elements
uniq_z_count = unique(z_count, 'rows');

