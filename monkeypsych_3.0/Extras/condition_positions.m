function new_coordinates = condition_positions(amplitude_x_close_target,distance_between_close_and_far_x,angle_between_targets,task_effector)
% AUDV
% new_coordinates = condition_positions(amplitude_x_close_target,distance_between_close_and_far_x,angle_between_targets)
% If you want an excentricity of 12 degrees for the first set of
% targets and 24 for the second one with a 20 degree angle you input
% new_coordinates = condition_positions(12,12,20)
% then copy to excel using the import wizard and delimit your data by
% spaces, finally copy paste to a condition file that has the titles and
% it's done.

%FIX TARGET POSITIONS WHEN THE ANGLE CAUSES REMANENTS OF THE DIVISION

%audv
% close all, 
eye_hnd_offset=3; eye_fixation_y=10;  radius=2.5; x_offset=0; %offset not represented in plot

posible_positions=360/angle_between_targets;
x_1=amplitude_x_close_target;                   x_1_far=amplitude_x_close_target+distance_between_close_and_far_x;
y_1=eye_fixation_y;                             y_1_far=eye_fixation_y;

for k=1:floor(posible_positions)-1;
    angle=angle_between_targets*k;
    x_1(k+1,1)=cosd(angle)*amplitude_x_close_target;
    x_1_far(k+1,1)=cosd(angle)*(amplitude_x_close_target+distance_between_close_and_far_x);
    y_1(k+1,1)=(sind(angle)*amplitude_x_close_target)+eye_fixation_y;
    y_1_far(k+1,1)=(sind(angle)*(amplitude_x_close_target+distance_between_close_and_far_x))+eye_fixation_y;

end

if nargin<4
    task_effector = 0;
end

switch task_effector
    
    case {0,1}
        
    case 2
    case 3
    case 4
        
end


k=k+1;  x_2=-x_1;   x_2_far=-x_1_far;   y_2=y_1;    y_2_far=y_1_far;
figure('units','normalized','outerposition',[0 0 1 1])
ang=0:0.01:2*pi;
xp=radius*cos(ang);
yp=radius*sin(ang);
hold on,
axis equal
plot(x_1([1;2;end]),y_1([1;2;end]),'ro','MarkerFaceColor','r','MarkerEdgeColor','r' );
plot(x_2([1;2;end]),y_2([1;2;end]),'ro','MarkerFaceColor','r','MarkerEdgeColor','r' );
plot(x_1_far([1;2;end]),y_1_far([1;2;end]),'ro','MarkerFaceColor','r','MarkerEdgeColor','r' );
plot(x_2_far([1;2;end]),y_2_far([1;2;end]),'ro','MarkerFaceColor','r','MarkerEdgeColor','r' );

for i=1:k
    x_1_c{i}=x_1(i)+xp;
    y_1_c{i}=y_1(i)+yp;
    x_2_c{i}=x_2(i)+xp;
    y_2_c{i}=y_2(i)+yp;
    x_1_far_c{i}=x_1_far(i)+xp;
    x_2_far_c{i}=x_2_far(i)+xp;
    y_1_far_c{i}=y_1_far(i)+yp;
    y_2_far_c{i}=y_2_far(i)+yp;
end

plot([x_1_c{1,1};x_1_c{1,2};x_1_c{1,end}]',[y_1_c{1,1};y_1_c{1,2};y_1_c{1,end}]','r--','LineWidth',5)
plot([x_2_c{1,1};x_2_c{1,2};x_2_c{1,end}]',[y_2_c{1,1};y_2_c{1,2};y_2_c{1,end}]','r--','LineWidth',5)
plot([x_1_far_c{1,1};x_1_far_c{1,2};x_1_far_c{1,end}]',[y_1_far_c{1,1};y_1_far_c{1,2};y_1_far_c{1,end}]','r--','LineWidth',5)
plot([x_2_far_c{1,1};x_2_far_c{1,2};x_2_far_c{1,end}]',[y_2_far_c{1,1};y_2_far_c{1,2};y_2_far_c{1,end}]','r--','LineWidth',5)
% whitebg(1,[0.9 0.9 0.9])
fontsize=28;
 set(gca,'LineWidth',3,'fontsize',fontsize-5,'FontName', 'Arial');
  title('Target offset from fixation center (deg)','interpreter','none','FontSize',25)

 
eye_fixation_x=zeros(12,1);     eye_fixation_y=repmat(eye_fixation_y,12,1);
hnd_fixation_x=zeros(12,1);     hnd_fixation_y=eye_fixation_y-eye_hnd_offset;
n_value=(1:12)';

xlim([-45 45])
ylim([-30 30])

new_coordinates=...
    round([n_value eye_fixation_x+x_offset eye_fixation_y [[x_1([1;2;end])+x_offset,y_1([1;2;end]),x_2([1;2;end])+x_offset,y_2([1;2;end]);-x_1([1;2;end])+x_offset,y_1([1;2;end]),-x_2([1;2;end])+x_offset,y_2([1;2;end])];...
    [x_1_far([1;2;end])+x_offset,y_1_far([1;2;end]),x_2_far([1;2;end])+x_offset,y_2_far([1;2;end]); -x_1_far([1;2;end])+x_offset,y_1_far([1;2;end]),-x_2_far([1;2;end])+x_offset,y_2_far([1;2;end])]]...
    hnd_fixation_x+x_offset, hnd_fixation_y, [[x_1([1;2;end])+x_offset,y_1([1;2;end])-eye_hnd_offset,x_2([1;2;end])+x_offset,y_2([1;2;end])-eye_hnd_offset;...
    -x_1([1;2;end])+x_offset,y_1([1;2;end])-eye_hnd_offset,-x_2([1;2;end])+x_offset,y_2([1;2;end])-eye_hnd_offset];...
    [x_1_far([1;2;end])+x_offset,y_1_far([1;2;end])-eye_hnd_offset,x_2_far([1;2;end])+x_offset,y_2_far([1;2;end])-eye_hnd_offset;...
    -x_1_far([1;2;end])+x_offset,y_1_far([1;2;end])-eye_hnd_offset,-x_2_far([1;2;end])+x_offset,y_2_far([1;2;end])-eye_hnd_offset]]]*100)/100;

