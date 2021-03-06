%% importance splitting
function [px,py,pvx,pvy,mc_fit,reason,aheads,resA,resL,PSOInc, psoParticles] = smc_for_flocking()
    global x y vx vy ahead Numb r_vax r_vay
    rng('shuffle');
    Numb = 7; % number of birds in a flock
    steps = 1; 
    init_box = 3; % bounds for initial configuration
    dmin = 1; % allowed minimum distance between the birds
    [x,y,vx,vy] = flock(0,Numb,steps,init_box,dmin); %initialize the flock
    % K = 1; % steps until the next level
    stop = 0.0001; % stopping criterion
    numPart = 20; % number of simulations
    numLevels = 20; % total number of levels
    maxAhead = 5; % number of maximum lookaheads before we resample if we couldnt find a new  level
    rng('shuffle');
    fixedPSOParticles = false;
    currentPSOParticles = 20;
    
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
    
    tic
    while best_fit>stop && level<numLevels && ahead<numLevels
        for p=1:numPart
    %         ind = find(px{p}==0,1)-1
            x = px{p}(end,:);
            y = py{p}(end,:);
            vx = pvx{p}(end,:);
            vy = pvy{p}(end,:);
            [fit_level(p),level_dist(p),improved(p)] = fly_flock(fit_level(p),level_dist(p)...
                ,currentPSOParticles,level,numLevels);
            if level==1 || improved(p)       
                px{p} = [px{p}; x];
                py{p} = [py{p}; y];
                pvx{p} = [pvx{p}; vx];
                pvy{p} = [pvy{p}; vy];
                if fit_level(p) < best_fit
                    bestVAX(level,:) = r_vax;
                    bestVAY(level,:) = r_vay;
                end
            end
        end
        if min(fit_level)<best_fit
            aheads(level) = ahead;
            psoParticles(level) = currentPSOParticles;
            if(~fixedPSOParticles)
                currentPSOParticles = startPSOParticles; %we could learn which ones are beneficial and stick to those! or at least skip low level non-beneficial ones...
            end
            
            if ahead>1 
                ahead = 1; %ahead = ahead - 1; 
            end
            best_fit = min(fit_level);
            mc_fit(:,level) = fit_level;
            clock(level) = clock(end)+toc;
    %       waitforbuttonpress; 
            level = level+1;
            % resample bad particles from top positions
            [sort_fit,sort_ind]= sort(fit_level,'ascend');
            sorting_indices = [sorting_indices sort_ind];
            L=numPart*precision;
            top_pos = sort_ind(1:L);
            bad_pos = sort_ind(L+1:numPart);
            resL = resL + 1;
            
            for r=1:numPart-L
                % sample from top positionsm
                pos = randi(length(top_pos));
                % assign a random top position to a bad one
                px{bad_pos(r)} = [px{bad_pos(r)}; px{top_pos(pos)}(end,:)];
                py{bad_pos(r)} = [py{bad_pos(r)}; py{top_pos(pos)}(end,:)];
                pvx{bad_pos(r)} = [pvx{bad_pos(r)}; pvx{top_pos(pos)}(end,:)];
                pvy{bad_pos(r)} = [pvy{bad_pos(r)}; pvy{top_pos(pos)}(end,:)];
                level_dist(bad_pos(r)) = level_dist(top_pos(pos));
                fit_level(bad_pos(r)) = fit_level(top_pos(pos));
            end
%             tic
        else
            if ahead < maxAhead 
                ahead = ahead + 1
            else %we reached max aheed
%                 if (sum(improved) >= numPart*.2) % some configs have improved and we resample
%                     'resampling'
%                     resA = resA + 1;
%                     ahead = 1;
%                     % resample bad particles from top positions
%                     [sort_fit,sort_ind]= sort(fit_level,'ascend');
%                     L=numPart*precision; % number of configurations we keep = configurations that improved
%                     top_pos = sort_ind(1:L);
%                     bad_pos = sort_ind(L+1:numPart);
% 
%                     for r=1:numPart-L
%                         % sample from top positionsm
%                         pos = randi(length(top_pos));
%                         % assign a random top position to a bad one
%                         px{bad_pos(r)} = [px{bad_pos(r)}; px{top_pos(pos)}(end,:)];
%                         py{bad_pos(r)} = [py{bad_pos(r)}; py{top_pos(pos)}(end,:)];
%                         pvx{bad_pos(r)} = [pvx{bad_pos(r)}; pvx{top_pos(pos)}(end,:)];
%                         pvy{bad_pos(r)} = [pvy{bad_pos(r)}; pvy{top_pos(pos)}(end,:)];
%                         level_dist(bad_pos(r)) = level_dist(top_pos(pos));
%                         fit_level(bad_pos(r)) = fit_level(top_pos(pos));
%                     end
%                 else %not enough have improved. what now?
                    disp('no improvement');
                    
                    if(fixedPSOParticles)
                        break;
                    else
                        disp('pso increase and startover');
                        if(currentPSOParticles < endPSOParticles)
                            ahead = 1;
                            currentPSOParticles = currentPSOParticles + incrementPSOParticles;
                            PSOInc = PSOInc + 1;
                        else
                            disp('ALL PSO EXHAUSTED improvement');
                        end
                        %load last good level!
                    end
                    
%                 end
            end
        end
    end
    
    if(best_fit<stop)
        reason = 'best';
    else
        if(level>=numLevels)
            reason = 'level';
        else
            if(ahead>=numLevels)
                reason = 'ahead';
            else
                if(currentPSOParticles >= endPSOParticles)
                    reason = 'pso exhausted'
                else
                    reason = 'no improv';
                end
            end
        end
    end
    toc
    best_fit
end