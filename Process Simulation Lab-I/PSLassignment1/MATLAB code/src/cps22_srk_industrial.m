function out=cps22_srk_industrial(comp,T_K,P_Pa,components,kij)
% Classical SRK diagnostics with sourced pure properties and vdW one-fluid rules.
% No phase-stability conclusion is returned. kij is scalar binary interaction.
comp=comp(:)'; if numel(comp)~=2||any(~isfinite(comp))||any(comp<0)||abs(sum(comp)-1)>1e-8||T_K<=0||P_Pa<=0
 error('CPS22:InvalidSRKInput','Require binary normalized composition and positive T/P.'); end
Tc=[components.Tc_K]; Pc=[components.Pc_Pa]; omega=[components.omega]; R=8.31446261815324;
m=0.480+1.574*omega-0.176*omega.^2; alph=(1+m.*(1-sqrt(T_K./Tc))).^2;
ai=0.42747*R^2.*Tc.^2./Pc.*alph; bi=0.08664*R.*Tc./Pc;
K=[0 kij;kij 0]; am=0; for i=1:2, for j=1:2, am=am+comp(i)*comp(j)*sqrt(ai(i)*ai(j))*(1-K(i,j)); end, end
bm=sum(comp.*bi); A=am*P_Pa/(R^2*T_K^2); B=bm*P_Pa/(R*T_K);
rt=roots([1 -1 A-B-B^2 -A*B]); realRoots=sort(real(rt(abs(imag(rt))<1e-8))); valid=realRoots(realRoots>B);
if isempty(valid), error('CPS22:NoAdmissibleSRKRoot','No real root above B.'); end
Z=max(valid); lnphi=zeros(1,2);
for i=1:2
 asum=0; for j=1:2, asum=asum+comp(j)*sqrt(ai(i)*ai(j))*(1-K(i,j)); end
 lnphi(i)=bi(i)/bm*(Z-1)-log(Z-B)-A/B*(2*asum/am-bi(i)/bm)*log(1+B/Z);
end
out=struct('Z',Z,'phi',exp(lnphi),'lnphi',lnphi,'real_roots',realRoots,'A',A,'B',B,'a_i',ai,'b_i',bi,'a_mix',am,'b_mix',bm,'m',m,'alpha',alph);
end
