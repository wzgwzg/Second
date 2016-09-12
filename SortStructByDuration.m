function new_obj_struct=SortStructByDuration(obj_struct)

struct_num=numel(obj_struct);
duration_array=zeros(struct_num,1);

for i=1:struct_num
    duration_array(i)=obj_struct(i).group_duration;
end

[duration_array,index]=sort(duration_array,'descend');

for j=1:struct_num
    temp=obj_struct(index(j));
    temp.groupId=j;
    new_obj_struct(j)=temp;
end

