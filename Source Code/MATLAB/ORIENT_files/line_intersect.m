%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%LINE_INTERSECT Line intersection.
%   p_i = LINE_INTERSECT(A,B,C,D) returns the coordinates of the 
%   point of intersection of two lines. The lines are determined by
%   their endpoint coordinates [A,B] and [C,D] respectively.
%
%   If the lines [A,B] and [C,D] do not intersect, an empty vector
%   is returned.
%

function p_i = line_intersect(a,b,c,d)
p_i = [];

D = a(1)*(d(2)-c(2))+b(1)*(c(2)-d(2))+d(1)*(b(2)-a(2))+c(1)*(a(2)-b(2));

if D == 0
    A = [b-a,0];
    B = [c-a,0];
    cr = cross(A,B);
    if cr(3) ~= 0
        return;
    else
        if a(1)~=b(1) 
            lam = (c(1)-a(1))/(b(1)-a(1));
            mu  = (d(1)-a(1))/(b(1)-a(1));
        else
            lam = (c(2)-a(2))/(b(2)-a(2));
            mu  = (d(2)-a(2))/(b(2)-a(2));
        end
        if ( lam >= 0 & lam <= 1 & mu >= 0 & mu <= 1 )
            p_i = [c;d];
        else
            if ( (lam<0 & mu>1) | (lam>1 & mu<0) )
                p_i = [a;b];
            else
                if ( lam < 0 & mu >= 0 & mu <= 1 )
                    p_i = [a;d];
                else
                    if ( mu < 0 & lam >= 0 & lam <= 1 )
                        p_i = [a;c];
                    else
                        if ( lam >= 0 & lam <=1 & mu >1 )
                            p_i = [c;b];
                        else
                            if ( mu >= 0 & mu <= 1 & lam >1 )
                                p_i = [d;b];
                            end
                        end
                    end
                end
            end
        end
    end
else
    s = (a(1)*(d(2)-c(2))+c(1)*(a(2)-d(2))+d(1)*(c(2)-a(2)))/D;
    t = -(a(1)*(c(2)-b(2))+b(1)*(a(2)-c(2))+c(1)*(b(2)-a(2)))/D;
    if (s>=0 & s<=1 & t>=0 & t<=1)
        p_i = [a(1)+s*(b(1)-a(1)),a(2)+s*(b(2)-a(2))];
    end
end
