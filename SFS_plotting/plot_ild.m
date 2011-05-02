function plot_ild(ild,phi)
%PLOT_ILD plots the given ILD values
%   Usage: plot_ild(ild,phi)
%          plot_ild(ild)
%
%   Input options:
%       ild -   vector with given ILD values (e.g. crfeated with extract_ild)
%       phi -   corresponding angles (optional, default: -180°..179°)
%
%   PLOT_ILD(ild,phi) creates a figure with the given ILD values and add
%   corresponding labels etc.
%
%   see also: extract_ild, plot_itd

% AUTHOR: Hagen Wierstorf


%% ===== Checking of input parameters ====================================
nargmin = 1;
nargmax = 2;
error(nargchk(nargmin,nargmax,nargin));
isargvector(ild);
if nargin==nargmax
    isargvector(phi);
    if length(ild)~=length(phi)
        error('%s: phi has to have the same length as ild!',upper(mfilename));
    end
else
    phi = -180:1:179;
end


%% ===== Plotting ========================================================
figure;
plot(phi,ild);
axis([phi(1),phi(end),-30,30]);
xlabel('phi (°)');
ylabel('ILD (dB)')
