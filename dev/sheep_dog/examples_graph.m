fig = figure;
ax  = axes('Parent',fig);


blue = [0 0 1];
sblue = 0.1*blue + 0.9*[1 1 1]; 

red = [1 0 0];
sred = 0.1*red + 0.9*[1 1 1]; 

%%
for k = 1:M_d
	line(ud(1,:,k),ud(2,:,k),'LineStyle','-','LineWidth',0.1,'Parent',ax,'Color',[1 1 1]);
end
for k = 1:M_e
	line(ue(1,:,k),ue(2,:,k),'LineStyle','-','LineWidth',0.1,'Parent',ax,'Color',[1 1 1]);
end


%%
for k = 1:M_d
	line_dog(k) =line(ud(1,1,k),ud(2,1,k),'LineStyle','-','LineWidth',0.1,'Parent',ax,'Color',sblue);
end
for k = 1:M_e
	line_sheep(k) = line(ue(1,1,k),ue(2,1,k),'LineStyle','-','LineWidth',0.1,'Parent',ax,'Color',sred);
end

for k = 1:M_d
	point_dog(k) = line(ud(1,1,k),ud(2,1,k),'LineStyle','none','Marker','.','MarkerSize',20,'Parent',ax,'Color',blue);
end

for k = 1:M_e
	point_sheep(k) = line(ue(1,1,k),ue(2,1,k),'LineStyle','none','Marker','.','MarkerSize',20,'Parent',ax,'Color',red);
end

legend(ax,[point_sheep(1) point_dog(1)],'Sheep','Dogs')

for it = 1:2:Nt
   
    for k = 1:M_d
        point_dog(k).XData = ud(1,it,k);
        point_dog(k).YData = ud(2,it,k);
        
        line_dog(k).XData = [ line_dog(k).XData ud(1,it,k)];
        line_dog(k).YData = [ line_dog(k).YData ud(2,it,k)];

    end

    for k = 1:M_e
        point_sheep(k).XData = ue(1,it,k);
        point_sheep(k).YData = ue(2,it,k);
        
        line_sheep(k).XData = [ line_sheep(k).XData ue(1,it,k)];
        line_sheep(k).YData = [ line_sheep(k).YData ue(2,it,k)];
        
    end
    
    pause(0.1)
end


error('s')

figure('position', [0, 0, 1000, 400]);
subplot(1,2,1)
hold on
for k = 1:M_d
	plot(ud(1,:,k),ud(2,:,k),'-','LineWidth',1.3);
end
for l = 1:M_e
	plot(ue(1,:,l),ue(2,:,l),'r-');
end
subplot(1,2,2)
plot(tline,kappa','LineWidth',1.3);

xlabel('Time')
ylabel('Control \kappa(t)')
title(['Total Time = ',num2str(tline_UO(end)),' and running cost = ',num2str(Running_cost)])
grid on


subplot(1,2,1)
j = 1;
hold on
for l = 1:M_e
	plot(ue(1,j,l),ue(2,j,l),'rs');
end
for k = 1:M_d
	plot(ud(1,j,k),ud(2,j,k),'bs');
end

subplot(1,2,1)
j = Nt+1;
hold on
for l = 1:M_e
	plot(ue(1,j,l),ue(2,j,l),'ro');
end
for k = 1:M_d
	plot(ud(1,j,k),ud(2,j,k),'bo');
end

legend('Driver1','Driver2','Evaders','Location','best')
xlabel('abscissa')
ylabel('ordinate')
%ylim([-2.5 1.5])
title(['Position error = ', num2str(Final_cost)])
grid on



%%
c = fix(clock);
c = c(1)*10^10+c(2)*10^8+c(3)*10^6+c(4)*10^4+c(5)*10^2+c(6);
ff= figure('position', [0, 0, 800, 600]);
vidObj = VideoWriter(['GBR_',num2str(c),'.avi']);
vidObj.Quality = 95;
vidObj.FrameRate = 60;
open(vidObj);

Time = 10;
iter = max(floor((Nt)/20/Time),1);
hold on
xlim([-7 7])
ylim([-7 7])
j = 1;
for k = 1:M_d
	plot(ud(1,j,k),ud(2,j,k),'bs');
end
for l = 1:M_e
	plot(ue(1,j,l),ue(2,j,l),'rs');
end
xlabel('abscissa')
ylabel('ordinate')
%ylim([-2.5 1.5])
title(['Position error = ', num2str(Final_cost)])
grid on

pause

% for j=1:floor(1/(480*h)):iter/2
 for j=[1:iter:Nt, Nt]
     %clf;
%      b = max(abs([1;u3(1:j,1);u3(1:j,2)]));
%      if (b > 1)&&(c == 1)
%          c = max(abs([1;u3(:,1);u3(:,2)]));
%      end
for l = 1:M_e
	plot(ue(1,1:j,l),ue(2,1:j,l),'r-');
end
for k = 1:M_d
	plot(ud(1,1:j,k),ud(2,1:j,k),'b-','LineWidth',1.3);
end





     
     FF=getframe(ff); 
     writeVideo(vidObj,FF);
 end
j = Nt+1;
for l = 1:M_e
	plot(ue(1,1:j,l),ue(2,1:j,l),'r-');
end
for k = 1:M_d
	plot(ud(1,1:j,k),ud(2,1:j,k),'b-','LineWidth',1.3);
end
for l = 1:M_e
	plot(ue(1,end,l),ue(2,end,l),'ro');
end 
for k = 1:M_d
	plot(ud(1,end,k),ud(2,end,k),'bo');
end

FF=getframe(ff); 
     writeVideo(vidObj,FF);
 
 
 close(vidObj);
