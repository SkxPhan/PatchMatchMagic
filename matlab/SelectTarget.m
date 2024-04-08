function BW = SelectTarget(I)
figure
imshow(I); title('Select a occlusion area and press Enter');
I1=rgb2gray(I);
hold on
[x,y,c]=ginput(1);
m(1)=x;
n(1)=y;
k=2;
while(c==1)
    [x1,y1,c1]=ginput(1);
    if c1==1
    m(k)=x1;
    n(k)=y1;
    plot(x,y,'r');
    line([m(k-1) m(k)],[n(k-1) n(k)]);
    k=k+1;
    c=c1;
    else
        break
    end
end
line([m(k-1) m(1)],[n(k-1) n(1)]);
BW = roipoly(I1,m,n);
end