    function tracks=updateUnassignedTracks(unassignedTracks,tracks,mask)
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
             tracks(ind).mask=mask; 
        end
    end
