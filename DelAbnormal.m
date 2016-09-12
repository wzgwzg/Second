function newobjects=DelAbnormal(objects,delId)
num=numel(delId);
for i=1:num
    objects(objects(:,1)==delId(i),:)=[];
end
newobjects=objects;