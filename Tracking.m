mov=VideoReader('data/video1.avi');
totalframes=mov.NumberOfFrames;
frame_rate=mov.FrameRate;
obj = setupSystemObjects('data/cheng2_mask.avi');
tracks = initializeTracks(); % create an empty array of tracks
i=1;
nextId = 1; % ID of the next track
TTrack =[];

% for z=1:totalframes
%     readFrame(obj);
% end

for j=1:totalframes
    
    frame = readFrame(obj);
    
    [areas, centroids, bboxes, mask] = detectObjects(frame,obj);
    
    tracks=predictNewLocationsOfTracks(tracks);
    
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment(centroids,tracks);
    
    tracks= updateAssignedTracks(assignments,centroids,bboxes,areas,tracks,mask);
    
    tracks=updateUnassignedTracks(unassignedTracks,tracks,mask);
    
    tracks=deleteLostTracks(tracks);
    
    [tracks,nextId]=createNewTracks(unassignedDetections,centroids,bboxes,areas,nextId,tracks,mask);
    
    TTrack{i}=tracks;
    i=i+1;
    
    displayTrackingResults(obj,frame,mask,tracks);
    
end