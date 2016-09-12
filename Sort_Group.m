function new_obj_struct=Sort_Group(obj_struct)
struct_num=numel(obj_struct);
for i=1:struct_num
    tempGroup=obj_struct(i); %the current obj_struct;
    
    start_time=tempGroup.start_time; 
    memberId=tempGroup.memberId;
    duration=tempGroup.duration;
    member_type=tempGroup.member_type;
    end_time=tempGroup.end_time;
    
    %sort the data by start_time
    [start_time,index]=sort(start_time);
    memberId=memberId(index);
    duration=duration(index);
    member_type=member_type(index);
    end_time=end_time(index);
    
    %update tempGroup
    tempGroup.start_time=start_time;
    tempGroup.memberId=memberId;
    tempGroup.duration=duration;
    tempGroup.member_type=member_type;
    tempGroup.end_time=end_time;
    
    %update obj_struct
    obj_struct(i)=tempGroup;
end

new_obj_struct=obj_struct;