clc; close all; clear;
%                           TASK 1
para = inputdlg({'Enter the value of resistivity in (Mohm.m): ',...
    'Enter the value of conductor length in (Km): ',...
    'Enter the value of conductor diameter in (cm): '}, 'Parameters', [1 50]);
roh  = str2double(para(1))*(10^-6);
len  = str2double(para(2))*(10^3);
r    = (str2double(para(3))/2)*(10^-2);
ques = questdlg('Is the transmission line symmetrical or unsymmetrical?',...
                    'choose',... 
                    'symmetrical', 'unsymmetrical',[1 50]);
switch ques
    case 'symmetrical'
        spc   = inputdlg('Enter the equilaterally spacing value: ',...
            'spacing', [1 50]);
        deq   = str2double(spc);
    case 'unsymmetrical'
        shape = questdlg('How is it bundeld?', 'shape',...
            'Horz/Vert','Triangle','Tetragon',[1 50]);
        switch shape
            case 'Horz/Vert' % 2 points connected horizontally or vertically
                spc = inputdlg({'Enter the spacing in (m): '}, 'spacing', [1 50]);
                deq = str2double(spc);
            case 'Triangle' % 3 points connected 
                spc = inputdlg({'Enter the 1st spacing in (m): ',...
                    'Enter the 2nd spacing in (m): ',...
                    'Enter the 3rd spacing in (m): '},...
                    'spacing', [1 50]);
                d1  = str2double(spc(1));
                d2  = str2double(spc(2));
                d3  = str2double(spc(3));
                deq = (d1*d2*d3)^1/3;
            case 'Tetragon' % 4 points connected
                spc= inputdlg({'Enter the 1st spacing in (m): ',...
                    'Enter the 2nd spacing in (m): ',...
                    'Enter the 3rd spacing in (m): '},...
                    'Enter the 4th spacing in (m): ','spacing', [1 50]);
                d1  = str2double(spc(1));
                d2  = str2double(spc(2));
                d3  = str2double(spc(3));
                d4  = str2double(spc(4));
                deq = (d1*d2*d3*d4)^1/4;
            otherwise
        end
    otherwise
end

GMR     = 0.7788*r;

%                           Resistance

RDC     = (roh*len)/(pi*(r^2));
result1 = strcat('The DC resistance = ', num2str(RDC), ' Ohms');
msgbox(result1);
RAC     = 1.1 * RDC;
result2 = strcat('The AC resistance = ', num2str(RAC), ' Ohms');
msgbox(result2);

%                           Inductance

L       = (2*(10^-7))*log(deq/GMR);
result3 = strcat('The inductance per phase = ', num2str(L), ' H/m');
msgbox(result3);

%                           Capacitance

eps     = 8.85*(10^-12);
Cap     = (2*pi*eps)/log(deq/r);
result4 = strcat('The capacitance per phase = ', num2str(Cap), ' F/m');
msgbox(result4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           TASK 2

L   = L*len;
Cap = Cap*len;
ff  = inputdlg('Enter the frequency in (HZ): ', 'Frequency', [1 50]);
f   = str2double(ff);
w   = 2*pi*f;
if len<80000
    A = 1;
    D = 1;
    B = RDC+(w*L*1i);
    C = 0;
else
    q = questdlg('choose the model for the medium line analysis: ',...
        'choose','PI-Model','T-Model',[1 50]);
    switch q
        case 'PI-Model'
            A = 1+((RDC+(w*L*1i))*((w*Cap*1i)))/2;
            D = A;
            B = RDC+(w*L*1i);
            C = (w*Cap*1i)*(1+((RDC+(w*L*1i))*((w*Cap*1i)))/4);
        case 'T-Model'
            A = 1+((RDC+(w*L*1i))*((w*Cap*1i)))/2;
            D = A;
            B = (RDC+(w*L*1i))*(1+((RDC+(w*L*1i))*(w*Cap*1i))/4);
            C = w*Cap*1i;
        otherwise
    end
end
resA = ['The A parameter is: ' num2str(A)]; msgbox(resA);
resB = ['The B parameter is: ' num2str(B)]; msgbox(resB);
resC = ['The C parameter is: ' num2str(C)]; msgbox(resC);
resD = ['The D parameter is: ' num2str(D)]; msgbox(resD);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           TASK 3

q   = questdlg('Please choose a case','Cases','Case I', 'Case II',[1 50]);
par = inputdlg({'Enter the receiving end voltage (Vr) value in (V): '},...
    'Parameters', [1 50]);
Vr  = str2double(par);

switch q
    case 'Case I'
        
        pf  = 0.8;       % lag
        P   = linspace(0,100000,10000);

        VR  = Vr/(3)^0.5;
        ir  = P./(3*VR*pf);
        IR  = ir*0.8 - 0.6*ir*1i;
        
        VS  = A*VR + B*IR;
        IS  = C*VR + D*IR;
        
        Vs  = VS*(3)^0.5;
        Is  = IS*(3)^0.5;
        
        phi = angle(Vs)- angle(Is);
        Ps  = abs(VS).*abs(IS).*cos(phi).*3;
        
        REG = ((abs(Vs.)/abs(A))-abs(Vr))./abs(Vr))*100;
        Eff = (P./Ps)*100;
        
        figure; subplot(1,2,1); plot(P,REG);
        ylabel('Voltage Regulation %'); xlabel('Active Power');
        
        subplot(1,2,2); plot(P,Eff);
        ylabel('Efficiency %'); xlabel('Active Power');
        
    case 'Case II'
        
        P   = 100000;
        pf  = linspace(0.3,1);
       
%       Lagging PF 
        
        VR  = Vr/(3)^0.5;
        ir  = P./(3*VR*pf);
        IR  = ir.*pf - sin(acos(pf)).*ir*1i;
        
        VS  = A*VR + B*IR;
        IS  = C*VR + D*IR;
        
        Vs  = VS*(3)^0.5;
        Is  = IS*(3)^0.5;
        
        phi = angle(Vs)-angle(Is);
        Ps  = abs(VS).*abs(IS).*cos(phi).*3;
        
        REG = ((abs(Vs.)/abs(A))-abs(Vr))./abs(Vr))*100;
        Eff = (P./Ps)*100;
        
        figure; subplot(2,2,1); plot(pf,REG);
        ylabel('Voltage Regulation %'); xlabel('Lagging Power factor');
        
        subplot(2,2,2); plot(pf,Eff);
        ylabel('Efficiency %'); xlabel('Lagging Power factor');
       
%       Leading PF
        
        IR  = ir.*pf + sin(acos(pf)).*ir*1i;
        
        VS  = A*VR + B*IR;
        IS  = C*VR + D*IR;
        
        Vs  = VS*(3)^0.5;
        Is  = IS*(3)^0.5;
        
        phi = angle(Vs)-angle(Is);
        Ps  = abs(VS).*abs(IS).*cos(phi).*3;
        
        REG = ((abs(Vs.)/abs(A))-abs(Vr))./abs(Vr))*100;
        Eff = (P./Ps)*100;
        
        subplot(2,2,3); plot(pf,REG);
        ylabel('Voltage Regulation %'); xlabel('Leading Power factor');
        
        subplot(2,2,4); plot(pf,Eff)
        ylabel('Efficiency %'); xlabel('Leading Power factor');
        
end

                    















