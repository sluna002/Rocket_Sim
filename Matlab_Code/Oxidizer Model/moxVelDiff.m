function [ vel_diff ] = moxVelDiff(vel_in)
%This function returns the difference between the supplied velocity and the
%calculated velocity of nos in feed lines
%When the difference is zero, supplied velocity is correct

global e D rhoLeft mu kTotal Pc Ptank L

%e = Roughness of feed line [mm]
%D = Diameter of feed line [m]
%rho = density of the nos in the feed line [kg/m3]
%mu = viscosity of fluid in the feed line [kg/m*s]
%kTotal = Minor losses coefficient []
%Pc = pressure of chamber [Pa]
%Ptank = Pressure in the nos tank [Pa]

%Calculate reynolds number
Re = vel_in * rhoLeft * D / mu;

%Create function that needs to be equal to zero and only unknown is f
f_func = @(f) -2 * log10( e / (D * 1000) / 3.7 + 2.51 / ( Re * sqrt(f))) - 1 / sqrt(f);

%Solve for f using root solver
f = fzero(f_func,0.15);

if Ptank < Pc
    useless = 0;
end

%Get out put velocity buy taking into acount total head loss and pressure
vel_out = sqrt( 2 * ( Ptank - Pc ) / ( f * L / D + kTotal) );

%Return the difference between the supplied velocity and calculated
%velocity
vel_diff = vel_in - vel_out;

end

