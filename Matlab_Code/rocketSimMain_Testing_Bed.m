clear;
close all;
clc;

global root

root = getRoot();

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

rpaSet = extract([root,'rpa_results.txt']);
rpaSet(:,2) = rpaSet(:,2) * 10^6; %Convert all pressures from MPa to Pa
[rpaStruct, indexMap] = organizer(rpaSet);

Dp_min = 2 * 0.025;%list of port diameters (inchs to meters)
Dp_fin_max = 4 * 0.025;%list of outer diameter of grain (inchs to meters)
minGrainThickness = 1 * 0.025;%The minimum thickness of the grain (difference between Dp_fin and Dp)
Mox_list = [2.5 5] * 0.454; %list of total oxidizer mass (lb to kg)
OF_list = 1:1:10; %List of overall OF ratios
AcAt_list = indexMap.AcAt(:,1); %List of AreaChamber/AreaThroat ratios
AeAt_list = indexMap.AeAt(:,1); %List of AreaExit/AreaThroat ratios



%The weight of the bottle needs to be accounted for

combinations = generateRocketVariations(Dp_min, Dp_fin_max, minGrainThickness, Mox_list, OF_list, AcAt_list, AeAt_list);

apogee = [];
PercentFuelRemaining = [];
MaxVel = [];
resultSet = [];
fprintf('%d many variations\n',size(combinations,1));
tic
for ii = 1 : size(combinations,1)
    rhof = 900;
    rhoAir = 1.225;
    g = 9.81;
    OF = combinations(ii,4);
    Dp_fin = combinations(ii,2);
    Mr = 6;
    eta_n = 0.95;
    Ar = 0.00817; %4inch diamter
    Cd = 0.7; 
    t_fin = 7;
    AcAt = combinations(ii,5);
    AeAt = combinations(ii,6);
    At = (1/AcAt) * 0.25 * pi * Dp_fin^2; 

    Dp = combinations(ii,1); %Diameter of Port [m]
    Mox = combinations(ii,3); %Total mass of oxidizer left [kg]
    Mox_total = Mox;
    Mf = Mox / OF; %Total mass of fuel left [kg]
    L = 4 * Mox / ( pi * rhof * OF * (Dp_fin^2 - Dp^2));
    vel = 0; %Velocity of rocket [m/s]
    alt = 0; %Altitude of rocket [m]

    init = [Dp, Mox, Mf, vel, alt]; %Initial conditions of dynamic variables
    t = [0 50];

%     useless = rocketFunc(1,init);
%     [T,Y] = ode45(@rocketFunc,t,init);
    [T,Y] = ode113(@rocketFunc,t,init);
    try
        apogee(ii) = Y((find(diff(Y(:,5)) < 0,1)),5) * 3.281; %meters to feet
        PercentFuelRemaining(ii) = Y(end,3) / Mf;
        MaxVel(ii) = max(Y(:,4));
    catch
        apogee(ii) = -1;
        PercentFuelRemaining(ii) = -1;
        MaxVel(ii) = -1;
    end
    
    if mod(ii,500) == 0
        disp([num2str(ii), ' runs complete']);
        toc
        tic
    end
%     plot(T,Y(:,5));
%     close all;
end

%THIS LINE NEEDS TO BE REVISED
resultSet = [combinations,apogee',PercentFuelRemaining',MaxVel'];

title = {'Diameter of Port','Outside Diameter','Mass of Oxidizer','O/F',...
         'Ac/At','Ae/At','Apogee','Percent fuel remaining','Max Velocity'};
printable = vertcat(title,num2cell(resultSet));
delete([root, 'rocketResults.xlsx']);
xlswrite([root, 'rocketResults.xlsx'],printable);

%%
%Testing variables
% rhof = 900;
% rhoAir = 1.225;
% g = 9.81;
% OF = 6;
% Dp_fin = 3.875 * 0.025; %inch to meter
% Mr = 6;
% char_v = 1569.2801;
% Cf = 1.4866;
% eta_c = 0.9;
% eta_n = 0.9;
% Ar = 0.00817; %4inch diamter
% Cd = 0.7; 
% t_fin = 6;
% 
% Dp = 1 * 0.025; %Diameter of Port [m] (inch to meter)
% Mox = 15; %Total mass of oxidizer left [kg]
% Mox_total = Mox;
% Mf = Mox / OF; %Total mass of fuel left [kg]
% L = 4 * Mox / ( pi * rhof * OF * (Dp_fin^2 - Dp^2));
% vel = 0; %Velocity of rocket [m/s]
% alt = 0; %Altitude of rocket [m]

