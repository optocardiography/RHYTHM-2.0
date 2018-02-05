%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%--------------------------------------------------------
% pr_hammer function     Project coordinates using
%                     the Hammer projection
%                     for set of longitude and latitude,
%                     and project on ellipse with axis
%                     ratio of 2:1.
% Input  : - vector of Longitude, in radians.
%          - vector of Latitude, in radians.
%          - Scale radius, default is 1.
% Output : - vector of X position
%          - vector of Y position 
%   By : Eran O. Ofek          July 1999
%--------------------------------------------------------
function [X,Y]=pr_hammer(Long,Lat,R)
if (nargin==3),
   % no default
elseif (nargin==2),
   R = 1;
else
   error('Illigal number of argument');
end

X = 2.*R.*sqrt(2).*cos(Lat).*sin(Long./2)./sqrt(1+cos(Lat).*cos(Long./2));
Y = R.*sqrt(2).*sin(Lat)./sqrt(1+cos(Lat).*cos(Long./2));

end