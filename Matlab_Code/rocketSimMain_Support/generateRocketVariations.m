function combinations = generateRocketVariations(Dp_min, Dp_fin_max, minGrainThickness, Mox_list, OF_list, AcAt_list, AeAt_list, D_feed_list)

grainGeometries = [];

otherCombinations = combinationGenerator(Mox_list, OF_list, AcAt_list, AeAt_list, D_feed_list);
numOther = size(otherCombinations,1);

grainNumber = 0;
for Dp = Dp_min :minGrainThickness: (Dp_fin_max-minGrainThickness)
    for Dp_fin = (Dp + minGrainThickness): minGrainThickness : Dp_fin_max
        tempGeometry = [Dp, Dp_fin];
        grainGeometries = [ grainGeometries ; repmat(tempGeometry,numOther,1) ];
        grainNumber = grainNumber + 1;
    end
end

combinations = [grainGeometries,repmat(otherCombinations,grainNumber,1)];

end
        