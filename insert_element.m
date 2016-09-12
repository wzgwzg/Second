%insert a specified element into a specified position of a array
function new_array=insert_element(array,element,pos)
array1=array(1:pos);
array2=array(pos+1:end);
new_array=[array1,element,array2];
end