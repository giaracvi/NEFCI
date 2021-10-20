function featIm = FuzzyMorph(im,C,Imp,TS)
%Input:
%im: original image;
%C: conjuctor: 'T_LK'% for Dilatation
%Imp: implication 'I_KD' for Erosion
%TS: B: min y max, SS: Schweizer-Sklar,PP:product and probabilistic sum

[fil,col]=size(im);

Dil=zeros(fil,col);
Ero=zeros(fil,col);

for i=1:fil
   for j=1:col
      matriz=im(max(i-1,1):min(i+1,fil),max(j-1,1):min(j+1,col));
      matriz=matriz(:)';
%Different structuring elements
      se=[0.8600    0.8600    0.8600    0.8600    1.0000    0.8600    0.8600    0.8600    0.8600];
      if i==1
          if j==1
          se=[1 0.86 0.86  0.86];
          elseif j==col
              se=[0.86  0.86  1  0.86];
          elseif j~=1 && j~=col
              se=[0.86   0.86  1  0.86  0.86   0.86];
          end
      elseif i==fil
          if j==1
              se=[0.86 1 0.86 0.86];
          elseif j==col
              se=[0.86  0.86   0.86 1];
          elseif j~=1 && j~=col
              se=[0.86  0.86 0.86 1 0.86 0.86];
          end
      end
      if i~=1 && i~=fil
          if j==1
               se=[0.86 1 0.86 0.86 0.86 0.86];
          elseif j==col
              se=[0.86 0.86 0.86 0.86 1  0.86];
          end
      end
      X=Conjuctor(matriz,se,C);
      Y=Implication(matriz,se,Imp);
      if strcmp(TS,'B')==1
      Dil(i,j) = max(X);
      Ero(i,j) = min(Y);
      elseif strcmp(TS,'SS')==1

      [fm,cm]=size(matriz);
      R=zeros(cm-1);
      R(1)=SS_S(X(1),X(2),-5);
      for z=2:cm-1
          R(z)=SS_S(X(z+1),R(z-1),-5);
      end
      Dil(i,j) = R(cm-1);
      R=zeros(cm-1);
      R(1)=SS_T(Y(1),Y(2),-5);
      for z=2:cm-1
          R(z)=SS_T(Y(z+1),R(z-1),-5);
      end
      Ero(i,j) = R(cm-1);
      elseif strcmp(TS,'PP')==1
                 Ero(i,j) = prod(Y);
                 [fm,cm]=size(matriz);
                 R=zeros(cm-1);
                 R(1)=X(1)+X(2)-X(1).*X(2);
                 for z=2:cm-1
                    R(z)=X(z+1)+R(z-1)-X(z+1).*R(z-1);
                 end
                 Dil(i,j) = R(cm-1);
      end
  end
end

featIm=Dil-Ero;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val]=Conjuctor(A,B,D)
if strcmp(D,'T_nM')==1
    val=(A+B<=1).*0+ (A+B>1).*(min(A,B));
elseif strcmp(D,'T_LK')==1
    val=max(A+B-1,0);
end

function [val]=Implication(A,B,D)
if strcmp(D,'I_KD')==1
    val=max(1-B,A);
end

function [val]=SS_T(X1,Y1,p)
    val=(max(X1^p + Y1^p - 1,0))^(1/p);

function [val]=SS_S(X1,Y1,p)
    val=1-(max(((1-X1)^p + (1-Y1)^p - 1),0))^(1/p);
