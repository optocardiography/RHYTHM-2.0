function [filtdata,kernel]=conefilt(data,width,slope)
% assumes sites of no data have NaN's

  kernel=zeros(width,width);
  for i=0:width-1;
    for j=0:width-1;
      kernel(i+1,j+1)=floor((width-1)*slope/2+1-slope*sqrt((i-(width-1)/2)^2+(j-(width-1)/2)^2));
      if kernel(i+1,j+1)<0, kernel(i+1,j+1)=0; end;
    end
  end
  kernel=kernel.*(1/sum(sum(kernel)));

  filtdata=data;
  for i=1:size(data,3)
    filtdata(:,:,i)=conv2(data(:,:,i),kernel,'same');
  end
  
