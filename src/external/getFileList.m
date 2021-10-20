function list=getFileList(folder,keyword,extension);


% Function Get File List
%
%  function list=getFileList(dir,keyword,extension)
%
%  Finds the files in folder 'dir', that contain the 
%		text 'keyword' and have extension 'extension'.
%
% [Inputs]
%   folder(compulsory)- Path to the folder to be checked.
%   keyword(compulsory)- Keyword to look for. The special char '*'
%		stands for any keyword.
%   dist(compulsory)- Extension to look for, without dot. The special char '*'
%		stands for any extension.
%
% [outputs]
%   list- Cell list with all the file names. It does not include 
%
% [usages]
%
% [author]
%   Carlos Lopez-Molina (carlos.lopez@unavarra.es)


%
% 0- validation
%

assert(nargin==3,'Error at getFileList: Wrong number of parameters');
assert(isdir(folder),'Error at getFileList: The folder does not exist');

%
% 1- Preprocessing
%

if (folder(end)~='/')
	folder=strcat(folder,'/');
end

if (strcmp(keyword,'*'))
    commandString=sprintf('%s%s.%s',folder,keyword,extension);
else
    commandString=sprintf('%s/*%s*.%s',folder,keyword,extension);
end

%
% 2- Processing
%

initialList = dir(commandString);

j=1;
if (isempty(initialList))
	list={};
else

	for i=1:length(initialList)
		if (initialList(i).isdir==0)
			list(j) = cellstr(initialList(i).name); %#ok<AGROW>
			j=j+1;
		end
	end
end























