function frame_group=separate_crowded_frames(frame_index,frame_rate)
frame_index_len=numel(frame_index);
frame_group=zeros(1,2); %record the start time and end time of a crowded video clip
group_index=1;
gstart=frame_index(1);

for i=1:frame_index_len-1
    if(frame_index(i+1)-frame_index(i)>4*frame_rate)  %if the frame index is discontinuous
        %frame_index=insert_element(frame_index,0,i); %then separate the frame index
        gend=frame_index(i);
        frame_group(group_index,:)=[gstart,gend]; %record the current start and end time of a index group
        group_index=group_index+1;
        gstart=frame_index(i+1);
    end
end

gend=frame_index(frame_index_len);
frame_group(group_index,:)=[gstart,gend];
end

