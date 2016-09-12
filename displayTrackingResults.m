    function displayTrackingResults(obj,frame,mask,tracks)
        % convert the frame and the mask to uint8 RGB
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

        minVisibleCount = 1;
        if ~isempty(tracks)

            % noisy detections tend to result in short-lived tracks
            % only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);

            % display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % get bounding boxes
                bboxes = cat(1, reliableTracks.bbox);

                % get ids
                ids = int32([reliableTracks(:).id]);

                % create labels for objects indicating the ones for
                % which we display the predicted rather than the actual
                % location
                labels = cellstr(int2str(ids'));
%                 predictedTrackInds = ...
%                     [reliableTracks(:).consecutiveInvisibleCount] > 0;
%                 isPredicted = cell(size(labels));
%                 isPredicted(predictedTrackInds) = {' predicted'};
%                 labels = strcat(labels, isPredicted);

                % draw on the frame
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);

                % draw on the mask
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
            end
        end

        
        % display the mask and the frame
        obj.maskPlayer.step(mask);   
        obj.videoPlayer.step(frame);
     
    end 
  
