function estimate = linearInterp(inputRange, outputRange, input)
    if diff(inputRange) ~= 0
        percent = (input - inputRange(1))/diff(inputRange);
        estimate = percent * diff(outputRange) + outputRange(1,:);
    else
        estimate = outputRange(1,:);
    end
end

