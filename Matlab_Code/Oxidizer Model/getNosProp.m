function [ nosProp ] = getNosProp(nosPropSet, rhog)

rhogList = nosPropSet(:,4);

START = find(rhogList <= rhog,1,'last');
END = find(rhogList >= rhog,1);

if isempty(START) || isempty(END)
    useless = 0;
end

nosProp = linearInterp(rhogList([START ; END]) ,nosPropSet(START:END,:), rhog);


end

