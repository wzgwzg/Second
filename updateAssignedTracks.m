 function tracks=updateAssignedTracks(assignments,centroids,bboxes,areas,tracks,mask)
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);
            area = areas(detectionIdx, :);

            % correct the estimate of the object's location
            % using the new detection
            correct(tracks(trackIdx).kalmanFilter, centroid);

            % replace predicted bounding box with detected
            % bounding box
            tracks(trackIdx).bbox = bbox;
            tracks(trackIdx).centroid = centroid;
            tracks(trackIdx).mask=mask; 
            tracks(trackIdx).area = area;
            % update track's age
            tracks(trackIdx).age = tracks(trackIdx).age + 1;

            % update visibility
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end
