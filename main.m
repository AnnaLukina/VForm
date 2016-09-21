clear all;

numberConfs = 50;

s = struct();

total=tic;
for i = 1 : numberConfs
    [px, py, pvx, pvy, fit,reason,aheads] = smc_for_flocking; %%annas function
    field = strcat('run', num2str(i))
    value = {px; py; pvx; pvy; fit;reason;aheads};
    s.(field) = value;
end
toc(total)