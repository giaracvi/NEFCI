function remainingTimeName=timeToName(remaining)

nSecs=mod(remaining,60);
remaining=(remaining-nSecs)/60;
nMins=mod(remaining,60);
nHours=floor(remaining/60);


%[nHours nMins nSecs]

if (nHours>0)
    remainingTimeName=sprintf('%d:%02d:%02d h.',nHours,nMins,round(nSecs));
elseif (nMins>0)
    remainingTimeName=sprintf('%d:%02d m.',nMins,nHours);
else
    remainingTimeName=sprintf('%d s.',nMins,nHours);
end
