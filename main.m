clear all;

numberConfs = 100;

s = struct();

total=tic;
for i = 1 : numberConfs
    indiv = tic;
    [px, py, pvx, pvy, fit,reason,aheads,resA,resL,PSOInc,psoParticles] = smc_for_flocking; %%Anna's function
    t_i = toc(indiv)
    field = strcat('run', num2str(i))
    value = {px; py; pvx; pvy; fit;reason;aheads;resA;resL;PSOInc;psoParticles;t_i};
    s.(field) = value;
end
t = toc(total)
s.('totalTime') = t;
save('100-20Par_20Lev_5ahead_ANNA_1split_001','s');
