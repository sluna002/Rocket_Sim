function [dataSet,indexMap] = organizer(rpaSet)

%REMIND STEVEN L. TO COMMENT

    orgC1 = sortrows(rpaSet,1);
    uniqueC1 = unique(orgC1(:,1));

    for ii = 1 : length(uniqueC1)
        startC1 = find(orgC1(:,1) == uniqueC1(ii),1);
        endC1 = find(orgC1(:,1) == uniqueC1(ii),1,'last');

        indexMap.OF(ii,[1,2]) = [uniqueC1(ii),ii];

        orgC2 = sortrows(orgC1(startC1:endC1,:),2);
        uniqueC2 = unique(orgC2(:,2));

        for jj = 1 : length(uniqueC2)
            startC2 = find(orgC2(:,2) == uniqueC2(jj),1);
            endC2 = find(orgC2(:,2) == uniqueC2(jj),1,'last');

            indexMap.Pc(jj,[1,2]) = [uniqueC2(jj),jj];

            orgC3 = sortrows(orgC2(startC2:endC2,:),3);
            uniqueC3 = unique(orgC3(:,3));

            for kk = 1 : length(uniqueC3)
                startC3 = find(orgC3(:,3) == uniqueC3(kk),1);
                endC3 = find(orgC3(:,3) == uniqueC3(kk),1,'last');

                indexMap.AcAt(kk,[1,2]) = [uniqueC3(kk),kk];

                orgC4 = sortrows(orgC3(startC3:endC3,:),4);
                uniqueC4 = unique(orgC4(:,4));

                for ll = 1 : length(uniqueC4)
                    startC4 = find(orgC4(:,4) == uniqueC4(ll),1);
                    indexMap.AeAt(ll,[1,2]) = [uniqueC4(ll),ll];

                    dataSet.OF(ii).Pc(jj).AcAt(kk).AeAt(ll).values = orgC4(startC4,:);

                end
            end
        end
    end
end
 
 
 
 