% Computes the minimum distance between two line segments.

function [distance] = Dist(x1,x2,y1,y2,vx1,vx2,vy1,vy2)

    dvx = vx1 - vx2;
    dvy = vy1 - vy2;
    dv2 = dot([dvx dvy],[dvx dvy]);
    
    cpatime = 0;
    if (dv2 > 1e-8)
        wx = x1 - x2;
        wy = y1 - y2;
        cpatime = -dot([wx wy],[dvx dvy])./dv2;
    end
    
    if (cpatime<0 || cpatime>1)
        distance = Inf;
    else
        distance = norm(x1-x2+cpatime*(vx1-vx2),y1-y2+cpatime*(vy1-vy2));
    end
end