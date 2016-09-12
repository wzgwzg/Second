function objects=Generate_Objects(TTrack)
j=1;
for i=1:numel(TTrack)
    tmp=TTrack{i};
   if(size(tmp,2)~=0)
        for k=1: size(tmp,2)
            newtrack(j,1:9)=0;
            newtrack(j,1)=tmp(k).id;
            newtrack(j,2)=i;
            newtrack(j,3:6)=tmp(k).bbox;   
            newtrack(j,7:8)=tmp(k).centroid;
            newtrack(j,9)=tmp(k).area;
            j=j+1;
        end
    end
end
objects=unique(newtrack,'rows');