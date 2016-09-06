clear;
close all;
clc;


global e D mu kTotal L At rhol rhog hl hg Pc Ptank v_choice Vtank nosPropSet rhoLeft Af char Ttank

char.temp = 1;
char.p = 2;
char.rhol = 3;
char.rhog = 4;
char.hl = 5;
char.hg = 6;
char.dh = 7;


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
Ttank = 277.778;


Mox = 15 * 0.454; %lb to kg
x = 0.95; % Fraction of Nos that is liquid
Tatm = 277; %K

Pc = 101e3;%300 * 6894.76; %psi to Pa
nosProp = getNosProp(nosPropSet, char.temp, Ttank); %psi to Pa
Ptank = nosProp(char.p);

Mox_l = Mox * x;
Mox_g = Mox * (1 - x);

rhog = 190;
rhol = 743.9;

Vtank = Mox_g / rhog + Mox_l / rhol;

rhol = nosProp(char.rhol);
rhog = nosProp(char.rhog);
hl = nosProp(char.hl);
hg = nosProp(char.hg);


ug = hg - Ptank / rhog;
ul = hl - Ptank / rhol;


Utank = Mox_g * ug + Mox_l * ul;


init = [Utank, Mox_g, Mox_l];
t = [0 20];

[T, Y] = ode113(@odeMoxTester, t, init);

Mox = sum(Y(:,[2,3])') / 0.454;

Mox_dot = diff(Mox)' ./ diff(T);


plot(T,Mox,'r',T(1:end-1),-Mox_dot,'b');


% vel = fzero(@moxVelDiff,100)






