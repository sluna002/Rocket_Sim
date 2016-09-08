function [ root ] = getRoot()
%Find the root directory of the project by parsing the directory that this
%file sits in

workingDir = mfilename('fullpath');
findDir = 'Rocket Sim';
index = strfind(workingDir, findDir);
root = workingDir(1:(index + length( findDir ) ) );

end

