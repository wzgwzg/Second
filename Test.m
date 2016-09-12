%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%访问obj_struct某field的各个元素
num=numel(obj_struct);
for i=1:num
    disp(num2str(i));
    member=obj_struct(i).memberId;
    member_num=numel(member);
    for j=1:member_num
        disp(num2str(member(j)));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Generate Tube
mov=VideoReader('E:/OptimalCenter/Revise/video/v2_down1.AVI');
Background=read(mov,2);
[M,N,~]=size(Background);

objects_num=newobjects(end,1);
TTube = struct(...
    'total',{},...
    'frame', {}, ...
    'mask', {});
maxtotal=0;
mintotal=zeros(1,objects_num);
for i=1:objects_num
    mm=find(objects(:,1)==i);
    num_frame=objects(find(objects(:,1)==i),2);
    total=length(mm);
    mintotal(i)=total;
    
    Mask=zeros(M,N,total);
    for im = 1:total
        object_mask=zeros(M,N);
        a1=TTrack{num_frame(im)}.mask;
        box = objects(mm(im),3:6);
        
        box(find(box<=0))=1;
        if (box(1)+box(3)-1)>N && (box(2)+box(4)-1)<=M
            object_mask(box(2):box(2)+box(4)-1,box(1):N)=1;
            a2=object_mask;
            newmask=imdilate(a1&a2,strel('rectangle', [3, 3]));
        end
        if (box(2)+box(4)-1)>M && (box(1)+box(3)-1)<=N
            object_mask(box(2):M,box(1):box(1)+box(3)-1)=1;
            a2=object_mask;
            newmask=imdilate(a1&a2,strel('rectangle', [3, 3]));
        end
        if (box(2)+box(4)-1)>M && (box(1)+box(3)-1)>N
            object_mask(box(2):M,box(1):N)=1;
            a2=object_mask;
            newmask=imdilate(a1&a2,strel('rectangle', [3, 3]));
        end
        if (box(1)+box(3)-1)<=N && (box(2)+box(4)-1)<=M && (box(1))>=1 && (box(2))>=1
            object_mask(box(2):box(2)+box(4)-1,box(1):box(1)+box(3)-1)=1;
            a2=object_mask;
            newmask=imdilate(a1&a2,strel('rectangle', [3, 3]));
        end
        Mask(:,:,im)=newmask;
    end
    if maxtotal<total
        maxtotal=total;
    end
    
    TTube(i)=struct(...
        'total',total,...
        'frame',num_frame , ...
        'mask', Mask);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Stiching
objects_num=newobjects(end,1);
num=numel(obj_struct);
time=zeros(objects_num,1);
start=-25;
for i=1:num
    member=obj_struct(i).memberId;
    start_time=obj_struct(i).start_time;
    duration=obj_struct(i).duration;
    member_num=numel(member);
    start=start+60;
    time(member(1))=start;
    detail_time=time(member(1)):time(member(1))+duration(1)-1;
    rows=find(newobjects(:,1)==member(1));
    newobjects(rows,2)=detail_time;
    if(member_num>1)
        for j=2:member_num
            lasttime=start_time(j-1);
            curtime=start_time(j);
            time(member(j))=time(member(j-1))+curtime-lasttime;
            detail_time=time(member(j)):time(member(j))+duration(j)-1;
            rows=find(newobjects(:,1)==member(j));
            newobjects(rows,2)=detail_time;
        end
    end
end

length=1850;
wobj=VideoWriter('data/test_group.avi');
wobj.FrameRate=25;
open(wobj);
for z = 1:length
    m=find(newobjects(:,2)==z);
    id=newobjects(m,1);
    gid=newobjects(m,10);
    bg=Background;
    
    for k=1:numel(id)
        v=m(k);
        n=objects(v,2);
        %         n_senconds=fix(Time_n/Frame_Rate);
        %         an1=fix(n_senconds/3600);
        %         an2=fix(n_senconds/60)-60*an1;
        %         an3=fix(n_senconds-3600*an1-60*an2);
        
        target_id=id(k);
        target_gid=gid(k);
        tmp_image=read(mov,n);
        id_tube=TTube(id(k));
        frame_mask_ind=find(id_tube.frame==n);
        newmask=id_tube.mask(:,:,frame_mask_ind);
        
        
        [bg]=maskrgb2(bg,tmp_image,newmask);
        bg = insertObjectAnnotation(bg,'rectangle',[objects(v,3:4) 0 0],['Id:',num2str(target_id),' Gid:',num2str(target_gid)],'Color','red','TextBoxOpacity',0,'Fontsize',12);
        %bg = insertObjectAnnotation(bg,'rectangle',[newobjects(v,3:4) 0 0],[num2str(an1),':',num2str(an2),':',num2str(an3)],'Color','red','TextBoxOpacity',0,'Fontsize',12);
    end
    imshow(bg);
    getframe;
    writeVideo(wobj,bg);
end

close(wobj);


