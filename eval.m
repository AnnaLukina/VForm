allfields = fieldnames(s);

allsteps = zeros(0,0);
allLowest = zeros(0,0);
% numPart = 10;
% numLevels = 20; %each step is level?

aheads = zeros(0,0);
reasons = zeros(0,0);

for i = 1:numel(allfields)
    px = s.(char(allfields(i))){1};
    py = s.(char(allfields(i))){2};
    pvx = s.(char(allfields(i))){3};
    pvy = s.(char(allfields(i))){4};
    fit = s.(char(allfields(i))){5}; %=mc_fit
    r = s.(char(allfields(i))){6};
    a = s.(char(allfields(i))){7};
    
    %aheads = [aheads; a];
    if(numel(r) > 1)
        reasons = [reasons; r(1)];
    else
        
        reasons = [reasons; 'o'];
    end
    
    steps = numel(fit(1,:))-sum(all(fit==0,1));
    fit(:,all(fit==0,1))=[];
    lowest = min(fit(:,numel(fit(1,:))));
    allsteps = [allsteps; steps];
    allLowest = [allLowest; lowest];
    
    
    
    
    getIndex = find(fit(:,end)==lowest);
    
    figure
    disp_flock(px{getIndex}(end,:),py{getIndex}(end,:),pvx{getIndex}(end,:),pvy{getIndex}(end,:));
    
    numberOfPos = sum(all(allLowest<0.009,2))
    
%     for level = 1:numeLevels
%         % fig1 = figure('position',[100 100 850 800]);
%         set(fig1,'NextPlot','replacechildren');
%         subplot(2,1,1,'replace');
%         disp_flock(px(end,:),py(end,:),pvx(end,:),pvy(end,:));
%         M(1)=getframe(fig1);
% 
%         % vizualization of the fitness levels
%         subplot(2,1,2,'replace')
%         hold on
%         lv = 1:level;
%         pv = 1:numPart;
%         [lvx,lvy] = meshgrid(lv,pv);
%         plot(lvx',fit(:,1:level)','k')
%         xlabel('Level in minutess')
%         ylabel('Fitness value')
%         ax = gca; % current axes
%         ax.XTick = 1:level;
%         ax.XTickLabel = strread(num2str(round(clock/60,1)),'%s');
%         ax.XGrid = 'on';
%         ax.Layer = 'top';
%         hold off
% 
%     %   plot the best configuration
%         f = find(px{top_pos(1)}==0,1)-1;
%         subplot(2,1,1,'replace') %fig1 = figure(level);
%         disp_flock(px{top_pos(1)}(end,:),py{top_pos(1)}(end,:),pvx{top_pos(1)}(end,:),pvy{top_pos(1)}(end,:));
%         M(level)=getframe(fig1);
% 
%         %making a movie
%         [h,w] = size(M(2).cdata);
%         hf = fig1;
%         moviename = ['smc_pso_flock_' i];
%         set(hf,'position',[100 100 w h]);
%         axis off
%         writerObj = VideoWriter(moviename);
%         writerObj.FrameRate = 50;
%         open(writerObj);
%         writeVideo(writerObj,M);
%         close(writerObj);
%         implay([moviename '.avi'])
%     end
end
