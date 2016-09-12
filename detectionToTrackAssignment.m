    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment(centroids,tracks)
    
        nTracks = length(tracks);
        nDetections = size(centroids, 1);

        % compute the cost of assigning each detection to each track
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end

        % solve the assignment problem
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

