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