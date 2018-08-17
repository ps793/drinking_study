function  output  = loess( loess_data )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
xi=1:length(loess_data);
yi=zeros(size(loess_data,1),1);
zi=loess_data;
[x,y,z] = prepareSurfaceData( xi, yi, zi );

% Set up fittype and options.
ft = fittype( 'loess' );
opts = fitoptions( 'Method', 'LowessFit' );
opts.Normalize = 'on';
%span=(0.01*size(z,1))/size(div{j},1);
span=1/6;

% Fit model to data.
[fitresult_div, gof] = fit( [x,y], z, ft, opts );
z_fit=feval(fitresult_div,[x,y]);
residual=abs(z_fit-z);

var_residual=sqrt(var(residual));

z_resid=residual/var_residual;

indication=(2*var_residual+mean(residual))<=residual;

output=[loess_data,z_fit,indication];

end

