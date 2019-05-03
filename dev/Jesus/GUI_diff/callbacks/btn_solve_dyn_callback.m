function btn_solve_dyn_callback(obj,eve,h)
%BTN_SOLVE_DYN_CALLBACK Summary of this function goes here
%   Detailed explanation goes here

Y0 = h.InitialCondition;
idyn = h.dynamics;
Nx = h.grid.Nx;
Ny = h.grid.Ny;
Sources = h.Sources;
xmin = h.grid.xmin;
xmax = h.grid.xmax;
ymin = h.grid.ymin;
ymax = h.grid.ymax;
xms = h.grid.xms;
yms = h.grid.yms;
kmax = h.kmax;

Y0ms = reshape(Y0,Nx*Ny,1); 
idyn.InitialCondition = Y0ms;

[~ ,Y] = solve(idyn);

h.StateVectorSolution = Y;

%%


hold(h.axes.EvolutionGraphs,'on')
line([Sources.x0],[Sources.y0],'Marker','.','LineStyle','none','MarkerSize',8,'Color','k','Parent',h.axes.EvolutionGraphs)
line([Sources.x0],[Sources.y0],'Marker','o','LineStyle','none','MarkerSize',10,'Color','k','Parent',h.axes.EvolutionGraphs)

Ysh = reshape(Y(1,:)',Nx,Ny);

xline_100 = linspace(xmin,xmax,100);
yline_100 = linspace(ymin,ymax,100);

[xms_100 ,yms_100] = meshgrid(xline_100,yline_100);
Ysh_100 = griddata(xms,yms,Ysh,xms_100,yms_100);


delete(h.axes.EvolutionGraphs.Children)
isurf = surf(xms_100,yms_100,Ysh_100,'Parent',h.axes.EvolutionGraphs);

u = xms;
v = yms;
%quiver(h.axes.EvolutionGraphs,xms,yms,u,v)

shading interp;colormap jet
caxis(h.axes.EvolutionGraphs,[0 50])
view(h.axes.EvolutionGraphs , 0,-90)
colorbar(h.axes.EvolutionGraphs)
axis('off')
shading(h.axes.EvolutionGraphs,'interp')
colormap(h.axes.EvolutionGraphs,'jet')
%%
pause(0.5)    

for it = 2:length(idyn.tspan)
    Ysh = reshape(Y(it,:)',Nx,Ny);
    Ysh_100 = griddata(xms,yms,Ysh,xms_100,yms_100);
    isurf.ZData =  Ysh_100;
    isurf.Parent.Title.String = "t = " + idyn.tspan(it) ;
    pause(0.01)
end


end

