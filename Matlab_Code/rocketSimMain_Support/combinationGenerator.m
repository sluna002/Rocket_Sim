function list = combinationGenerator(varargin)
    
    %Feed in an arbitrary amount of vectors and this will generate all
    %possible combiniations of those vector values
    
    numInputs = length(varargin);
    index = zeros(1,numInputs);
    
    for ii = 1 : numInputs
        index(ii) = length(varargin{ii});
    end
    
    max = prod(index);
    len = length(index); 
    row_number = repmat(1:max,len,1)';
    divisor = repmat(max./cumprod(index),max,1);
    modulus = repmat(index,max,1);
    index_list = mod(floor((row_number-1)./divisor),modulus)+1;
    
    list = zeros(max,numInputs);
    for ii = 1 : numInputs
        list(:,ii) = varargin{ii}(index_list(:,ii));
    end
    
end