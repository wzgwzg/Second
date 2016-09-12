function newobjects=DeleteObjectinCrowd(frame_group,objects)
frame_group_num=size(frame_group,1);
for i=1:frame_group_num
    start=frame_group(i,1);
    eend=frame_group(i,2);
    rows=find(objects(:,2)>=start&objects(:,2)<=eend);
    objects(rows,:)=[];
end
newobjects=objects;