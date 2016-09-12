function tracks=predictNewLocationsOfTracks(tracks)
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;

            % predict the current location of the track
            predictedCentroid = predict(tracks(i).kalmanFilter);

            % shift the bounding box so that its center is at
            % the predicted location
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end
