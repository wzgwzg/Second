function minidistance = estimateMerge(box1,box2)
%calculate coordinates
x1=box1(1);
x2=x1+box1(3);
x3=box2(1);
x4=x3+box2(3);
y1=box1(2);
y2=y1+box1(4);
y3=box2(2);
y4=y3+box2(4);

judgementx=estimateIntersection(x1,x2,x3,x4);
judgementy=estimateIntersection(y1,y2,y3,y4);

if(judgementx&&judgementy)
    minidistance=0;
elseif(~judgementx&&judgementy)
    minidistance=min(abs(x3-x2),abs(x4-x1));
elseif(judgementx&&~judgementy)
    minidistance=min(abs(y3-y2),abs(y4-y1));
else
    if(x3>x2&&y3>y2)
        minidistance=sqrt((x3-x2).^2+(y3-y2)^2);
    elseif(x3>x2&&y1>y4)
        minidistance=sqrt((x3-x2).^2+(y4-y1).^2);
    elseif(x1>x4&&y3>y2)
        minidistance=sqrt((x4-x1).^2+(y3-y2).^2);
    else
        minidistance=sqrt((x4-x1).^2+(y4-y1).^2);
    end
end

end


function judgement = estimateIntersection(v1,v2,v3,v4)
if(v3>=v1&&v3<=v2)
    judgement=1;
elseif(v1>=v3&&v1<=v4)
    judgement=1;
else
    judgement=0;
end
end