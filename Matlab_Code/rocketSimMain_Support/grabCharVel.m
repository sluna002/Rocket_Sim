function values = grabValues_MeanPressure(rpaStruct, indexMap, OFw, AcAt, AeAt)

NN = zeros(size(indexMap.Pc,1));
values_list = zeros(NN,11);

for ii = 1 : NN
    values_list(ii,:) = grabValues(rpaStruct, indexMap, OFw, indexMap.Pc(ii,1), AcAt, AeAt);
end

values = mean(values_list);

end