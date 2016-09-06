function [var_dot] = odeMoxTester(t,var_in)

global e D rhoLeft mu kTotal L Pc Ptank rhol rhog At hl hg v_choice Vtank nosPropSet Af



Mox = var_in(1);
Utank = var_in(2);
Mox_g = var_in(3);
Mox_l = var_in(4);

if Mox_l  <= 0
    Mox_l = 0;
    Mox_dot = rhog * 0.25 * pi * D * sqrt( 2 * ( Ptank - Pc ) / (kTotal) );
else  
    Mox_dot = rhol * 0.25 * pi * D * sqrt( 2 * ( Ptank - Pc ) / (kTotal) );
end


if Ptank <= Pc
    Ptank = Pc;
    dUt = 0;
    Mox_g_dot = 0;
    Mox_l_dot = 0; 

elseif Mox_l > 0
    Mox_g_dot = Af * Mox_dot / rhol / (1 / rhog - 1 / rhol);
    Mox_l_dot = -(Mox_g_dot + Mox_dot);
    Vl = Mox_l / rhol;
    Vu = Vtank - Vl;
    rhog = Mox_g / Vu;
    
    if rhog > 452
        useless = 0;
    end
    
    nosProp = getNosProp(nosPropSet, rhog);
    
    rhol = nosProp(3);
    hl = nosProp(5);
    hg = nosProp(6);
    Ptank = nosProp(2);
%     H = Mox_l * hl + Mox_g * hg;
%     Ptank = (H - Utank) / Vtank;
    dW = Ptank * Mox_dot / rhol;
    dUt = -(dW + Mox_dot * hl);
    
else
    
    rhog = moxg / Vt;
    Mox_g_dot = -Mox_dot;
    Mox_l_dot = 0;

    nosProp = getNosProp(nosPropSet, rhog);
    
    hg = nosProp(6);
    Ptank = nosProp(2);
%     H = moxg * hg;
%     
%     Ptank = (H - Utank) / Vtank;
    dUt = -Mox_dot * hg;
    
end






% Pc = Mox_dot ^ 2 / (rhog * At ^ 2);






var_dot = [-Mox_dot, dUt, Mox_g_dot, Mox_l_dot]';




end

