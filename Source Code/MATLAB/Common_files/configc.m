%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
%CONFIGC Loads system configuration information based on given name.
%User may edit here new setup data.

function sys=configc(name)
if strcmp(name,'sony')
    sys = [
        768         %number of pixels in horizontal direction
        576         %number of pixels in vertical direction
        6.2031      %effective CCD chip size in horizontal direction
        4.6515      %effective CCD chip size in vertical direction
        8.5         %nominal focal length
        5           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'sonyz')
    sys = [
        768         %number of pixels in horizontal direction
        576         %number of pixels in vertical direction
        6.2031      %effective CCD chip size in horizontal direction
        4.6515      %effective CCD chip size in vertical direction
        8.5         %nominal focal length
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'pulnix')
    sys = [
        512         %number of pixels in horizontal direction
        512         %number of pixels in vertical direction
        4.3569      %effective CCD chip size in horizontal direction
        4.2496      %effective CCD chip size in vertical direction
        16          %nominal focal length
        15          %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'watec')
    sys = [
        768         %number of pixels in horizontal direction
        494         %number of pixels in vertical direction
        0.0084*768  %effective CCD chip size in horizontal direction (mm)
        0.0098*494  %effective CCD chip size in vertical direction (mm)
        8.5         %nominal focal length (mm) 8.5
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'watec_with_f8.5')
    sys = [
        640        %number of pixels in horizontal direction
        480        %number of pixels in vertical direction
        6.4        %effective CCD chip size in horizontal direction (mm)
        4.8        %effective CCD chip size in vertical direction (mm)
        8.5        %nominal focal length (mm)
        0          %radius of the circular control points
        0          %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'watec_with_f12.5')
    sys = [
        640        %number of pixels in horizontal direction
        480        %number of pixels in vertical direction
        6.4        %effective CCD chip size in horizontal direction (mm)
        4.8        %effective CCD chip size in vertical direction (mm)
        12.5       %nominal focal length (mm)
        0          %radius of the circular control points
        0          %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'interpolated_dalsa')
    sys = [
        509         %number of pixels in horizontal direction
        505         %number of pixels in vertical direction
        128*0.016   %effective CCD chip size in horizontal direction (mm)
        127*0.016   %effective CCD chip size in vertical direction (mm)
        3.5         %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'brainvision_high')
    sys = [
        192         %number of pixels in horizontal direction
        128         %number of pixels in vertical direction
        8.91        %effective CCD chip size in horizontal direction (mm)
        6.67        %effective CCD chip size in vertical direction (mm)
        25          %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'brainvision_low')
    sys = [
        96          %number of pixels in horizontal direction
        64          %number of pixels in vertical direction
        8.91        %effective CCD chip size in horizontal direction (mm)
        6.67        %effective CCD chip size in vertical direction (mm)
        25          %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'brainvision_ultimaL')
    sys = [
        100         %number of pixels in horizontal direction
        100         %number of pixels in vertical direction
        10          %effective CMOS chip size in horizontal direction (mm)
        10          %effective CMOS chip size in vertical direction (mm)
%         50          %nominal focal length (mm)
        35          %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'E4300')
    sys = [
        2272        %number of pixels in horizontal direction
        1704        %number of pixels in vertical direction
        7.18        %effective CCD chip size in horizontal direction (mm)
        5.32        %effective CCD chip size in vertical direction (mm)
        14.0        %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'andor_ixon_6mm')
    sys = [
        128         %number of pixels in horizontal direction
        128         %number of pixels in vertical direction
        128*0.024   %effective CCD chip size in horizontal direction (mm)
        128*0.024   %effective CCD chip size in vertical direction (mm)
        6           %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'andor_ixon_12.5mm')
    sys = [
        128         %number of pixels in horizontal direction
        128         %number of pixels in vertical direction
        128*0.024   %effective CCD chip size in horizontal direction (mm)
        128*0.024   %effective CCD chip size in vertical direction (mm)
        12.5        %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'andor_ixon_2.2mm')
    sys = [
        128         %number of pixels in horizontal direction
        128         %number of pixels in vertical direction
        128*0.024   %effective CCD chip size in horizontal direction (mm)
        128*0.024   %effective CCD chip size in vertical direction (mm)
        2.2         %nominal focal length (mm)
        0           %radius of the circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'iDS_UI_3220CP-M-GL_with_f1.2')
    sys = [
        752         %number of pixels in horizontal direction
        480         %number of pixels in vertical direction
        4.512       %effective CMOS chip size in horizontal direction (mm)
        2.880       %effective CMOS chip size in vertical direction (mm)
        6           %nominal focal length (mm)
        0           %radius of circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end

if strcmp(name,'IDS-UI-3280CP-C-HQ')
    sys = [
        2456         %number of pixels in horizontal direction
        2054         %number of pixels in vertical direction
        8.446       %effective CMOS chip size in horizontal direction (mm)
        7.066       %effective CMOS chip size in vertical direction (mm)
        5           %nominal focal length (mm)
        0           %radius of circular control points
        0           %for future expansions
        0
        0
        abs(name)'
        ];
    return;
end
    



error('Unknown camera type')
