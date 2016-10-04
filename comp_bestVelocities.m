allfields = fieldnames(s);

aheads = zeros(0,0);
reasons = zeros(0,0);

adjustmentsX = zeros(0,0);
adjustmentsY = zeros(0,0);

for i = 1:10%numel(allfields)
    if ~strcmp(char(allfields(i)), 'totalTime')
        px = s.(char(allfields(i))){1};
        py = s.(char(allfields(i))){2};
        pvx = s.(char(allfields(i))){3};
        pvy = s.(char(allfields(i))){4};
        fit = s.(char(allfields(i))){5};
        fit(:,all(fit==0,1))=[];
        
        [M,minIndex] = min(fit,[],1);
        pvyBest = pvy(minIndex);
        pvxBest = pvx(minIndex);
        for j = 1:numel(minIndex)-1
            if j>1
                adjX = pvxBest{j}(j+1,:)-pvxBest{j}(j,:);
                adjY = pvyBest{j}(j+1,:)-pvyBest{j}(j,:);
%             else
%                 adjX = pvxBest{j}(j,:);
%                 adjY = pvyBest{j}(j,:);
            end
            adjustmentsX = [adjustmentsX; adjX];
            adjustmentsY = [adjustmentsY; adjY];
        end
        endConfX = px{1}(1,:)+ pvx{1}(1,:) + sum(adjustmentsX);
        endConfY = py{1}(1,:)+ pvy{1}(1,:) + sum(adjustmentsY);
        
        endVelX = pvx{minIndex(end)}(end,:);
        endVelY = pvy{minIndex(end)}(end,:);
        
        figure;
        disp_flock(endConfX, endConfY, endVelX, endVelY);
        title(char(allfields(i)));
        
    end
end