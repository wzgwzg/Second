%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mov=VideoReader('data/yizi.mp4');
% Background=read(mov,2);
% [M,N,~]=size(Background);
%original_frame_length=mov.NumberOfFrames;
%frame_rate=mov.FrameRate;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Stiching
num=numel(new_obj_struct);
objects(:,11)=objects(:,2);

for i=1:num
    disp(num2str(i));
    
    wobj=VideoWriter(strcat('Group/groupID',num2str(i),'.avi'));
    wobj.FrameRate=frame_rate;
    open(wobj);
    
    
    member=new_obj_struct(i).memberId;
    start_time=new_obj_struct(i).start_time;
    duration=new_obj_struct(i).duration;
    member_type=new_obj_struct(i).member_type;
    member_num=new_obj_struct(i).memberNum;
    
    time=zeros(member_num,1);
    stitchtime=[]; %the stitching time of every member in group i
    
    time(1)=1;
    detail_time=time(1):time(1)+duration(1)-1;
    stitchtime(1,1:duration(1))=detail_time;
    
    
    if(member_type(1)==1)
        rows=find(objects(:,1)==member(1));
        objects(rows,2)=detail_time;
    end
    
    if(member_num>1)
        for j=2:member_num
            lasttime=start_time(j-1);
            curtime=start_time(j);
            time(j)=time(j-1)+curtime-lasttime;
            
            if(member_type(j)==0)
                detail_time=time(j):time(j)+duration(j)-1;
                stitchtime(j,1:duration(j))=detail_time;
            else
                original_rows=find(objects(:,1)==member(j));
                original_time=objects(original_rows,2);
                original_start_time=original_time(1);
                delta_t=original_start_time-time(j);
                detail_time=original_time-delta_t;
                stitchtime(j,1:duration(j))=detail_time;
                objects(original_rows,2)=detail_time;
            end
            
        end
    end
    
    
    length=max(max(stitchtime)); % the max value in stitchtime
    
    for z = 1:length
        disp(num2str(z));
        
        [r,c]=find(stitchtime==z); %the index of element whose value is z in stitchtime
        id=member(r); %the corresponding memberId
        gid=i;
        bg=Background;
        
        for k=1:numel(id)
            if(member_type(r(k))==0)
                n=start_time(r(k))+c(k)-1;
                n_senconds=fix(n/25);
                an1=fix(n_senconds/3600);
                an2=fix(n_senconds/60)-60*an1;
                an3=fix(n_senconds-3600*an1-60*an2);
                tmp_image=read(mov,n);
                bg=tmp_image;
                bg = insertObjectAnnotation(bg,'rectangle',[500,500,0,0],'whole frame','TextBoxOpacity',0,'Fontsize',14);
            else
                target_id=id(k);
                m=find(objects(:,2)==z & objects(:,1)==target_id);
                n=objects(m,11);
                n_senconds=fix(n/25);
                an1=fix(n_senconds/3600);
                an2=fix(n_senconds/60)-60*an1;
                an3=fix(n_senconds-3600*an1-60*an2);
                frame_index=n;
                if(frame_index>original_frame_length)
                    frame_index=original_frame_length;
                end
                tmp_image=read(mov,frame_index);
                id_tube=TTube(target_id);
                frame_mask_ind=find(id_tube.frame==n);
                newmask=id_tube.mask(:,:,frame_mask_ind);
                
                
                bg=maskrgb2(bg,tmp_image,newmask);
                
                if(objects(m,4)<90)
                    bg = insertObjectAnnotation(bg,'rectangle',[objects(m,3:4)+[0 objects(m,6)] 0 0],['Id:',num2str(target_id),' Gid:',num2str(gid), ' N:',num2str(n),' ', num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',18);
                else
                    bg = insertObjectAnnotation(bg,'rectangle',[objects(m,3:4) 0 0],['Id:',num2str(target_id),' Gid:',num2str(gid), ' N:',num2str(n),' ', num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',18);
                end
                
            end
            
        end
        imshow(bg);
        %getframe;
        writeVideo(wobj,bg);
    end
    
    close(wobj);
end
