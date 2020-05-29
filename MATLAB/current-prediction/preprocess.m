%% PREPROCESS

% This is currently an example and must be expanded to all the colors and
% to the actual current_list
root_folder = 'Database/Green/';
current_list = [0 50e-3 100e-3];
num_bands = 9;

% ROI positions
ROI = [0,0];
is_roi_defined = 0;

% We iterate on each current

for current = current_list(end:-1:1)
    current_str = sprintf('%1.3f',current);
    filelist = strsplit(ls(strcat(root_folder, current_str)));
    
    num_files = (length(filelist)-2)/3;
    signatures = zeros(num_files, num_bands);
    
    % We iterate over all the files in the folder
    iterator = 1;
    for filename = filelist
        % Each time we find a new .bin file, we read the envi and save the
        % signatures        
        if ~isempty(filename{1}) && strcmp(filename{1}(end-2:end),'bin')
            path_and_file = strcat(root_folder, ...
                                    current_str,'/', ...
                                    filename{1}(1:end-4));
                                
            dummy_image = freadenvi(path_and_file);
            % If ROI is not defined, we ask the used to enter the test
            % point
            if ~is_roi_defined
                imshow(dummy_image(:,:,4)/1024, []);
                [ROI(2), ROI(1)] = ginput(1);
                ROI = round(ROI);
                is_roi_defined = 1;
            end
            
            % We read the signatures
            signatures(iterator, :) = dummy_image(ROI(1), ROI(2),:);
  
            iterator = iterator + 1;
        end
        
    end
    
    save(strcat(current_str, '_signatures.mat'), 'signatures');
    
end