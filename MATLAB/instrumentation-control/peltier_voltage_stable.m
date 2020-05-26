function stable = peltier_voltage_stable(power_supply, ...
                                         peltier_channel,...
                                         alpha)

num_samples = 100;
measurements = zeros(1,num_samples);

% We get some measurements with a sample rate of approximately 100 ms.
for I = 1:num_samples
    measurements(I) = power_supply.getMeasure(peltier_channel);
    pause(0.1);
end

% Now we must analyze the derivative using a test
frames = diff(measurements);

% We return the result of a Welch's t-test on the derivative.
% We invert the result because the null hypothesis (0) implies
% that has stabilized (true), and the alternative
% hypothesis (1), the opposite (false).
stable = 1 - ttest(frames, 0, alpha);