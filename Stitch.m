group_num=numel(new_obj_struct);
object_num=newerobjects(end,1);
objId_groupId=zeros(object_num,2);
for i=1:group_num
    memberId=new_obj_struct(i).memberId;
    objId_groupId(memberId,1)=memberId;
    objId_groupId(memberId,2)=i;
end

for i=1:object_num
    tmptime=stitchtime(i,:);
    tmptime(tmptime==0)=[];
    newerobjects(newerobjects(:,1)==i,2)=tmptime;
end

length=max(max(stitchtime)); % the max value in stitchtime
wobj=VideoWriter(strcat('data/caronline.avi'));
wobj.FrameRate=frame_rate;
open(wobj);

for z = 1:length
    disp(num2str(z));
    
    stitch_mask=zeros(M,N); %detect collision caused by stitching
    [r,c]=find(stitchtime==z); %the index of element whose value is z in stitchtime
    bg=Background;
    
    %must stitch the whole frame first
    whole_frame=find(r>object_num);
    if(whole_frame)
        stitch_mask(:,:)=1; %the mask is set to all one
        gid=objId_groupId(objId_groupId(:,1)==r(whole_frame),2); %the group id of r(k)
        start_time=new_obj_struct(gid).start_time;
        memberId=new_obj_struct(gid).memberId;
        memberId_index=find(memberId==r(whole_frame));
        n=start_time(memberId_index)+c(whole_frame)-1;
        n_seconds=fix(n/25)+45000;
        
        an1=fix(n_seconds/3600);
        an2=fix(n_seconds/60)-60*an1;
        an3=fix(n_seconds-3600*an1-60*an2);
        
        tmp_image=read(mov,n);
        bg=tmp_image;
        %bg = insertObjectAnnotation(bg,'rectangle',[360,288,0,0],[num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',20);
    end
    
    for k=1:numel(r)
        if(r(k)>object_num)
            continue;
        else
            target_id=r(k);
            gid=objId_groupId(objId_groupId(:,1)==target_id,2);
            m=find(newerobjects(:,2)==z & newerobjects(:,1)==target_id);
            n=newerobjects(m,11);
            %time_n=newerobjects(m,12);
            n_seconds=fix(n/25)+1800;
            %n_seconds=n_seconds*2;
            an1=fix(n_seconds/3600);
            an2=fix(n_seconds/60)-60*an1;
            an3=fix(n_seconds-3600*an1-60*an2);
            
            frame_index=n;
            if(frame_index>original_frame_length)
                frame_index=original_frame_length;
            end
            tmp_image=read(mov,frame_index);
            id_tube=TTube(target_id);
            frame_mask_ind=find(id_tube.frame==n);
            newmask=id_tube.mask(:,:,frame_mask_ind);
            
            intersect_mask=stitch_mask & newmask; % detect if there is collision and where is it
            
            if(isempty(intersect_mask))
                bg=maskrgb2(bg,tmp_image,newmask);
            else
                bg=maskrgb3(bg,tmp_image,newmask,intersect_mask);
            end
            
            stitch_mask=stitch_mask | newmask; % after stitching the current object, we should change stitch_mask
            
%             gid=gid+101;
%             if(newerobjects(m,4)<90)
%                 bg = insertObjectAnnotation(bg,'rectangle',[newerobjects(m,3:4)+[0 newerobjects(m,6)] 0 0],['groupId:',num2str(gid), '-', num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',14);
%             else
%                 bg = insertObjectAnnotation(bg,'rectangle',[newerobjects(m,3:4) 0 0],['groupId:',num2str(gid),'-',num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',14);
%             end
        end
        
    end
    imshow(bg);
    %getframe;
    writeVideo(wobj,bg);
end

close(wobj);