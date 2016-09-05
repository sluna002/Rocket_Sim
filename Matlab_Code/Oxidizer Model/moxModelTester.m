
global e D rho mu kTotal Pc Ptank L

e = 0.15; %mm
D = 0.5 * 0.0254; %in to m
rho = 800; %kg/m3
mu = 15e-6; %N*s/m2
Pc = 500 * 6894.76; %psi to Pa
Ptank = 800 * 6894.76; %psi to Pa
kTotal = 40; %Total headloss coefficient (Tank Valve k = 0.5, Injector k = 1)
L = 2 * 0.3048; %Feet to meters

vel = fzero(@moxVelDiff,100)


