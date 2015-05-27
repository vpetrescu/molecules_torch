data = load('qm7b.mat');

N = size(data.X,1);
data.Z = zeros(N,23);
for i=1:N
    oneX = data.X(i,:,:);
    for m = 1:23
        data.Z(i,m) = round((2*data.X(i,m,m))^(1/2.4));
    end
end

save('qm7bZ.mat', 'data');
