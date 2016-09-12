function [newobjects,obj_struct]=NewMergeObjects(objects)
tic;
obj_struct=InitializeObjectStruct(); %Iniatialize
groupId=0;
object_num=objects(end,1); %The number of all objects
objects(:,10)=0; %first set all objects' groupId to 0
dist_limit=1.17; %when the distance between two objects is less than this parameter, we can think they are near
group_assign_limit=37; %group assign threshold
delgroupId=[]; %record the groupId that needs to be deleted

for i=1:object_num
    disp(num2str(i));
    
    rows=find(objects(:,1)==i); %the rows of object id
    rows_num=numel(rows);       %the number of rows
    if(objects(rows(1),10)==0)  %if object id has not been assigned to a group, generate a new group
        groupId=groupId+1;
        obj_struct(groupId).groupId=groupId;
        obj_struct(groupId).group_type=1; %1 represents tube_group and 0 represents hybrid group
        objects(rows,10)=groupId;        %object id is assigned to this new group
        obj_struct(groupId).memberId=i;  %the first member of this new group
        obj_struct(groupId).member_type=1; %1 represents tube and 0 represents frame
        obj_struct(groupId).start_time=objects(rows(1),2);  %start time of object id
        obj_struct(groupId).duration=rows_num;  %duration of object id
        obj_struct(groupId).memberNum=1;  %record the num of members
    end
    
    cur_groupId=objects(rows(1),10); %the groupId of object i
    
    possible_neighborId=[]; %store the object id of possible neighbor
    
    for j=1:rows_num    %traverse all frames of object id to find its neighbor
        for p=1:3       %search from the current frame to the second frame after the current frame
            common_frame_rows=find(objects(:,2)==(objects(rows(j),2)+p-1) & objects(:,10) ~= cur_groupId & objects(:,1)>i);
            common_frame_rows_num=numel(common_frame_rows);
            if(common_frame_rows_num~=0)
                if(p==1) %There must be complete common frame between the current object and possible object
                    tempId=objects(common_frame_rows,1)';
                    intersectId=intersect(possible_neighborId,tempId);
                    tempId=setdiff(tempId,intersectId);
                    if(~isempty(tempId))
                        possible_neighborId=[possible_neighborId,tempId]; %record possible neighborId and delete the same element
                    end
                end
                
                box=objects(rows(j),3:6);
                for k=1:common_frame_rows_num
                    boxtmp=objects(common_frame_rows(k),3:6);
                    distance=estimateMerge(box,boxtmp);
                    if(distance<40)   %if the distance between object id and another one is less than 10, then they are treated as neighbors
                        
                        member=objects(common_frame_rows(k),1);
                        member_self_groupId=objects(common_frame_rows(k),10); %its original groupId
                        
                        cur_member_rows=find(objects(:,1)==member); %all rows of the current member
                        
                        if(member_self_groupId==0)
                            obj_struct(cur_groupId).memberId(end+1)=member;
                            obj_struct(cur_groupId).member_type(end+1)=1;
                            obj_struct(cur_groupId).start_time(end+1)=objects(cur_member_rows(1),2);
                            obj_struct(cur_groupId).duration(end+1)=numel(cur_member_rows);
                            obj_struct(cur_groupId).memberNum=obj_struct(cur_groupId).memberNum+1;
                            objects(cur_member_rows,10)=obj_struct(cur_groupId).groupId;
                        else
                            
                            mingroupId=min(cur_groupId,member_self_groupId);
                            maxgroupId=max(cur_groupId,member_self_groupId);
                            
                            if(mingroupId ~= maxgroupId)
                                delgroupId(end+1)=maxgroupId; %record the groupId that needs to be deleted
                                
                                disp([num2str(mingroupId),' ',num2str(maxgroupId),' ',num2str(member)]);
                                %merge group
                                trueGroup=obj_struct(mingroupId);
                                tempGroup=obj_struct(maxgroupId);
                                trueGroup.memberId=[trueGroup.memberId,tempGroup.memberId];
                                trueGroup.start_time=[trueGroup.start_time,tempGroup.start_time];
                                trueGroup.duration=[trueGroup.duration,tempGroup.duration];
                                trueGroup.member_type=[trueGroup.member_type,tempGroup.member_type];
                                trueGroup.memberNum=numel(trueGroup.memberId);
                                obj_struct(mingroupId)=trueGroup;
                                
                                %update part objects' groupId
                                for z=1:trueGroup.memberNum
                                    objects(objects(:,1)==trueGroup.memberId(z),10)=mingroupId;
                                end
                                
                                cur_groupId=mingroupId; %cur_groupId may change
                            end
                            
                        end
                        possible_neighborId=setdiff(possible_neighborId,member); %remove the contact neighbor id from possible id
                    end
                end
            end
        end
    end
    
    %find non-contact neighbor
    possible_neighbor_num=numel(possible_neighborId);
    if(possible_neighbor_num~=0)
        for m=1:possible_neighbor_num
            Id=possible_neighborId(m); %have common frames and non-contact possible Id
            possibleId_rows=find(objects(:,1)==Id); %the rows of possible Id
            possible_groupId=objects(possibleId_rows(1),10); % the groupId of possible neighboring object
            
            original_self_time=objects(rows,2); %The original time of the current tube
            original_time=objects(possibleId_rows,2); %The original time of possible neighbor
            intersect_rows=intersect(original_self_time,original_time); %intersection rows between object i and possible Id
            r=rows(ismember(objects(rows,2),intersect_rows)); %Id==i,rows in intersect rows
            g=possibleId_rows(ismember(objects(possibleId_rows,2),intersect_rows));
            d_Euclidean=sqrt(sum( (objects(r,7:8)-objects(g,7:8)).^2, 2));
            dist_parameter=objects(r,6);
            d_Euclidean=d_Euclidean./dist_parameter;
            minimum_dist=min(d_Euclidean);
            near_dist_num=numel(find(d_Euclidean<=dist_limit));
            if(exp(-minimum_dist)*near_dist_num>group_assign_limit)
                
                
                if(possible_groupId ~= 0)
                    mingroupId=min(cur_groupId,possible_groupId);
                    maxgroupId=max(cur_groupId,possible_groupId);
                    
                    if(mingroupId ~= maxgroupId)
                        delgroupId(end+1)=maxgroupId; %record the groupId that needs to be deleted
                        
                        disp([num2str(mingroupId),' ',num2str(maxgroupId),' ',num2str(Id)]);
                        %merge group
                        trueGroup=obj_struct(mingroupId);
                        tempGroup=obj_struct(maxgroupId);
                        trueGroup.memberId=[trueGroup.memberId,tempGroup.memberId];
                        trueGroup.start_time=[trueGroup.start_time,tempGroup.start_time];
                        trueGroup.duration=[trueGroup.duration,tempGroup.duration];
                        trueGroup.member_type=[trueGroup.member_type,tempGroup.member_type];
                        trueGroup.memberNum=numel(trueGroup.memberId);
                        obj_struct(mingroupId)=trueGroup;
                        
                        %update part objects' groupId
                        for z=1:trueGroup.memberNum
                            objects(objects(:,1)==trueGroup.memberId(z),10)=mingroupId;
                        end
                        
                        cur_groupId=mingroupId; %cur_groupId may change
                    end
                else
                    obj_struct(cur_groupId).memberId(end+1)=Id;
                    obj_struct(cur_groupId).member_type(end+1)=1;
                    obj_struct(cur_groupId).start_time(end+1)=objects(possibleId_rows(1),2);
                    obj_struct(cur_groupId).duration(end+1)=numel(possibleId_rows);
                    obj_struct(cur_groupId).memberNum=obj_struct(cur_groupId).memberNum+1;
                    objects(possibleId_rows,10)=obj_struct(cur_groupId).groupId;
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

%update the groupId of objects
for i=1:obj_struct_num
    final_groupId=obj_struct(i).groupId;
    final_member=obj_struct(i).memberId;
    for j=1:obj_struct(i).memberNum
        objects(objects(:,1)==final_member(j),10)=final_groupId;
    end
end

newobjects=objects;
toc;