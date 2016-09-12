function [new_obj_struct,newerobjects]=Group_adjustment(obj_struct,frame_group,newobjects)
num=size(frame_group,1);
delgroupId=[]; %record the groupId that needs to be deleted

for i=1:num
    
    frame_number1=frame_group(i,1)-1; %the frame number before the crowded video clip
    frame_number2=frame_group(i,2)+1; %the frame number after the crowded video clip
    
    rows=find(newobjects(:,2)==frame_number1 | newobjects(:,2)==frame_number2); %find rows in which objects appear before/after the crowded scene
    tempGroupId=newobjects(rows,10); %group of those object whcih appear before/after the crowded scene
    tempGroupId=unique(tempGroupId); %remove the same element in tempGroupId
    
    
    
    groupNum=numel(tempGroupId);
    if(groupNum>1) %if those objects do not belong to one group, then merge group
        groupId=min(tempGroupId);
        trueGroup=obj_struct(groupId); %other groups should be merged into this group
        
        for j=1:groupNum
            if(tempGroupId(j)~=groupId)
                tempGroup=obj_struct(tempGroupId(j));
                              
                %Merge
                
                trueGroup.memberId=[trueGroup.memberId,tempGroup.memberId];
                trueGroup.start_time=[trueGroup.start_time,tempGroup.start_time];
                trueGroup.duration=[trueGroup.duration,tempGroup.duration];
                trueGroup.member_type=[trueGroup.member_type,tempGroup.member_type];
                trueGroup.memberNum=numel(trueGroup.memberId);
                obj_struct(groupId)=trueGroup;  
                delgroupId(end+1)=tempGroupId(j); %record the groupId that needs to be deleted
               
                %update part objects' groupId
                for z=1:trueGroup.memberNum
                    newobjects(newobjects(:,1)==trueGroup.memberId(z),10)=groupId;
                end
                
            end
        end
    end
    
end

%delete disabled group
delnum=numel(delgroupId);
for i=1:delnum
    obj_struct([obj_struct.groupId]==delgroupId(i))=[];
end

%update the groupId of obj-struct
obj_struct_num=numel(obj_struct);
for i=1:obj_struct_num
    obj_struct(i).groupId=i;
end

new_obj_struct=obj_struct;


%update the groupId of objects
for i=1:obj_struct_num
    final_groupId=obj_struct(i).groupId;
    final_member=obj_struct(i).memberId;
    for j=1:obj_struct(i).memberNum
        newobjects(newobjects(:,1)==final_member(j),10)=final_groupId;
    end
end
newerobjects=newobjects;


