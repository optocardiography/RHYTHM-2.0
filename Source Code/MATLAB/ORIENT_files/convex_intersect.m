%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%CONVEX_INTERSECT Intersection of convex polygons.
%   [PINT,K,AINT] = CONVEX_INTERSECT(P,Q) returnes a K-by-2 matrix PINT
%   of vertices (in counterclockwise order) of the convex polygon, 
%   that represents the intersection of two convex polygons specified 
%   by the matrices P and Q respectively. 
%
%   The area AINT of the intersection polygon is also returned.
%
%   If polygons P and Q do not intersect, PINT is an empty matrix
%   and AINT = 0.
%   
%   The function is based on the algorithm of JOSEPH O'ROUKE,
%   "Computational Geometry in C", Cambridge University Press, 1996.
%

function [pint,k,Aint] = convex_intersect(p,q)
%initialization
n = length(p);
m = length(q);
at = 1; bt = 1;
aa = 0; ba = 0;
pint = []; Aint = 0;
inflag = 0;

% chasing algorithm of J.O'Rouke, Computational Geometry in C, 1996. 
while ( (aa<n || ba<m) && aa<2*n && ba<2*m )
 
    ah = mod(at,n)+1;
    bh = mod(bt,m)+1;
    A = [p(ah,:)-p(at,:),0];
    B = [q(bh,:)-q(bt,:),0];
    cr = cross(A,B); cr = cr(3);
    ahHB = cross(B,[p(ah,:)-q(bt,:),0]); ahHB = ahHB(3);
    bhHA = cross(A,[q(bh,:)-p(at,:),0]); bhHA = bhHA(3);
    
    p_i = line_intersect(p(at,:),p(ah,:),q(bt,:),q(bh,:));
    if length(p_i) > 1
        if inflag == 0
            aa = 0; ba = 0;
        end
        if bhHA > 0
            inflag = 2;
        elseif ahHB > 0 
            inflag = 1;
        elseif ( ahHB==0 && bhHA==0 && cr==0 )
           if ( sum(p(ah,:)-p_i(1,:))==0 || sum(p(ah,:)-p_i(2,:))==0 )
               inflag = 1;
           elseif ( sum(q(bh,:)-p_i(1,:))==0 || sum(q(bh,:)-p_i(2,:))==0 )
               inflag = 2;
           else 
               inflag = 3;
           end
        end
    pint = [pint;p_i];    
    end
    
    if ( (cr==0) && bhHA<0 && ahHB<0 )
        if inflag == 1
            bt = mod(bt,m)+1; ba = ba+1;
        else
            at = mod(at,n)+1; aa = aa+1;
        end
    elseif ( cr>=0 )
        if bhHA > 0
            at = mod(at,n)+1; aa = aa+1;
            if inflag == 1
                pint = [pint;p(ah,:)];
            end
        else 
            bt = mod(bt,m)+1; ba = ba+1;
            if inflag == 2
                pint = [pint;q(bh,:)];
            end
        end
    else
        if ahHB > 0
            bt = mod(bt,m)+1; ba = ba+1;
            if inflag == 2
                pint = [pint;q(bh,:)];
            end
        else
            at = mod(at,n)+1; aa = aa+1;
            if inflag == 1
                pint = [pint;p(ah,:)];
            end
        end
    end
end
    

% check special cases
if inflag == 0
    PinQ = inpolygon(p(1,1),p(1,2),q(:,1),q(:,2));
    if PinQ == 1
        pint = p; Aint = polyarea(pint(:,1),pint(:,2));
    else
        QinP = inpolygon(q(1,1),q(1,2),p(:,1),p(:,2));
        if QinP == 1
            pint = q; Aint = polyarea(pint(:,1),pint(:,2));
        end
    end
else
    pint = unique(pint,'rows');
    if length(pint)>2
        ord = convhull(pint(:,1),pint(:,2));
        pint = pint(ord(2:end),:);
        if length(pint)>2
            Aint = polyarea(pint(:,1),pint(:,2));
        end
    end
end     
k = length(pint);
