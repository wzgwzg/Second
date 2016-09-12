function newobjects=changeID(objects)
Ids=unique(objects(:,1));
for index=2:length(Ids)
    if(Ids(index)-1==Ids(index-1))
        continue;
    else
        rows=find(objects(:,1)==Ids(index));
        objects(rows,1)=Ids(index-1)+1;
        Ids=unique(objects(:,1));
    end
end
newobjects=objects;
end