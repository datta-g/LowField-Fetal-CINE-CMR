function Para = Double_Parameters(PreviousPara)
Para=[];
for loop=1:length(PreviousPara)
    Para=[Para,PreviousPara(loop),PreviousPara(loop)];
end
end
