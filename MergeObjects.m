function [newobjects,obj_struct]=MergeObjects(objects)
obj_struct=InitializeObjectStruct(); %Iniatialize
groupId=0;
object_num=objects(end,1); %The number of all objects
objects(:,10)=0; %first set all objects' groupId to 0

for i=1:object_num
    rows=find(objects(:,1)==i); %the rows of object id
    rows_num=numel(rows);       %the number of rows
    if(objects(rows(1),10)==0)  %if object id has not been assigned to a group, generate a new group
        groupId=groupId+1;
        obj_struct(groupId).groupId=groupId;
        objects(rows,10)=groupId;        %object id is assigned to this new group
        obj_struct(groupId).memberId=i;  %the first member of this new group
        obj_struct(groupId).start_time=objects(rows(1),2);  %start time of object id
        obj_struct(groupId).duration=rows_num;  %duration of object id
        obj_struct(groupId).memberNum=2;  %member num add one to accept another member
    end
    for j=1:rows_num    %traverse all frames of object id to find its neighbor
        for p=1:3       %search from the current frame to the second frame after the current frame
            common_frame_rows=find(objects(:,2)==(objects(rows(j),2)+p-1) & objects(:,10)==0 & objects(:,1)>i);
            common_frame_rows_num=numel(common_frame_rows);
            if(common_frame_rows_num~=0)
                box=objects(rows(j),3:6);
                for k=1:common_frame_rows_num
                    boxtmp=objects(common_frame_rows(k),3:6);
                    distance=estimateMerge(box,boxtmp);
                    if(distance<10)   %if the distance between object id and another one is less than 10, then they are treated as neighbors
                        member=objects(common_frame_rows(k),1);
                        cur_member_rows=find(objects(:,1)==member); %all rows of the current member
                        cur_groupId=objects(rows(j),10); %the groupId of object id
                        obj_struct(cur_groupId).memberId(obj_struct(cur_groupId).memberNum)=member;
                        obj_struct(cur_groupId).start_time(obj_struct(cur_groupId).memberNum)=objects(cur_member_rows(1),2);
                        obj_struct(cur_groupId).duration(obj_struct(cur_groupId).memberNum)=numel(cur_member_rows);
                        obj_struct(cur_groupId).memberNum=obj_struct(cur_groupId).memberNum+1;
                        objects(cur_member_rows,10)=obj_struct(cur_groupId).groupId;
                    end
                end
            end
        end
       
        
    end
end
newobjects=objects;