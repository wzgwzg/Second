function GenerateVideo(sourcepath,savepath,format)
directory=dir(strcat(sourcepath,'*.',format));
num=length(directory);
wobj=VideoWriter(strcat(savepath,'data.avi'));
wobj.FrameRate=25;
open(wobj);
for i=300:num
    name=directory(i).name;
    complete_name=strcat(sourcepath,name);
    frame=imread(complete_name);
    writeVideo(wobj,frame);
end
close(wobj);