clc
clear
close all

a=im2double(rgb2gray(imread('googlecar.jpg')));
a1=zeros(size(a)); %a1 is the mean image

figure, imshow(a)

[m,n]=size(a);

%% averaging
AveWinSizeRatio=10; %ratio of size of averaging window size
m1=round(m*AveWinSizeRatio/200);
n1=round(n*AveWinSizeRatio/200);

for i=1:m
    for j=1:n
        x1=i-m1;
        x2=i+m1;
        y1=j-n1;
        y2=j+n1;
        x1(x1<1)=1;
        y1(y1<1)=1;
        x2(x2>m)=m;
        y2(y2>n)=n;
        b=a(x1:x2,y1:y2);
        a1(i,j)=mean(b(:));
    end
end
figure, imshow(a1)
% clearvars i j x1 x2 y1 y2 

%% bright spotting

% Treshold=.4; %threshold for bright spots
a2=a-a1;
a2(a2<0)=0;
Treshold=mean(a2(:))+0.5*std(a2(:)); %threshold for bright spots
a2(a2<Treshold)=0;
a2(a2~=0)=1;
figure, imshow(a2)

%% 8-adjacency
kernel=[1 1 1; 1 0 1; 1 1 1]/8;
% a3=conv2(a2,kernel,'same')>=.998;
a3=conv2(a2,kernel,'same')==1;
figure, imshow(a3)

data1=regionprops(a3,'centroid','BoundingBox','ConvexImage','MajorAxisLength','MinorAxisLength','Orientation');
n=1;
for i=1:numel(data1)
    x=data1(i).BoundingBox;
    if x(3)<50 && x(4)<50
        y(n)=i;
        n=n+1;
    end
end
data1(y)=[];

figure, imshow(a3)
hold on
for i=1:numel(data1)
    rectangle('Position',round(data1(i).BoundingBox),'EdgeColor','r')
end
clearvars i x y n 

%% filling
a4=a3;
for k=1:numel(data1)
    box=round(data1(k).BoundingBox);
    abox=a3(box(2):box(2)+box(4),box(1):box(1)+box(3));
    
    [xcrd,ycrd]=find(abox==1);
    crd=[xcrd ycrd];
    center=round(mean(crd));
    
    m=(ycrd-center(2))./(xcrd-center(1));
    for i=1:numel(xcrd)
        if xcrd(i)~=center(1)
            x=min([xcrd(i) center(1)]):max([xcrd(i) center(1)]);
            y=round(m(i)*(x-center(1))+center(2));
            for j=1:numel(x)
                abox(x(j),y(j))=1;
            end
        else
            y=min([ycrd(i) center(2)]):max([ycrd(i) center(2)]);
            for j=1:numel(y)
                abox(xcrd(i),y(j))=1;
            end
        end
    end
    a4(box(2):box(2)+box(4),box(1):box(1)+box(3))=abox;
end
figure, imshow(a4)

data2=regionprops(a4,'centroid','BoundingBox','ConvexImage','MajorAxisLength','MinorAxisLength','Orientation');
n=1;
for i=1:numel(data2)
    x=data2(i).BoundingBox;
    if x(3)<50 && x(4)<50
        z(n)=i;
        n=n+1;
    end
end
data2(z)=[];

figure, imshow(a4)
hold on
for i=1:numel(data2)
    rectangle('Position',round(data2(i).BoundingBox),'EdgeColor','r')
end

%% ellipse check
n=1;
data3=data2;
for k=1:numel(data2)
    box=round(data2(k).BoundingBox);
    abox=a4(box(2):box(2)+box(4),box(1):box(1)+box(3));
    area1=sum(sum(abox));
    area2=0.25*pi*data2(k).MajorAxisLength*data2(k).MinorAxisLength;
    if abs(area2-area1)/area1>0.20
        z1(n)=k;
        n=n+1;
    end
end
data3(z1)=[];

figure, imshow(a4)
hold on
for i=1:numel(data3)
    rectangle('Position',round(data3(i).BoundingBox),'EdgeColor','r')
end

 %% drawing ellipses
theta = 0:(pi/64):(2*pi);
figure,
imshow(a4)
hold on
 for k=1:numel(data3)
     ax1=[0 data3(k).MinorAxisLength/2];
     ax2=[data3(k).MajorAxisLength/2 0];
     alpha=-pi*data3(k).Orientation/180;
     
     
     
     x1=ax1(1)*cos(theta)+ax2(1)*sin(theta);
     y1=ax1(2)*cos(theta)+ax2(2)*sin(theta);
     cent=data3(k).Centroid;
     x=x1*cos(alpha)-y1*sin(alpha)+cent(1);
     y=y1*cos(alpha)+x1*sin(alpha)+cent(2);
     plot(x,y,'b','LineWidth',2)
     
     yl1=[-data3(k).MinorAxisLength/2 data3(k).MinorAxisLength/2];
     xl1=[0 0];
     xL1=xl1*cos(alpha)-yl1*sin(alpha)+cent(1);
     yL1=yl1*cos(alpha)+xl1*sin(alpha)+cent(2);
     
     xl2=[-data3(k).MajorAxisLength/2 data3(k).MajorAxisLength/2];
     yl2=[0 0];
     xL2=xl2*cos(alpha)-yl2*sin(alpha)+cent(1);
     yL2=yl2*cos(alpha)+xl2*sin(alpha)+cent(2);
     
     plot(xL1,yL1,'--r')
     plot(xL2,yL2,'--r','LineWidth',2)
 end
figure,
imshow(a)
hold on
 for k=1:numel(data3)
     ax1=[0 data3(k).MinorAxisLength/2];
     ax2=[data3(k).MajorAxisLength/2 0];
     alpha=-pi*data3(k).Orientation/180;
     
     
     
     x1=ax1(1)*cos(theta)+ax2(1)*sin(theta);
     y1=ax1(2)*cos(theta)+ax2(2)*sin(theta);
     cent=data3(k).Centroid;
     x=x1*cos(alpha)-y1*sin(alpha)+cent(1);
     y=y1*cos(alpha)+x1*sin(alpha)+cent(2);
     plot(x,y,'b','LineWidth',2)
     
     yl1=[-data3(k).MinorAxisLength/2 data3(k).MinorAxisLength/2];
     xl1=[0 0];
     xL1=xl1*cos(alpha)-yl1*sin(alpha)+cent(1);
     yL1=yl1*cos(alpha)+xl1*sin(alpha)+cent(2);
     
     xl2=[-data3(k).MajorAxisLength/2 data3(k).MajorAxisLength/2];
     yl2=[0 0];
     xL2=xl2*cos(alpha)-yl2*sin(alpha)+cent(1);
     yL2=yl2*cos(alpha)+xl2*sin(alpha)+cent(2);
     
     plot(xL1,yL1,'--r')
     plot(xL2,yL2,'--r','LineWidth',2)
 end

