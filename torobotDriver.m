
clear L
%constants for angle conversions
rad= pi/180;
deg= 180/pi;
%points for jbot path
points=[200 80
        300 20
        380 320
        20  380
        380 380]/100;
%set jbot joint specifications
L(1) = Revolute('d', 0, 'a', 1.04, 'alpha', 0, ...
    'qlim', [-90 90]*rad );
L(2) = Revolute('d', 0, 'a', .7, 'alpha', 0, ...
    'qlim', [-90 90]*rad );
L(3) = Revolute('d', 0, 'a', 1.24, 'alpha', 0, ...
    'qlim', [-90 90]*rad );
jbot=SerialLink(L, 'name', 'jbot', ...
    'manufacturer', 'jacob', 'ikine', 'jbot');
jbot.base = transl([1.5,2,0]) ;
for i=1:numrows(points)
    T(:,:,i) = transl(points(i,1), points(i,2), 0);
end

Ts1 = ctraj(T(:,:,1), T(:,:,2), 100);
Ts2 = ctraj(T(:,:,2), T(:,:,3), 100);
Ts3 = ctraj(T(:,:,3), T(:,:,4), 100);
Ts4 = ctraj(T(:,:,4), T(:,:,5), 100);
for i=1:length(Ts2(1,1,:))
    Ts1(:,:,99+i)=Ts2(:,:,i);
    Ts1(:,:,199+i)=Ts3(:,:,i);
    Ts1(:,:,299+i)=Ts4(:,:,i);
end
qs1 = jbot.ikine(Ts1, [0 0 0], [1 1 0 0 0 0]);
jbot.plot(qs1, 'view', 'top', 'workspace', [0 5 0 5 -1 1], 'ortho')
%declare to robot controller object
torb=Torobot('port','COM4','debug',1,'nservos',3,'baud',9600);
%send pose command to torobot controller with to move joints represented by
%jbot virtual robot object
for i=1:numrows(qs)
    torb.setpos([1 2 3], [qs1(i,1)*deg  qs1(i,2)*deg qs1(i,3)*deg],200)
    pause(.2);
end