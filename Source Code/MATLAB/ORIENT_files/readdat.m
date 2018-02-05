%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
%
% ie: [data,numparams,txtparams]=readdat('ball_3mm_pts.dat');
%
% Read *.dat files exported from vtk. Headers are expected.
% 
% MWKay, 2002
%

function [data,numparams,txtparams]=readdat(fname)
fid=fopen(fname,'r','n');
l=lower(fgets(fid));
hlinesi=findstr('header lines:',l)+length('header lines:');
hlines=str2num(l(hlinesi:end));

for i=2:hlines
  l=lower(fgets(fid));
  if findstr('source',l) 
    ii=findstr('source file:',l)+length('source file:')+1;
    sourcefilename=l(ii:end-1);
  elseif findstr('numberoftuples',l) 
    ii=findstr('numberoftuples:',l)+length('numberoftuples:');
    NumberOfTuples=str2num(l(ii:end));
  elseif findstr('numberofcomponents',l) 
    ii=findstr('numberofcomponents:',l)+length('numberofcomponents:');
    NumberOfComponents=str2num(l(ii:end));
  elseif findstr('created',l) 
    ii=findstr('created:',l)+length('created:')+1;
    created=l(ii:end-1);
  elseif findstr('datatype',l) 
    ii=findstr('datatype:',l)+length('datatype:')+1;
    datatype=strtrim(l(ii:end-1));
  end
end
datatype = strcat('',datatype);
dat=fread(fid,NumberOfTuples*NumberOfComponents,datatype);
fclose(fid);
if NumberOfComponents>1
  data=reshape(dat',NumberOfComponents,NumberOfTuples)';
elseif NumberOfComponents==1
  data=dat;
end
numparams=[NumberOfTuples NumberOfComponents];
txtparams={sourcefilename created datatype};


