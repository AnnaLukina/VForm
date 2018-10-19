%% no tricks, just running PSO for numlevels times with 300 particles
function [px,py,pvx,pvy,mc_fit,reason,aheads,resA,resL,PSOInc, psoParticles] = unfolding_PSO()
    global x y vx vy ahead Numb
    rng(1);
    Numb = 7; % number of birds in a flock
    steps = 1; 
    init_box = 3; % bounds for initial configuration
    dmin = 1; % allowed minimum distance between the birds
    [x,y,vx,vy] = flock(0,Numb,steps,init_box,dmin); %initialize the flock
    % K = 1; % steps until the next level
    stop = 0.001; % stopping criterion
    numPart = 1; % number of simulations
    numLevels = 20; % total number of levels
    maxAhead = 5; % number of maximum lookaheads before we resample if we couldnt find a new  level
    fixedPSOParticles = false;
    currentPSOParticles = 300;
    
    startPSOParticles = 10;
    endPSOParticles = 40;
    incrementPSOParticles = 5;
    PSOInc = 0;
    
    
    reason = '';
    fit_level = zeros(numPart,1); % fitness levels for each particle
    level_dist = zeros(numPart,1); % distance between the levels
    mc_fit = zeros(numPart,numLevels);
    aheads = zeros(0,0);
    psoParticles = zeros(0,0);
    px = cell(numPart,1);
    py = cell(numPart,1);
    pvx = cell(numPart,1);
    pvy = cell(numPart,1);
    bestVAX = zeros(0,0);
    bestVAY = zeros(0,0);
    sorting_indices = zeros(0,0);
    resA = 0;
    resL = 0;
    improved = zeros(numPart,1);
    precision = .5;%1/numPart;%.5;
    best_fit = Inf; % best fit among all the particles
    for p=1:numPart
        px{p} = x;
        py{p} = y;
        pvx{p} = vx;
        pvy{p} = vy;
        level_dist(p) = Inf;
        fit_level(p) = best_fit;
        mc_fit(p) = fit_level(p);
    end
    level = 1;
    clock = 0;
    ahead = 1;

    if(~fixedPSOParticles)
        currentPSOParticles = startPSOParticles;
    end
    
    success = zeros(0,0);
    for k=1:1000
        rng(1);
        fit_level = Inf;
        level_dist = Inf;
        best_fit = Inf;
        level = 1;
        [x,y,vx,vy] = flock(0,Numb,steps,init_box,dmin); %initialize the flock
        rng('shuffle');
        tic
        while best_fit>stop && level<numLevels
            [fit_level(level),level_dist] = fly_flock(best_fit,level_dist,currentPSOParticles,level);
                best_fit = fit_level(level);
                level = level+1;
        end
        toc
        success(k) = best_fit
%         hold on
%         plot(1:length(fit_level),fit_level)
%         hold off
    end
    figure
    hist(success,100)
end