function disp_flock(x,y,vx,vy)

hold on
quiver(x,y,vx,vy,0,'LineWidth',1.5,'color',[0.85 0.88 0.59])
plot(x,y,'o','MarkerFace','r')
xlabel('x coordinate')
ylabel('y coordinate')
x_centroid = mean(x);
y_centroid = mean(y);
plot(x_centroid,y_centroid,'ok')
% centroid = regionprops(true(size([x;y])), [x;y],  'WeightedCentroid');
% plot(centroid.WeightedCentroid(1),centroid.WeightedCentroid(2),'oc')
hold off

end