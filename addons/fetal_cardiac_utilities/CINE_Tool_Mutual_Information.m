function RTMI = CINE_Tool_Mutual_Information(RT)
RTMI=zeros(size(RT,3),size(RT,4),'single');
for iSlice=1:size(RT,4)
    X=10*permute(INorm(double(RT(:,:,:,iSlice))),[3,1,2]);X=X(:,:);
    [Y,Z]=meshgrid(1:size(RT,3),1:size(RT,3));
    IND=find(triu(Y,1)>0);
    IND=[Y(IND),Z(IND)];
    mm=zeros(length(IND),1);
    for i=1:length(IND)
        mm(i,1) = mymutualinfo(X,IND(i,:));
    end
    MM=zeros(size(X,1),size(X,1));
    IND=find(triu(Y,1)>0);
    for i=1:length(IND)
        MM(IND(i))=mm(i);
    end
    
    MM=mean(MM+MM');
    RTMI(:,iSlice)=MM;
end
end

function M = mymutualinfo(X,IND)
M = mutualinfo(abs(X(IND(1),:)),abs(X(IND(2),:)));
end


