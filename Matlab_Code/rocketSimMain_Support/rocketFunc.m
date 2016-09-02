function [var_p] = rocketFunc(t, var_in)

%Temporary assumptions
% - Oxidizer mass flow rate is constant
% - Motor is unbreakable
% - Atmosphere has constant density

%Global variables are constant
global rhof rhoAir g OF Dp_fin Mr L eta_n Ar Cd Mox_total t_fin AcAt AeAt At; 
%rhof: density of fuel              [kg/m3]
%rhoAir: density of air             [kg/m3]
%g: Gravitational acceleration      [m/s2]
%OF: Overall O/F ratio              [unitless]
%Dp_fin: Final port diameter        [m]
%Mr: Mass of rocket w/o fuel        [kg]
%L: Length of grain                 [m]
%eta_n: nozzle efficiency           [unitless]
%Ar: area of rocket                 [m2]
%Cd: Coefficient of Drag            [unitless]
%Mox_total: Total mass of oxidizer  [kg] (This is a temporary variable for
                                         %for the oxTank model)
%t_fin: Time to empty n2o tank      [s]  (This is a temporary variable for
                                         %for the oxTank model)
%AcAt: Area Chamber / Area Throat
%AeAt: Area Exit / Area Throat                                         
%At: Area Throat                    [m2] 
                                         
global rpaStruct indexMap;
%Var variables are dynamic
Dp = var_in(1); %Diameter of Port [m]
Mox = var_in(2); %Total mass of oxidizer left [kg]
Mf = var_in(3); %Total mass of fuel left [kg]
vel = var_in(4); %Velocity of rocket [m/s]
alt = var_in(5); %Altitude of rocket [m]

Dp_dot_f = @(Gox) 2 * (0.155 * Gox ^ 0.5) / 1000; %Dp_dot [m/s], Gox [kg/(m2*s)]
Mf_dot_f = @(rhof, Dp, L, Dp_dot) rhof * pi * Dp * L * Dp_dot / 2; % Mf_dot [kg/s], rhof [kg/m3], Dp [m], Dp_dot [m/s], L [m]
Gox_f = @(Mox_dot, Dp) Mox_dot / (Dp ^ 2 * pi / 4); % Gox [kg/(m2*s)], Dp [m], Mox_dot [kg/s]
Thrust_f = @(Mox_dot, Mf_dot, char_v, eta_c, Cf, eta_n) (Mox_dot + Mf_dot) * char_v * eta_c * Cf * eta_n; % Thrust [N], Mox_dot [kg/s], Mf_dot [kg/s], char_v [m/s]

Mox_dot = oxTank(Mox_total,t_fin,t);
Gox = Gox_f(Mox_dot, Dp);

if Dp_fin <= Dp
    Dp_dot = 0;
else
    Dp_dot = Dp_dot_f(Gox);
end

Mf_dot = Mf_dot_f(rhof, Dp, L, Dp_dot);

OFw = Mox_dot / Mf_dot;

% if sign(OFw) == -1
%     useless = 1;
% elseif sign(Dp_dot) == -1
%     useless = 0;
% end

if OFw == 0 || OFw == inf || isnan(OFw)
    Pc = 0;
    Thrust = 0;
else
    values_mean = grabValues_MeanPressure(rpaStruct, indexMap, OFw, AcAt, AeAt);
    char_v = values_mean(6);
    eta_c = values_mean(11);

    Pc = (Mox_dot + Mf_dot) * char_v * eta_c / At;

    values = grabValues(rpaStruct, indexMap, OFw, Pc, AcAt, AeAt);

    char_v = values(6);
    eta_c = values(11);
    Cf = values(9);

    Thrust = Thrust_f(Mox_dot, Mf_dot, char_v, eta_c, Cf, eta_n);
end

Drag = 0.5 * rhoAir * vel^2 * Ar * Cd * -sign(vel);

acceleration = (Thrust + Drag) / (Mr + Mf + Mox) - g;

var_p = [Dp_dot, -Mox_dot, -Mf_dot, acceleration, vel]';

end

%% N2O Tank model
function Mox_dot = oxTank(Mox_total,t_fin,t)
    if t < t_fin
        Mox_dot = Mox_total / t_fin;
    else
        Mox_dot = 0;
    end
        
end

%% Rocket casing failure model