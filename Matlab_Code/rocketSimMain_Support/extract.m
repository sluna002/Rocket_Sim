function out = extract(fileName)

fileID = fopen(fileName);

%Skip the first nine lines of the file
for x = 1 : 9
    line = fgetl(fileID);
end

data = [];

while ischar(line)
    
    len = length(line);
    spaceInedex = find(line == ' ');
    consecutiveSpace = diff(spaceInedex);
    
    %Reduce all consecutive spaces in a line to a single space so that str2num can
    %convert it to a number
    line(spaceInedex(consecutiveSpace == 1)) = [];
    
    %Delete first and last spaces in line
    line([1,end]) = [];
    data = [data ; str2num(line)];
    line = fgetl(fileID);
    
end

out = data;

fclose(fileID);

end