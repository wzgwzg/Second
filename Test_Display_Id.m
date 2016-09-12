original_mov=VideoReader('data/processed1.mp4');
original_frame_length=mov.NumberOfFrames;
Background=read(mov,2);

[M,N,~]=size(Background);


NN=objects(end,1);


TTube = struct(...
    'total',{},...
    'frame', {}, ...
    'mask', {}); 
mintotal=zeros(1,NN);
for i=1:NN
    disp(num2str(i));
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
   
    
    TTube(i)=struct(...
        'total',total,...
        'frame',num_frame , ...
        'mask', Mask);
end


tt0=ones(NN,1);
for aaa=2:NN
    tt0(aaa)=20*(aaa-1);
end


l=1821;
NN=objects(end,1);
t0=ones(NN,1);
lb=t0;
ub=l*t0-mintotal(:)+1;
%ub=l*t0-20;
tt0=zeros(NN,1);
tt0(1)=1;
for i=2:NN
    tt0(i)=24*(i-1);
end
% TolFun
tic;
options = saoptimset('InitialTemperature',500,'MaxIter',120,'TolFun',1e-3,'Display','diagnose');
% options = saoptimset('DataType','custom','AnnealingFcn',@newpoint,'MaxIter',5000,'TolFun',1e-3,'Display','diagnose');
fun = @sum_objective2;
t = round(simulannealbnd(fun,tt0,lb,ub,options));
toc;

%%%%%%%%%%%%%%%%%%%%%%%%6.Formal
testobjects=objects;
for i=1:NN
    m=find(objects(:,1)==i);
    sm=t(i):(t(i)+mintotal(i)-1);
    if ~isempty(m)
        testobjects(m(1):m(end),2)=sm;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%Test
testobjects=objects;
for i=1:NN
    m=find(objects(:,1)==i);
    sm=tt0(i):(tt0(i)+mintotal(i)-1);
    if ~isempty(m)
        testobjects(m(1):m(end),2)=sm;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%����

len=1821;
wobj=VideoWriter('data/demo5_08_2.avi');
wobj.FrameRate=frame_rate;
open(wobj);
for z = 1:len
    m=find(testobjects(:,2)==z);
    id=testobjects(m,1);
    n=[];
    %bg=Background_color(mov,ind_Background(z),downsamplenum,temporal,opt);
    bg=Background;
    %     tmp_image=imresize(read(mov,ind_Background(z)),downsamplenum);%%%%%%%ȡԭʼ��Ƶ֡����ɫ�Ա�ͨ��
    %     [y] = rgb2ycbcr(tmp_image);
    %      cb=y(:,:,2);
    %      cr=y(:,:,3);
    %     bg_gray=new_Background(:,:,z);
    %     bgYcbcr(:,:,1)=uint8( 255*(bg_gray-min(bg_gray(:)))/(max(bg_gray(:))-min(bg_gray(:))) );
    %     bgYcbcr(:,:,2)=cb;
    %     bgYcbcr(:,:,3)=cr;
    %     bg=ycbcr2rgb( bgYcbcr );
    
    for k=1:length(id)
        v=m(k);
        
        n=objects(v,2);
        
        Time_n=objects(v,2);
        n_senconds=fix(Time_n/Frame_Rate); 
        an1=fix(n_senconds/3600);
        an2=fix(n_senconds/60)-60*an1;
        an3=fix(n_senconds-3600*an1-60*an2);
        
        target_id=id(k);
        tmp_image=read(mov,n);%%%%%%%
        id_tube=TTube(id(k));
        frame_mask_ind=find(id_tube.frame==n);
        newmask=id_tube.mask(:,:,frame_mask_ind);
        
        %         ly=find_boundary(480,616,newmask,'up');
        %         lx=find_boundary(480,616,newmask,'left');
        
        [bg]=maskrgb2(bg,tmp_image,newmask);
        %[bg]=Poisson_blending(bg,tmp_image,newmask);
        %bg = insertObjectAnnotation(bg,'rectangle',[objects1(v,3:4) 0 0],['Id:',num2str(target_id),' N:',num2str(z)],'Color','red','TextBoxOpacity',0,'Fontsize',12);
        bg = insertObjectAnnotation(bg,'rectangle',[objects(v,3:4) 0 0],['Id:',num2str(target_id),' N:',num2str(z),' ', num2str(an1),':',num2str(an2),':',num2str(an3)],'Color','red','TextBoxOpacity',0,'Fontsize',10);
    end
    imshow(bg);
    writeVideo(wobj,bg);
end

%%%%%%%%%%%%%%%%%%%%7.��������Ƶ
%movie2avi(video_M,'F:\revise_test_video1.avi','FPS',10)  ;
close(wobj);
