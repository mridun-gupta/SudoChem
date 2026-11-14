function [lnGamma,gamma]=cps22_nrtl_candidate(x,T_K,aij,bij_K,alpha)
% NRTL activity coefficients for tau_ij=a_ij+b_ij/T_K.
% Candidate parameters only; no claim of high-pressure validity.
x=x(:)'; n=numel(x);
if numel(x)~=2||any(~isfinite(x))||any(x<0)||abs(sum(x)-1)>1e-8||T_K<=0
 error('CPS22:InvalidNRTLInput','Require binary finite normalized composition and positive T.'); end
if any(~isfinite(aij(:)))||any(~isfinite(bij_K(:)))||any(~isfinite(alpha(:)))||any(alpha(:)<0)
 error('CPS22:InvalidNRTLParameters','Invalid NRTL parameter matrix.'); end
tau=aij+bij_K/T_K; G=exp(-alpha.*tau); lnGamma=zeros(1,n);
for i=1:n
    den1=sum(x.*G(:,i)'); num1=sum(x.*tau(:,i)'.*G(:,i)'); term1=num1/den1; term2=0;
    for j=1:n
       den=sum(x.*G(:,j)'); inner=sum(x.*tau(:,j)'.*G(:,j)')/den;
       term2=term2+x(j)*G(i,j)/den*(tau(i,j)-inner);
    end
    lnGamma(i)=term1+term2;
end
gamma=exp(lnGamma);
end
