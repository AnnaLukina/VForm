%% flying the flock
    function [last_fit,level_dist,improved] = fly_flock(best_fit,level_dist)
global x y vx vy Numb
nvars = Numb*2;
last_fit = best_fit;
improved = 0;

options = optimoptions('particleswarm','SwarmSize', 20,'UseParallel',false,'display','none');

%for t=1:K
%     disp_flock(x(t,:),y(t,:),vx(t,:),vy(t,:));
    % bounding box
    mag = sqrt(vx.^2 + vy.^2);
    %lower bound & upper bound
    LB = zeros(1,nvars);
    UB = zeros(1,nvars);
    UB(1:Numb) = mag;
    UB(Numb+1:nvars) = 2*pi;
%     fitness = new_fit_old(va);
    % check bounds
    % newVX(newX<LB(1:n)) = 0;
    % newVY(newY<LB(n+1:nvars)) = 0;
    % newVX(newX>UB(1:n)) = 0;
    % newVY(newY>UB(n+1:nvars)) = 0;
    % newX(newX<LB(1:n)) = LB(newX<LB(1:n));
    % newY(newY<LB(n+1:nvars)) = LB(newY<LB(n+1:nvars));
    % newX(newX>UB(1:n)) = UB(newX>UB(1:n));
    % newY(newY>UB(n+1:nvars)) = UB(newY>UB(n+1:nvars));
    
    % run PSO
    [va, fitness] = particleswarm(@fit_wrapper, nvars, LB, UB, options);
    ax = va(1:Numb).*cos(va(Numb+1:nvars));
    ay = va(1:Numb).*sin(va(Numb+1:nvars));
    [r_vax, r_vay] = trim(ax, ay, mag);
    % update positions and velocities
    vx = vx + r_vax;
    vy = vy + r_vay;
    x = x + vx;
    y = y + vy;
    % check if the next level is reached
    %if t>1 
        % define fixed levels based on fitness
        if level_dist==Inf && fitness~=Inf
            level_dist = fitness/100;
        end
        % store last fitness obtained
%         if fitness(t)<last_fit
%             last_fit = fitness(t);
%         end
        if last_fit==inf
            last_fit = fitness;
        else
        % check if the next level is reached
            if last_fit~=Inf && (last_fit-fitness>=level_dist)
                last_fit = fitness;
                level_dist = level_dist/10;
                improved = 1;
%                 break;
            end
        end
    %end
% end
end

%% trimming tails outside the bounds
function [newX,newY] = trim(x, y, max)
newX = zeros(size(x));
newY = zeros(size(y));
for i=1:size(x,2)
    if norm([x(i) y(i)]) <= max(i)
        newX(i) = x(i);
        newY(i) = y(i);
    else
        %disp('trim');
        theta = atan2(y(i),x(i));
        newX(i) = max(i)*cos(theta);
        newY(i) = max(i)*sin(theta);
    end
end
end
