%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Reconstruct the calibration points from camera model
% using calibration parameters. Uses heikkila1 notation 
% to compute pc=Rc*pw+tc
%
% [Xi,Yi]=pred(xyz,par,pos,camera);
%   camera text descriptor of camera used in configc.m. If
%   unset then assumes 'watec_and_snappy'.
%
% see heikkila1
%
% 2002, MWKay
%% Code
function [Xi,Yi]=pred(xyz,par,pos,camera)
if nargin==3,  camera='watec_and_snappy'; end;

% Get camera parameters
sys=configc(camera);
Nx=sys(1);
Ny=sys(2); 
Sx=sys(3);
Sy=sys(4);

% First reconstruct rotation matrix Rc from camera 
% rotation angles omega, psi, and kappa
wa=pos(4)*pi/180;  % omega 
pa=pos(5)*pi/180;  % psi   
ra=pos(6)*pi/180;  % kappa 
cw=cos(wa); sw=sin(wa);
cp=cos(pa); sp=sin(pa);
cr=cos(ra); sr=sin(ra);
Rc=zeros(3,3);

Rc(:,1)=[cr*cp -sr*cw+cr*sp*sw sr*sw+cr*sp*cw]'; 
Rc(:,2)=[sr*cp cr*cw+sr*sp*sw -cr*sw+sr*sp*cw]';
Rc(:,3)=[-sp cp*sw cp*cw]';

% Next transform from world (calibration) coordinate frame to camera frame
pw=xyz;   % mm, referenced to axis of rotation
tc=pos(1:3);
[nr,~]=size(pw);
pc = zeros(size(pw,1),size(Rc,1));
for i=1:nr
  pc(i,:)=(Rc'*pw(i,:)'+tc)';
end

% Now perform an 'ideal' perspective projection onto the image plane
f=par(2);
xp=f.*pc(:,1)./pc(:,3);
yp=f.*pc(:,2)./pc(:,3);

% Apply the scaling factor to find the pixel locations
sfact=par(1);
cx=par(3);
cy=par(4);
Xp=Nx.*(sfact.*xp)./Sx+cx;  % ideal pixels
Yp=Ny.*(yp)./Sy+cy;         % ideal pixels

% Now properly impose lens distortion  10/11/04
XiYi=imdist(camera,par,[Xp Yp]); % from Heikkila toolbox
Xi=XiYi(:,1);
Yi=XiYi(:,2);



% 10/11/04 Everything below is wrong, wrong, wrong!!

%rp=sqrt(xp.^2+yp.^2);

%% Now apply lens distortion even though it is very small for our camera
%% see heikkila1
%K1=-par(5)  % Radial distortion coef 1
%K2=-par(6)  % Radial distortion coef 2
%P1=-par(7)  % Tangential distortion coef 1
%P2=-par(8)  % Tangential distortion coef 2
%xxp=xp.*(1+K1.*(rp.^2)+K2.*(rp.^4)) + 2.*P1.*xp.*yp + P2.*(rp.^2+2.*(xp.^2));
%yyp=yp.*(1+K1.*(rp.^2)+K2.*(rp.^4)) + P1.*(rp.^2+2.*(yp.^2)) + 2.*P2.*xp.*yp;

%sfact=par(1);
%cx=par(3);
%cy=par(4);
%Xi=Nx.*(sfact.*xxp)./Sx+cx;   % Correct for lens distortion
%Yi=Ny.*(yyp)./Sy+cy;          % Correct for lens distortion
%%Xi=Nx.*(sfact.*xp)./Sx+cx;     % Do not correct for lens distortion 
%%Yi=Ny.*(yp)./Sy+cy;            % Do not correct for lens distortion 


