function output = grabValues(rpaStruct, indexMap, OFw, Pc, AcAt, AeAt)

    %inputs
%     OF = 5.6;
%     Pc = 30.6;
%     AcAt = 3;
%     AeAt = 4;



    OFStart = find(indexMap.OF(:,1) <= OFw, 1, 'last');
    OFEnd = find(indexMap.OF(:,1) >= OFw,1);
    
    if isempty(OFStart) || isempty(OFEnd)
        error(['OF = ',num2str(OFw)]);
    end

    PcStart = find(indexMap.Pc(:,1) <= Pc, 1, 'last');
    PcEnd = find(indexMap.Pc(:,1) >= Pc,1);
    
    if isempty(PcStart) || isempty(PcEnd)
        error(['Pc = ',num2str(Pc)]);
    end

    AcAtStart = find(indexMap.AcAt(:,1) == AcAt,1);

    AeAtStart = find(indexMap.AeAt(:,1) == AeAt,1);

    valuesTemp = zeros(4,11);

    valuesTemp(1,:) = rpaStruct.OF(OFStart).Pc(PcStart).AcAt(AcAtStart).AeAt(AeAtStart).values;
    valuesTemp(2,:) = rpaStruct.OF(OFStart).Pc(PcEnd).AcAt(AcAtStart).AeAt(AeAtStart).values;
    valuesTemp(3,:) = rpaStruct.OF(OFEnd).Pc(PcStart).AcAt(AcAtStart).AeAt(AeAtStart).values;
    valuesTemp(4,:) = rpaStruct.OF(OFEnd).Pc(PcEnd).AcAt(AcAtStart).AeAt(AeAtStart).values;
    
    valuesTemp(1,:) = linearInterp(indexMap.OF(OFStart:OFEnd,1),valuesTemp(1:2,:),OFw);
    valuesTemp(2,:) = linearInterp(indexMap.OF(OFStart:OFEnd,1),valuesTemp(3:4,:),OFw);
    
    output = linearInterp(indexMap.Pc(PcStart:PcEnd,1),valuesTemp(1:2,:),Pc);
    
        

end


