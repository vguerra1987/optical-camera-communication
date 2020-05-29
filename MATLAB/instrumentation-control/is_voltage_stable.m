function stable = is_voltage_stable(power_supply, ...
                                         channel,...
                                         alpha)

num_samples = 100;
measurements = zeros(1,num_samples);

% We get some measurements with a sample rate of approximately 100 ms.
for I = 1:num_samples
    measurements(I) = power_supply.getMeasure(channel);
    pause(0.01);
end

fprintf('media: %f std: %f\n',mean(measurements), std(measurements));

% Now we must analyze the derivative using a test
frames = diff(measurements);

% We return the result of a Welch's t-test on the derivative.
% We invert the result because the null hypothesis (0) implies
% that has stabilized (true), and the alternative
% hypothesis (1), the opposite (false).
[h,~] = ttest(frames, 0, alpha)
stable = 1 - h;