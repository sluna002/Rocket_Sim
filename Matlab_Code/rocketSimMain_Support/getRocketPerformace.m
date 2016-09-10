function [Thrust_list, Pc_list, Ptank_list, Isp] = getRocketPerformace(T, Y)

global rhof rhoAir g Dp_fin Mr L eta_n Ar Cd AcAt AeAt At Pc;
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


global D_feed kTotal Ptank rhol rhog hl hg Vtank nosPropSet Af prop Pc_max;
%D_feed: diameter of feedline
%kTotal: Total headloss coefficient of Nos injector system
%Ptank: current pressure in Nos tank
%rhol: density of liquid Nos
%rhog: density of gaseous Nos
%hl: specific enthalpy of liquid Nos
%hg: specific enthalpy of gaseous Nos
%Vtank: Volume of Nos tank
%nosPropSet: A data set of Nos properties at vapor dome
%Af: Boiling flux factor
%prop: A struct whos contents corrispond with column numbers of nosPropSet
%EX: prop.temp = 1;
%    prop.rhol = 3;
%The temperature characteristic is the first column of nosPropSet while
%density of liquid nos is the third

global rpaStruct indexMap;

NN = length(T);
Thrust_list = zeros(NN,1);
Ptank_list = zeros(NN,1);
Pc_list = zeros(NN,1);
Mox_dot_list = zeros(NN,1);


    for ii = 1 : NN
        Dp = Y(ii,1);
        Mf = Y(ii,2);
        Utank = Y(ii,3);
        Mox_g = Y(ii,4);
        Mox_l = Y(ii,5);

        if Mox_l <= 0
            Mox_l = 0;
            Mox_dot = rhog * 0.25 * pi * D_feed ^ 2 * sqrt( 2 * ( Ptank - Pc ) / (kTotal * rhog) );
        else
            Mox_dot = rhol * 0.25 * pi * D_feed ^ 2* sqrt( 2 * ( Ptank - Pc ) / (kTotal * rhol) );
        end


        %Solve for current Nos Tank state
        if Ptank <= Pc
            Ptank = Pc;

            dUt = 0;
            Mox_g_dot = 0;
            Mox_l_dot = 0;
            Mox_dot = 0; %Overides previous calculation of Mox_dot

        elseif Mox_l > 0
            Mox_g_dot = Af * Mox_dot / rhol / (1 / rhog - 1 / rhol);
            Mox_l_dot = -(Mox_g_dot + Mox_dot);
            Vl = Mox_l / rhol;
            Vu = Vtank - Vl;
            rhog = Mox_g / Vu;

            if rhog > 452
                error(['Density of ',num2str(rhog),'kg/m3 exceeds the max of 452']);
            end

            nosProp = getNosProp(nosPropSet, prop.rhog, rhog);

            rhol = nosProp(3);
            hl = nosProp(5);
            hg = nosProp(6);
            Ptank = nosProp(2);

            %     H = Mox_l * hl + Mox_g * hg;
            %     Ptank = (H - Utank) / Vtank;
            dW = Ptank * Mox_dot / rhol;
            dUt = -(dW + Mox_dot * hl);

        else

            rhog = Mox_g / Vtank;
            Mox_g_dot = -Mox_dot;
            Mox_l_dot = 0;

            if rhog > 452
                error(['Density of ',num2str(rhog),'kg/m3 exceeds the max of 452']);
            end

            nosProp = getNosProp(nosPropSet, prop.rhog, rhog);

            hg = nosProp(6);
            Ptank = nosProp(2);

            %     H = moxg * hg;
            %
            %     Ptank = (H - Utank) / Vtank;
            dUt = -Mox_dot * hg;

        end

        Dp_dot_f = @(Gox) 2 * (0.155 * Gox ^ 0.5) / 1000; %Dp_dot [m/s], Gox [kg/(m2*s)]
        Mf_dot_f = @(rhof, Dp, L, Dp_dot) rhof * pi * Dp * L * Dp_dot / 2; % Mf_dot [kg/s], rhof [kg/m3], Dp [m], Dp_dot [m/s], L [m]
        Gox_f = @(Mox_dot, Dp) Mox_dot / (Dp ^ 2 * pi / 4); % Gox [kg/(m2*s)], Dp [m], Mox_dot [kg/s]
        Thrust_f = @(Mox_dot, Mf_dot, char_v, eta_c, Cf, eta_n) (Mox_dot + Mf_dot) * char_v * eta_c * Cf * eta_n; % Thrust [N], Mox_dot [kg/s], Mf_dot [kg/s], char_v [m/s]

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
            Pc = 101e3;
            Thrust_list(ii) = 0;
        else
            values_mean = grabValues_MeanPressure(rpaStruct, indexMap, OFw, AcAt, AeAt);
            char_v = values_mean(6);
            eta_c = values_mean(11);

            Pc = (Mox_dot + Mf_dot) * char_v * eta_c / At;

            if Pc < 101e3
                Pc = 101e3;
            elseif Pc > Pc_max
                Pc_max = Pc;
            end

            values = grabValues(rpaStruct, indexMap, OFw, Pc, AcAt, AeAt);

            char_v = values(6);
            eta_c = values(11);
            Cf = values(9);

            Thrust_list(ii) = Thrust_f(Mox_dot, Mf_dot, char_v, eta_c, Cf, eta_n);
        end
        Mox_dot_list(ii) = Mox_dot;
        Pc_list(ii) = Pc;
        Ptank_list(ii) = Ptank;
    end
    
    I = sum((Thrust_list(1:end-1) + Thrust_list(2:end)) .* diff(T(1:end)));
    Weight_burned = 9.81*(Y(1,2) - Y(end,2) + Y(1,4) + Y(1,5));
    Isp = I / Weight_burned ;
    




end

