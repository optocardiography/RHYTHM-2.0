%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% ie: [data,numparams,txtparams]=readneighs('scan3_d_neighs.dat');
%
% Read *.dat file with cell neighbors, exported from vtk. Headers are expected.
% 
% MWKay, 2005
%

function [neighnum,neighs,numparams,txtparams]=readneighs(fname)
fid=fopen(fname,'r','n');
l=lower(fgets(fid));
hlinesi=findstr('header lines:',l)+length('header lines:');
hlines=str2num(l(hlinesi:end));

for i=2:hlines
  l=lower(fgets(fid));
  if findstr('source',l) 
    ii=findstr('source file:',l)+length('source file:')+1;
    sourcefilename=l(ii:end-1);
  elseif findstr('numberofcells',l) 
    ii=findstr('numberofcells:',l)+length('numberofcells:');
    NumberOfCells=str2num(l(ii:end));
  elseif findstr('created',l) 
    ii=findstr('created:',l)+length('created:')+1;
    created=l(ii:end-1);
  elseif findstr('datatype',l) 
    ii=findstr('datatype: ',l)+length('datatype: ');
    datatype=strtrim(l(ii:end-1));
  end
end

neighnum=zeros(NumberOfCells,1);
neighs=struct([]);   % create an empty structure

for i=1:NumberOfCells
  neighnum(i)=fread(fid,1,datatype);
%   disp(num2str(i))
  for j=1:neighnum(i)
    neighs{i}(j)=fread(fid,1,datatype);
  end
end
fclose(fid);

numparams=[NumberOfCells];
txtparams={sourcefilename created datatype};
