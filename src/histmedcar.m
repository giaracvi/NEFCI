function [H,umbrals] = histmedcar(ImGra,Bottom,Top,Step)
[n,m]=size(ImGra);
acum=zeros(n,m); 
contador=0;
for i=Bottom:Step:Top
    for j=i:Step:Top
        im1=hysthresh(ImGra,j,i);
        im2=hysthresh(ImGra,j,j);
        resta=im1-im2;
        acum=acum+resta;
        contador=contador+1;
    end
end
acum=floor(acum*255/contador);
aux3=ones(1,256);
contador=1;
for i=0:1:255
    umbra=hysthresh(acum,i,i);
    aux=sum(sum(umbra==1)); 
    aux2=sum(sum(ImGra(find(umbra==1))==i));
    if(aux==0)
        aux3(contador)=0;
    else
        aux3(contador)=aux2/aux;
    end
    contador=contador+1;
end
contador=0;
for i=2:1:255
	if (aux3(i)>0)
		if (aux3(i)>aux3(i-1) && aux3(i)>aux3(i+1))
			contador=contador+1;
			if (contador==1)
				umbrals(1)=i-1;
			else
				umbrals(2)=i-1;
			end
		end
	end
end
if (exist('unbrals'))
    if (numel(umbrals)==1)
        [H,umbrals] = histmedcar(ImGra,Bottom,Top+10,Step);
    else
        H=hysthresh(ImGra,umbrals(2),umbrals(1));
    end
else
    H=hysthresh(ImGra,56,90);
end
