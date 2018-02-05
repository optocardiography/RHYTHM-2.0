%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%CHECKPOLY Polygon check.
%   PCCW = CHECKPOLY(P) checks, if the polygon specified
%   by the n-by-2 matrix P is convex. 
%
%   If P is a convex polygon, the vertices are sorted in 
%   counterclockwise order and returned in PCCW.
%
%   If P is not convex, an empty matrix is returned.
%

function pccw = checkpoly(p)
pccw = []; 
n=length(p);

k = convhull(p(:,1),p(:,2));
if length(k) ~= n+1
    return
else
    pccw = p(k(2:end),:);
end
