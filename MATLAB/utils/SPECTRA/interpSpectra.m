function output_spectra = interpSpectra(wavelengths, temperature_i, spectra_i, temperature_k)
% function output_spectra = interpSpectra(wavelengths, temperature_i, spectra_i, temperature_k)
%
% INPUTS
%    - wavelengths --> vector of wavelengths
%    - temperature_i --> vector of temperatures (support)
%    - spectra_i ---> cell or column-arranged matrix of spectra
%    - temperature_k --> Targer temperatures to carry out the interpolation
%
% OUTPUS
%    - output_spectra --> Column-arranged matrix containing 
%      approximated spectra at temperature_k
%
% The function carries out interpolations, no extrapolations. Therefore,
% temperature_k must be contained within temperature_i
%
% If temperature_k is not defined, the function interpolates 100 equispaced
% points between the first and last elements of temperature_i


%% Input control

% temperature_k not defined
if (nargin == 3)
    temperature_k = linspace(temperature_i(1), temperature_i(end), 100);
end

% Sizes check
Lw = size(wavelengths);
Lt = size(temperature_i);
Lk = size(temperature_k);

if (numel(wavelengths) == 1)||(numel(temperature_i) == 1)||(numel(temperature_k) == 1)
   error ('wavelengths, temperature_i, and temperature_k cannot be scalar values but vectors'); 
end

if (numel(Lw) > 2) || (numel(Lt) > 2) || (numel(Lk) > 2)
   error ('wavelengths, temperature_i, and temperature_k cannot be tensors'); 
end

if (min(Lw) ~= 1) || (min(Lt) ~= 1) || (min(Lk) ~= 1)
   error ('wavelengths, temperature_i, and temperature_k must be vectors, not matrices');
end

% temperature_k is out of temperature_i
if (max(temperature_k) > max(temperature_i))|| ...
   (min(temperature_k) < min(temperature_i))
    error('temperature_k must be inside temperature_i');
end

% Type of spectra_i

if isa(spectra_i,'cell')
    % Size check if it is a cell
    Ls = size(spectra_i);
    
    if (sum(Ls - Lt) ~= 0)
        error ('Cell-defined spectra must be the same size as temperature_i'); 
    end
    
    % Cell to matrix conversion
    spectra_i = cell2mat(spectra_i);
    
    if (numel(spectra_i) ~= max(Lt)*max(Lw))
        error('The vectors inside each cell position must be the same size as wavelengths');
    end

    spectra_i = reshape(spectra_i, max(Lw), max(Lt));
    Ls = size(spectra_i);
    
elseif isa(spectra_i,'double')
    % Size check if it is a double matrix
    
    Ls = size(spectra_i);

    if (sum(Ls - [max(Lw), max(Lt)]) ~= 0)
        error ('The spectra_i matrix must be consistent with wavelengths and temperature_i'); 
    end
    
else
    error ('The type of spectra_i must be cell or double');
end

% Final sizes
Lw = max(Lw);
Lt = max(Lt);
Lk = max(Lk);

% We traspose wavelengths if needed to obtain a row vector
if size(wavelengths,1) > size(wavelengths,2)
    wavelengths = wavelengths';
end

% We get the wavelength precision
dW = diff(wavelengths(1:2));

% Output variable memory allocation
output_spectra = zeros(Ls);

%% Interpolation calculation

% The interpolation will be based on iterating, mean-referencing the
% boundary spectra of each segment and carry out a weighed sum.

support_index = 1;

temp_index = 1;
for temp = temperature_k
    left_temp = temperature_i(support_index);
    right_temp = temperature_i(support_index + 1);
    dist_temp = right_temp - left_temp;
    
    % Weighing coefficient
    alpha = 1 - (temp - left_temp)/dist_temp;
    
    % Now we must refer the mean values of each spectra to the same
    % wavelength
    left_spectrum = spectra_i(:, support_index);
    right_spectrum = spectra_i(:, support_index + 1);
    
    % We get the expected wavelengths
    left_mean = wavelengths*left_spectrum/sum(left_spectrum);
    right_mean = wavelengths*left_spectrum/sum(left_spectrum);
    result_mean = alpha*left_mean + (1 - alpha)*right_mean;
    
    % We estimate the displacements
    wavelength_phase = fix((right_mean - left_mean)/dW);
    compensation_phase = fix((result_mean - right_mean)/dW);
    
    % We circshift the left spectra to fit both means and carry out the
    % weighed sum
    left_spectrum = circshift(left_spectrum, wavelength_phase);
    
    result_spectrum = left_spectrum*alpha + right_spectrum*(1 - alpha);
    
    % Finally, we perform a small compensation on the wavelength_phase
    % assuming that the mean is displaced linearly (at least locally)
    output_spectra(:, temp_index) = ...
        circshift(result_spectrum, compensation_phase);
    
    % We must update the boundary elements of this segment if needed
    if (temp > right_temp)
        support_index = support_index + 1;
    end
    
    temp_index = temp_index + 1;
end
