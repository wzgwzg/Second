%Calculate the duration of every group
function new_obj_struct=Calculate_group_duration(obj_struct)
groupnum=numel(obj_struct);
group_duration=zeros(groupnum,1);

for i=1:groupnum
    start_time=obj_struct(i).start_time;
    duration=obj_struct(i).duration;
    memberNum=obj_struct(i).memberNum;
    end_time=zeros(memberNum,1);
    
    for j=1:memberNum
        end_time(j)=start_time(j) + duration(j) - 1;
    end
   
    start=min(start_time);
    eend=max(end_time);
    group_duration(i)=eend-start+1;
    obj_struct(i).group_duration=group_duration(i);
    obj_struct(i).end_time=end_time;
end

new_obj_struct=obj_struct;
end