function dy = odefcn(t,y)
% global Ptc
dy = zeros(7,1);
%% Get Current #'s
Utc = y(1);
Pcc = y(2);
rinc = y(3);
moxl = y(4);
moxg = y(5);
mfc = y(6);
mcc = y(7);
Voxc = moxl / rhoNOSl;
moxc = moxl + moxg;
%% OxMass Flows
Ttc = Ptc*(Vt - Voxc)/(Pt*(Vt-Vox)/Tatm);
if moxl <= 0
    dmox = Injector(N, dinj, Kinj, Ptc, Pcc, rhoNOSg);
else
    dmox = Injector(N, dinj, Kinj, Ptc, Pcc, rhoNOSl);
end
%% Port Radius
Ap = pi * rinc^2;
if rinc < rout
    if dmox > 0
        Gox = dmox / 32.2 / Ap; % slugs/in^2-sec
        rp = a*Gox^n; % in/sec
    else
        rp = 0;
    end
else
    rp = 0;
end
dy(3) = rp;
%% Fuel Mass Flow
dmf = (2*pi*L * rinc * rp) * (rhoHTPB); % By rp
dy(6) = -dmf;
%% Get Combustion Temp
OF = dmox / dmf;
% disp(mat2str(OF))
if dmf > 0
    T = GetTemp(OF);
    ChamberTemp = T;
elseif dmf <= 0 && dmox > 0
    T = Ttc;
else
    T = ChamberTemp;
end
%% Nozzle Mass Flow
if dmf == 0
    Rex = Rnos;
else
    Rex = ExitR(OF); % in-lbf/lbm-R
end
[F, I, dmn] = nozzlecalc(dmf + dmox, Pcc, T, At, Ae, Aet, Patm, Rex, g2); % [lbf, sec, lbm/sec]
%% Mass of Gas in Chamber
if moxc <=0
    dmt = -dmn;
elseif rinc >= rout && moxc > 0
    dmt = dmox - dmn;
else
    dmt = dmox + dmf - dmn;
end
dy(7) = dmt;
%% Chamber Pressure
if moxc <= 0
    Vch = pi*L*rinc^2; % in^3
    Rair = 53.3533*12; % in-lbf / lbm-R
    dPcc = (Rair) * T / Vch * (-dmn); % psia/sec
elseif rinc >= rout && moxc > 0
    Vch = pi*L*rinc^2;
    dPcc = (Rnos) * T / Vch * dmt;
else
    Vc = pi*L*rinc^2 + Vfree;
    dVc = (2*pi*L * rinc * rp);
    dPcc = Rex*T *(dmt*Vc - mcc*dVc) / (Vc^2);
    % dPcc = Rex*T*(dmt/Vc + mcc*dVc/(Vc^2));
end
dy(2) = dPcc;
%% Tank Pressure
if Ptc <= Patm
    Ptc = Patm;
    dUt = 0;
    dmoxg = 0;
    dmoxl = 0;
elseif moxl > 0
    dmoxg = Dome.Af * dmox / rhoNOSl / (rhoNOSg/(rhoNOSg^2) - rhoNOSl/(rhoNOSl^2));
    dmoxl = -1*(dmoxg + dmox); % lbm/sec
    Vl = moxl / rhoNOSl;
    Vu = Vt - Vl;
    rhoNOSg = moxg / Vu; %lbm/in^3
    rhoNOSl = table(Dome.density_E_g, Dome.density_E_l, rhoNOSg);
    % lbm / in^3
    hg = table(Dome.density_E_g, Dome.enthalpy_E_g, rhoNOSg); %BTU/lbm
    hl = table(Dome.density_E_g, Dome.enthalpy_E_l, rhoNOSg); %BTU/lbm
    H = moxg*hg + moxl*hl;
    Ptc = (H - Utc) / Vt * (25037*12/32.2/32.2);
    dW = Ptc * dmox / rhoNOSl / 25037 * 32.2 / 12; % BTU / sec
    % dW = 0;
    dUt = -(dW + dmox*hl); % BTU / sec
else
    rhoNOSg = moxg / Vt;
    dmoxg = -dmox;
    dmoxl = 0;
    hg = table(Dome.density_E_g, Dome.enthalpy_E_g, rhoNOSg); %BTU/lbm
    H = moxg * hg;
    Ptc = (H - Utc) / Vt * (25037*12/32.2/32.2);
    dUt = -dmox*hg;
end
dy(1) = dUt;
dy(4) = dmoxl;
dy(5) = dmoxg; % lbm/sec
%% Progress
clc
t
dmn
F
I
Pcc
Ptc
rp
Rex
% pause(1/32)
progressbar(t/tburn,'Hybrid Simulator')
% set(display,'XData',t,'YData',Ptc)
% set(display2,'XData',t,'YData',Pcc)
end