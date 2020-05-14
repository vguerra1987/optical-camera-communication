function output = fineTuneRotation(img, template, do_debug)
% This function fine tunes the rotation compensation using a template

if nargin == 2
    do_debug = 0;
end

rho_obj = 0.95;
iteration = 10;

curr_rho = 0;
curr_theta = 0;

alpha = 0.01;
theta_sample = 1;

derivative = Inf;

% We iterate until one of the following conditions is satisfied
while (iteration > 0) && (curr_rho < rho_obj) && (abs(derivative) > 0.0001)
    
    img_rot = imrotate(img, curr_theta);
    curr_rho = getNewRho(img_rot, template, curr_rho);
    
    % We estimate the derivative using a centered difference scheme
    % (evaluating the correlation with +-2 deviations)
    aux_img = imrotate(img, curr_theta + theta_sample);
    rho_next = getNewRho(aux_img, template, 0);
    aux_img = imrotate(img, curr_theta - theta_sample);
    rho_prev = getNewRho(aux_img, template, 0);
    derivative = (rho_next-rho_prev)/2/theta_sample;
    second_derivative = (rho_next - 2*curr_rho + rho_prev)/2/theta_sample;
    
    step = -alpha/2*(rho_obj -curr_rho)/(derivative + eps);
    % step = alpha/2*log((curr_rho -rho_obj)^2)*(curr_rho-rho_obj)/derivative;
    
    if (abs(step) < 1)
        step = sign(step);
    end
    
    curr_theta = curr_theta - step;
    
    if (do_debug)
        fprintf('Derivative: %f\n', derivative);
        fprintf('Second derivative: %f\n', second_derivative);
        fprintf('Step: %f\n',step);
        fprintf('Rho: %f\n',curr_rho);
        fprintf('Function: %f\n', (curr_rho - rho_obj)^2);
        fprintf('Next rotation: %f\n', curr_theta);
        
        imshow(img_rot,[]);
        drawnow;
    end
    iteration = iteration - 1;
end

output = img_rot;

end

function curr_rho = getNewRho(img, template, curr_rho)
% We calculate the correlation coefficient for all the pixels and get
% the maximum
Lrow = size(template,1);
Lcol = size(template,2);
for I = 1:size(img,1)-Lrow
    for J = 1:size(img,2)-Lcol
        aux = pearsonCoeff(img(I:I+Lrow-1, J:J+Lcol-1,:), template);
        if (aux > curr_rho)
            curr_rho = aux;
        end
    end
end
end

function out = pearsonCoeff(blockA,blockB)
out = mean(blockA.*blockB, 'all') - ...
    mean(blockA, 'all')*mean(blockB, 'all');
out = out/std(blockA(:))/std(blockB(:));
end