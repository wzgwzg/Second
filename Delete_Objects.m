function newobjects=Delete_Objects(objects)
num=objects(end,1);
limit=2; %delete objects whose duration is less than 2 frames
for i=1:num
    rows=find(objects(:,1)==i);
    rows_num=numel(rows);
    if(rows_num<=limit)
        objects(rows,:)=[];
    end
end
newobjects=objects;
