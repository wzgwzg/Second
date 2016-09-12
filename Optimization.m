function [stitchtime,optimal_time]=Optimization(new_obj_struct,newerobjects,frame_group)
tic;
object_num=newerobjects(end,1);
groupnum=numel(new_obj_struct);
frame_group_num=size(frame_group,1);
tmpobj=newerobjects(:,[1:6,9]); %record the temporary test time of each object

%the max single tube duration
maxduration=0;
for i=1:groupnum
    duration=new_obj_struct(i).duration;
    tmpmax_duration=max(duration);
    if(maxduration<tmpmax_duration)
        maxduration=tmpmax_duration;
    end
end


stitchtime=zeros(object_num+frame_group_num,maxduration); %record the time position of each object

optimal_time=zeros(groupnum,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the initialization of the first group
optimal_time(1)=1; %the first group is placed on the first position

member=new_obj_struct(1).memberId;
start_time=new_obj_struct(1).start_time;
duration=new_obj_struct(1).duration;
member_type=new_obj_struct(1).member_type;
member_num=new_obj_struct(1).memberNum;

time=zeros(member_num,1);

time(1)=optimal_time(1);
detail_time=time(1):time(1)+duration(1)-1;
stitchtime(member(1),1:duration(1))=detail_time;
tmpobj(tmpobj(:,1)==member(1),2)=detail_time;



if(member_num>1)
    for j=2:member_num
        lasttime=start_time(j-1);
        curtime=start_time(j);
        time(j)=time(j-1)+curtime-lasttime;
        
        if(member_type(j)==0)
            detail_time=time(j):time(j)+duration(j)-1;
            stitchtime(member(j),1:duration(j))=detail_time;
        else
            original_rows=find(newerobjects(:,1)==member(j));
            original_time=newerobjects(original_rows,11);
            original_start_time=original_time(1);
            delta_t=original_start_time-time(j);
            detail_time=original_time-delta_t;
            stitchtime(member(j),1:duration(j))=detail_time;
            tmpobj(original_rows,2)=detail_time;
        end
        
    end
end

current_stitch_time=new_obj_struct(1).group_duration+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Optimization
for i=2:groupnum
    
    disp(['group: ',num2str(i)]);
    
    %basic information of group i
    member=new_obj_struct(i).memberId;
    start_time=new_obj_struct(i).start_time;
    duration=new_obj_struct(i).duration;
    member_type=new_obj_struct(i).member_type;
    member_num=new_obj_struct(i).memberNum;
    
    tmpstitchtime=zeros(member_num,max(duration));
    
    %find a proper time position of the current group from the beginning to
    %current_stitch_time
    for j=1:3:current_stitch_time
        [cur_stitch,~]=find(stitchtime==j); % the current stitched object in the test frame
        cur_stitch=unique(cur_stitch);
        cur_stitch_num=numel(cur_stitch);
        
        if(cur_stitch_num>10)
            continue;
        end
        
        optimal_time(i)=j; % the test time position
        
        time=zeros(member_num,1);
        
        time(1)=optimal_time(i); %the time position of the first member of group i
        detail_time=time(1):time(1)+duration(1)-1;
        tmpstitchtime(1,1:duration(1))=detail_time;
        tmpobj(tmpobj(:,1)==member(1),2)=detail_time;
        
        %set time positions for other members of group i
        if(member_num>1)
            for k=2:member_num
                lasttime=start_time(k-1);
                curtime=start_time(k);
                time(k)=time(k-1)+curtime-lasttime;
                
                if(member_type(k)==0)
                    detail_time=time(k):time(k)+duration(k)-1;
                    tmpstitchtime(k,1:duration(k))=detail_time;
                else
                    original_time=newerobjects(newerobjects(:,1)==member(k),11);
                    original_start_time=original_time(1);
                    delta_t=original_start_time-time(k);
                    detail_time=original_time-delta_t;
                    tmpstitchtime(k,1:duration(k))=detail_time;
                    tmpobj(tmpobj(:,1)==member(k),2)=detail_time;
                end
                
            end
        end
        
        %calculate collision
        collision=0;
        collision_threshold=25*(floor(member_num/10)+1); %collision threshold
        too_collision=false;
        
        for z=1:member_num
            z_test_time=tmpstitchtime(z,:); %the test time of the current member
            z_test_time(z_test_time==0)=[]; %remove the 0 element
            % find objects that have common stitch time with the current
            % member
            [r,~]=find(stitchtime>=z_test_time(1) & stitchtime<=z_test_time(end));
            r=unique(r);
            r_num=numel(r);
            
            for e=1:r_num
                r_stitchtime=stitchtime(r(e),:);
                r_stitchtime(r_stitchtime==0)=[];
                intersect_time=intersect(z_test_time,r_stitchtime);
                intersect_time_num=numel(intersect_time);
                
                if(~isempty(intersect_time)) %is there exists intersect time exactly
                    if(member_type(z)==1) %member_type(z) represents a tube
                        rows1=find(tmpobj(:,1)==member(z) & tmpobj(:,2)>=intersect_time(1) & tmpobj(:,2)<=intersect_time(end));
                        if(r(e)<=object_num) % r(e) is the index of tube object
                            
                            rows2=find(tmpobj(:,1)==r(e) & tmpobj(:,2)>=intersect_time(1) & tmpobj(:,2)<=intersect_time(end));
                            
                            rows1_num=numel(rows1);
                            rows2_num=numel(rows2);
                            
                            if(rows1_num ~= intersect_time_num || rows2_num ~= intersect_time_num)
                                rawtime1=tmpobj(rows1,2);
                                rawtime2=tmpobj(rows2,2);
                                [~,row_index]=setdiff(rawtime1,intersect_time);
                                rows1(row_index)=[];
                                [~,row_index]=setdiff(rawtime2,intersect_time);
                                rows2(row_index)=[];
                                %                                 if(rows1_num>rows2_num)
                                %                                     [~,row_index]=setdiff(rawtime1,rawtime2);
                                %                                     rows1(row_index)=[];
                                %                                 else
                                %                                     [~,row_index]=setdiff(rawtime2,rawtime1);
                                %                                     rows2(row_index)=[];
                                %                                 end
                            end
                            
                            box1=tmpobj(rows1,3:6);
                            box2=tmpobj(rows2,3:6);
                            intersect_box=diag(rectint(box1,box2));
                            non_zero_num=numel(find(intersect_box ~= 0));
                            non_zero_num=floor(non_zero_num/12)+1; %convert to seconds, 12 is frame rate
                            
                            min_area=min(tmpobj(rows1,7),tmpobj(rows2,7));
                            intersect_box=intersect_box./min_area;
                            collision=collision+sum(intersect_box)*exp(non_zero_num);
                            
                        else
                            rows1_num=numel(rows1);
                            intersect_seconds=floor(rows1_num/12)+1;
                            collision=collision+rows1_num*exp(intersect_seconds);
                        end
                        
                        if(collision>collision_threshold)
                            too_collision=true;
                            break;
                        end
                    else % member_type(z) represents a clip
                        if(r(e)>object_num) % r(e) also represents a clip
                            too_collision=true;
                            break;
                        else
                            rows2=find(tmpobj(:,1)==r(e) & tmpobj(:,2)>=intersect_time(1) & tmpobj(:,2)<=intersect_time(end));
                            rows2_num=numel(rows2);
                            intersect_seconds=floor(rows2_num/12)+1;
                            collision=collision+rows2_num*exp(intersect_seconds);
                            if(collision>collision_threshold)
                                too_collision=true;
                                break;
                            end
                        end
                        
                    end
                end
            end
            
            if(too_collision)
                break; % if the current frame is too collision, stop in advance
            end
            
        end
        
        if(collision<collision_threshold)
            stitchtime(member(1),1:duration(1))=tmpstitchtime(1,1:duration(1));
            
            if(member_num>1)
                for h=2:member_num
                    if(member_type(h)==1)
                        stitchtime(member(h),1:duration(h))=tmpstitchtime(h,1:duration(h));
                    else
                        stitchtime(member(h),1:duration(h))=tmpstitchtime(h,1:duration(h));
                    end
                end
            end
            
            current_stitch_time=max(max(stitchtime))+1;
            break; %the optimal stitch time of group i has been found, stop in advance
        end
    end
    
    
end
toc;


