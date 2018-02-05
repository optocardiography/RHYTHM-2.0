%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Smooth region borders of triangular mesh data
% Algorithm does not work with NaNs.
% If NaNs exist in celldata, then the algorithm will set them to be zero.

function [smoothdata]=smoothregionbdr(celldata,numneighs,neighbors)
gg=find(isnan(celldata));
celldata(gg)=0;

pvect=zeros(size(celldata,1),2);
pvect(:,1)=celldata;
pvect(:,2)=celldata;
pkount=0;
pdiffnum=1;
while (pdiffnum>0)
  pkount=pkount+1;
  p_now=mod(pkount,2)+1;      % 2 first, then 1
  p_prev=mod(pkount+1,2)+1;
  for jj=1:size(pvect,1)
    if numneighs(jj)==3
      if (pvect(neighbors{jj}(1),p_now)-pvect(neighbors{jj}(2),p_now))==0
	pvect(jj,p_now)=pvect(neighbors{jj}(1),p_now);
      elseif (pvect(neighbors{jj}(1),p_now)-pvect(neighbors{jj}(3),p_now))==0
	pvect(jj,p_now)=pvect(neighbors{jj}(1),p_now);
      elseif (pvect(neighbors{jj}(2),p_now)-pvect(neighbors{jj}(3),p_now))==0
	pvect(jj,p_now)=pvect(neighbors{jj}(2),p_now);
      end  
    elseif numneighs(jj)==2
      if (pvect(neighbors{jj}(1),p_now)-pvect(neighbors{jj}(2),p_now))==0
        pvect(jj,p_now)=pvect(neighbors{jj}(1),p_now);
      end
    end
  end
  pdiffnum=length(find(pvect(:,1)-pvect(:,2)~=0));
  disp(sprintf('Pass %d, Reassigned %d cells',pkount,pdiffnum)); 
  pvect(:,p_prev)=pvect(:,p_now);
end
smoothdata=pvect(:,1);   % smoothed edges

