    function  tracks=deleteLostTracks(tracks)
        if isempty(tracks)
            return;
        end

        invisibleForTooLong = 10;
        ageThreshold = 8;

        % compute the fraction of the track's age for which it was visible
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;

        % find the indices of 'lost' tracks
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

        % delete lost tracks
        tracks = tracks(~lostInds);
    end
