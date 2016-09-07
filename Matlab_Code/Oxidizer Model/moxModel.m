clear;
close;
clc;


global D kTotal rhol rhog hl hg Pc Ptank Vtank nosPropSet Af char Ttank

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

D = 0.5 * 0.0254; %in to m
Af = 1.3; %Boiling flux factor
kTotal = 44; %Total headloss coefficient (Tank Valve k = 0.5, Injector k = 1)
Ttank = 277.778; %K (THIS CANNOT BE OVER 298K OR DENSITY VALUES EXCEED DATASET)

Mox = 15 * 0.454; %lb to kg
x = 0.95; % Fraction of Nos that is liquid

Pc = 101e3;%300 * 6894.76; %psi to Pa
nosProp = getNosProp(nosPropSet, char.temp, Ttank); %psi to Pa
Ptank = nosProp(char.p);

Mox_l = Mox * x;
Mox_g = Mox * (1 - x);

rhog = nosProp(char.rhog);
rhol = nosProp(char.rhol);

Vtank = Mox_g / rhog + Mox_l / rhol;

hl = nosProp(char.hl);
hg = nosProp(char.hg);


ug = hg - Ptank / rhog;
ul = hl - Ptank / rhol;


Utank = Mox_g * ug + Mox_l * ul;


init = [Utank, Mox_g, Mox_l];
t = [0 20];

[T, Y] = ode45(@odeMoxTester, t, init);

Mox = sum(Y(:,[2,3])') / 0.454;

Mox_dot = diff(Mox)' ./ diff(T);


plot(T,Mox,'r',T(1:end-1),-Mox_dot,'b');


% vel = fzero(@moxVelDiff,100)






