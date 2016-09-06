clear;
close all;
clc;


global e D mu kTotal L At rhol rhog hl hg Pc Ptank v_choice Vtank nosPropSet rhoLeft Af

nosPropSet = xlsread('C:\Users\Steven\Google Drive\Rocket Project 2015 - 2016\Rocket Sim\Nox_Properties.xlsx');
nosPropSet(:,2) = nosPropSet(:,2) * 1e3; %Convert from kPa to Pa
nosPropSet(:,[5,6,7]) = nosPropSet(:,[5,6,7]) * 1e3; % Convert from kJ/kg to J/kg

e = 0.15; %mm
D = 0.5 * 0.0254; %in to m
Af = 1.3; %Boiling flux factor
mu = 15e-6; %N*s/m2
kTotal = 100000000; %Total headloss coefficient (Tank Valve k = 0.5, Injector k = 1)
L = 2 * 0.3048; %Feet to meters
At = 7.9161132e-4; %m2 area of throat
v_choice = 20;


Mox = 15 * 0.454; %lb to kg
x = 0.95; % Fraction of Nos that is liquid
Tatm = 277; %K

Pc = 101e3;%300 * 6894.76; %psi to Pa
Ptank = 800 * 6894.76; %psi to Pa

Mox_l = Mox * x;
Mox_g = Mox * (1 - x);

rhog = 190;
rhol = 743.9;

Vtank = Mox_g / rhog + Mox_l / rhol;

Vl = Mox_l / rhol;
Vu = Vtank - Vl;
rhog = Mox_g / Vu;

nosProp = getNosProp(nosPropSet, rhog);
rhol = nosProp(3);
rhog = nosProp(4);
hl = nosProp(5);
hg = nosProp(6);
rhoLeft = rhol;




ug = hg - Ptank / rhog;
ul = hl - Ptank / rhol;





Utank = Mox_g * ug + Mox_l * ul;


init = [Mox, Utank, Mox_g, Mox_l];
t = [0 5];

[T, Y] = ode113(@odeMoxTester, t, init);

Y(:,1) = Y(:,1) / 0.454;

plot(T,Y(:,1));


% vel = fzero(@moxVelDiff,100)






