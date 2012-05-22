function [x,y,P] = wave_field_mono_nfchoa_25d(X,Y,xs,L,f,src,conf)
%WAVE_FIELD_MONO_NFCHOA_25D simulates a wave field for 2.5D NFC-HOA
%
%   Usage: [x,y,P,ls_activity] = wave_field_mono_wfs_25d(X,Y,xs,L,f,src,[conf])
%
%   Input parameters:
%       X           - [xmin,xmax]
%       Y           - [ymin,ymax]
%       xs          - position of point source (m)
%       L           - array length (m)
%       f           - monochromatic frequency (Hz)
%       src         - source type of the virtual source
%                         'pw' - plane wave (xs is the direction of the
%                                plane wave in this case)
%                         'ps' - point source
%                         'fs' - focused source
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       x           - corresponding x axis
%       y           - corresponding y axis
%       P           - Simulated wave field
%
%   WAVE_FIELD_MONO_NFCHOA_25D(X,Y,xs,L,f,src,conf) simulates a wave
%   field of the given source type (src) using a NFC-HOA 2.5 dimensional driving
%   function in the frequency domain. This means by calculating the integral for
%   P with a summation.
%   To plot the result use plot_wavefield(x,y,P).
%
%   References:
%       
%       Williams1999 - Fourier Acoustics (Academic Press)
%
%   see also: plot_wavefield

%*****************************************************************************
% Copyright (c) 2010-2012 Quality & Usability Lab                            *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://dev.qu.tu-berlin.de/projects/sfs-toolbox       sfstoolbox@gmail.com *
%*****************************************************************************

% AUTHOR: Sascha Spors
% $LastChangedDate$
% $LastChangedRevision$
% $LastChangedBy$


%% ===== Checking of input  parameters ==================================
nargmin = 6;
nargmax = 7;
error(nargchk(nargmin,nargmax,nargin));
isargvector(X,Y);
xs = position_vector(xs);
isargpositivescalar(L,f);
isargchar(src);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end


%% ===== Configuration ==================================================
% xy resolution
xysamples = conf.xysamples;
% Plotting result
useplot = conf.useplot;


%% ===== Variables ======================================================
% Getting values for x- and y-axis
x = linspace(X(1),X(2),xysamples);
y = linspace(Y(1),Y(2),xysamples);


%% ===== Computation ====================================================
% Calculate the wave field in time-frequency domain
%
% Get the position of the loudspeakers
x0 = secondary_source_positions(L,conf);
% Create a x-y-grid to avoid a loop
[xx,yy] = meshgrid(x,y);
% Initialize empty wave field
P = zeros(length(y),length(x));
% Driving function D(x0,omega)
D = driving_function_mono_nfchoa_25d(x0,xs,f,src,conf);

% Integration over secondary source positions
for ii = 1:size(x0,1)

    % ====================================================================
    % Secondary source model G(x-x0,omega)
    % This is the model for the loudspeakers we apply. We use closed cabinet
    % loudspeakers and therefore point sources.
    G = point_source(xx,yy,x0(ii,1:3),f);

    % ====================================================================
    % Integration
    %              /
    % P(x,omega) = | D(x0,omega) G(x-x0,omega) dx0
    %              /
    %
    % see: Spors2009, Williams1993 p. 36
    P = P + D(ii).*G;

end

% === Scale signal (at xref) ===
P = norm_wave_field(P,x,y,conf);


% ===== Plotting =========================================================
if(useplot)
    plot_wavefield(x,y,P,L,1,conf);
end