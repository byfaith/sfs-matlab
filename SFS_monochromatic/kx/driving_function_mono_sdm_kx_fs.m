function D = driving_function_mono_sdm_kx_fs(kx,xs,f,conf)
%DRIVING_FUNCTION_MONO_SDM_KX_FS returns the driving signal D for a focused source in
%SDM in the kx domain
%
%   Usage: D = driving_function_mono_sdm_kx_fs(kx,xs,f,[conf])
%
%   Input parameters:
%       kx          - kx dimension [nx1]
%       nk          - position of focused source / m [1x3]
%       f           - frequency of the monochromatic source / Hz
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   DRIVING_FUNCTION_MONO_SDM_KX_FS(kx,xs,f,conf) returns SDM driving signals
%   for the given secondary sources, the focused source direction and the
%   frequency f. The driving signal is calculated in the kx domain.
%
%   References:
%       S. Spors and J. Ahrens (2010) - "Reproduction of Focused Sources by the
%       Spectral Division Method", ISCCSP
%
%   See also: driving_function_mono_wfs, driving_function_imp_wfs_ps

%*****************************************************************************
% Copyright (c) 2010-2015 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2015 Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
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
% http://github.com/sfstoolbox/sfs                      sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input  parameters ==================================
nargmin = 3;
nargmax = 4;
narginchk(nargmin,nargmax);
isargmatrix(kx,xs);
isargpositivescalar(f);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end


%% ===== Configuration ==================================================
xref = conf.xref;
c = conf.c;
dimension = conf.dimension;
driving_functions = conf.driving_functions;
x0 = conf.secondary_sources.center;
withev = conf.sdm.withev;


%% ===== Computation ====================================================
% Calculate the driving function in time-frequency domain

% Frequency
omega = 2*pi*f;
% Indexes for evanescent contributions and propagating part of the wave field
idxpr = (( abs(kx) <= (omega/c) ));
idxev = (( abs(kx) > (omega/c) ));
D = zeros(1,length(kx));

if strcmp('2D',dimension)

    % === 2-Dimensional ==================================================

    % Ensure 2D
    xs = xs(:,1:2);
    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        to_be_implemented;
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2D focused source.'],upper(mfilename),driving_functions);
    end


elseif strcmp('2.5D',dimension)

    % === 2.5-Dimensional ================================================

    % Reference point
    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % D_25D(kx,w) = e^(i kx xs) ...
        %                                   ____________
        %                         H0^(2)( \|(w/c)^2-kx^2 |yref-ys| )
        %                     / - --------------_-_-_-_-_-_---------, |kx|<|w/c|
        %                     |      H0^(2)( \|(w/c)^2-kx^2 yref )
        %                    <        ____________
        %                     | K0( \|kx^2-(w/c)^2 |yref-ys| )
        %                     \ ----------_-_-_-_-_-_---------,       |kx|>|w/c|
        %                          K0( \|kx^2-(w/c)^2 yref )
        %
        % see Spors and Ahrens (2010), (7)
        %
        D(idxpr) =  exp(1i*kx(idxpr)*xs(1)) .* ...
            besselh(0,2,sqrt( (omega/c)^2 - kx(idxpr).^2 )*abs(xref(2)-xs(2))) ./ ...
            besselh(0,2,sqrt( (omega/c)^2 - kx(idxpr).^2 )*abs(xref(2)-x0(2)));
        if(withev)
            D(idxev) =  exp(1i*kx(idxev)*xs(1)) .* ...
                besselk(0,sqrt(kx(idxev).^2 - (omega/c).^2)*abs(xref(2)-xs(2))) ./ ...
                besselk(0,sqrt(kx(idxev).^2 - (omega/c).^2)*abs(xref(2)-x0(2)));
        end

    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2.5D focused source.'],upper(mfilename),driving_functions);
    end


elseif strcmp('3D',dimension)

    % === 3-Dimensional ==================================================

    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        to_be_implemented;
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 3D focused source.'],upper(mfilename),driving_functions);
    end

else
    error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end