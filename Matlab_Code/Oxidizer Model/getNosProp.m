function [ nosProp ] = getNosProp(nosPropSet, inChar, input)

list = nosPropSet(:,inChar);

START = find(list <= input,1,'last');
END = find(list >= input,1);

if isempty(START) || isempty(END)
    error(['Column ', num2str(inChar), ' does not within range of ', num2str(input)]);
end

nosProp = linearInterp(list([START ; END]) ,nosPropSet(START:END,:), input);


end

