function new_obj_struct=MergeObjectandFrame(obj_struct,frame_group,object_num)
frame_group_num=size(frame_group,1);
obj_struct_num=numel(obj_struct);
for i=1:frame_group_num
    
    start=frame_group(i,1);
    eend=frame_group(i,2);
    
    for j=1:obj_struct_num
        
        end_time=obj_struct(j).end_time;
        startrep=repmat(start,obj_struct(j).memberNum,1);
        time_interval=startrep-end_time;
        
        if(~isempty(time_interval(time_interval==1)))
            obj_struct(j).group_type=0; %1 represents tube_group and 0 represents hybrid group
            obj_struct(j).memberId(end+1)=i+object_num;
            obj_struct(j).member_type(end+1)=0; %1 represents tube and 0 represents frame
            obj_struct(j).start_time(end+1)=start;
            obj_struct(j).duration(end+1)=eend-start+1;
            obj_struct(j).end_time(end+1)=eend;
            obj_struct(j).memberNum=numel(obj_struct(j).memberId);
            break;
        end
    end
end

new_obj_struct=obj_struct;