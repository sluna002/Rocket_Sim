function [func] = extrapolateFuncGen(pointx, pointy)
%LAGRANGE   approx a point-defined function using the Lagrange polynomial interpolation
%
%      LAGRANGE(X,POINTX,POINTY) approx the function definited by the points:
%      P1=(POINTX(1),POINTY(1)), P2=(POINTX(2),POINTY(2)), ..., PN(POINTX(N),POINTY(N))
%      and calculate it in each elements of X
%
%      If POINTX and POINTY have different number of elements the function will return the NaN value
%
%      function wrote by: Carlo Castoldi carlo.castoldi(at)gmail.com
%      7-oct-2001
%
if size(pointx,2) == 1
    pointx = pointx';
end

if size(pointy,2) == 1
    pointy = pointy';
end

n=size(pointx,2);
L=sym(ones(n,1));
if (size(pointx,2)~=size(pointy,2))
   fprintf(1,'\nERROR!\nPOINTX and POINTY must have the same number of elements\n');
   y=NaN;
else
   syms inp;
   for i=1:n
      for j=1:n
         if (i~=j)
            L(i)=L(i) * (inp-pointx(j))/(pointx(i)-pointx(j));
         end
      end
   end
   tempFunc = symfun(L .* pointy', inp);
   func = symfun(sum(tempFunc(inp)),inp);
end