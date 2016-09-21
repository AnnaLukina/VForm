%% init
function[x,y,vx,vy] = flock(loading,num,steps,init_box,dmin)
rng('shuffle');
if ~loading
    x = zeros(steps,num);
    y = zeros(steps,num);
    vx = zeros(steps,num);
    vy = zeros(steps,num);
    while 1
        collision = 0;
        x(1,:)= init_box*(rand(1,num));
        y(1,:)= init_box*(rand(1,num));
        vx(1,:)= rand(1,num)*0.5+0.25;
        vy(1,:)= rand(1,num)*0.5+0.25;
%         x(2,:) = x(1,:) + vx(1,:);
%         y(2,:) = y(1,:) + vy(1,:);
        for bi=1:num
            for bj=bi+1:num
                if (Dist(x(1,bi),x(1,bj),y(1,bi),y(1,bj),...
                        vx(1,bi),vx(1,bj),vy(1,bi),vy(1,bj)) < dmin)
                    collision = 1;
                end
            end
        end
        if ~collision 
            break; 
        end
    end
end
end