function [ nosProp ] = getNosProp(nosPropSet, inChar, input)

list = nosPropSet(:,inChar);

START = find(list <= input,1,'last');
END = find(list >= input,1);

if isempty(START) || isempty(END)
    useless = 0;
end

nosProp = linearInterp(list([START ; END]) ,nosPropSet(START:END,:), input);


end

