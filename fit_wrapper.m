%% fitness fct
function [fitness] = fit_wrapper(va)
global x y vx vy ahead Numb
fitness = new_fit(va,x,y,vx,vy,ahead,Numb);
end