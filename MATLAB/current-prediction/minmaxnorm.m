function data_out = minmaxnorm(data_in)

data_out = zeros(size(data_in));
data_out(:,end) = data_in(:,end);

for I = 1:size(data_in,1)
    aux = data_in(I,1:end-1);
    data_out(I,1:end-1) = (aux - min(aux))/(max(aux) - min(aux));
    
end