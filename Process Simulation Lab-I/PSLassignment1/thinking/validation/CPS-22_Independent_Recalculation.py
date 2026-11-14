"""Independent audit route for the CPS-22 empirical tie-line and fugacity diagnostic.

This does not import the MATLAB code or the project build script. It independently
re-evaluates the interpolation, lever rule, NRTL activity coefficients, SRK fugacity
coefficients, component-specific Poynting factors, and balance closures.
All values marked candidate/estimated remain unaccepted model inputs.
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'data' / 'CPS-22_Experimental_VLE_99_Points.csv'
BASE = ROOT / 'validation' / 'CPS-22_Industrial_Base_Case_Results.csv'
OUT = ROOT / 'validation'
R = 8.31446261815324
# Source-frozen candidate pure component constants. Values are inputs, not locally measured data.
Tc = np.array([514.7092848812961, 647.096])
Pc = np.array([6267914.582702095, 22064000.0])
omega = np.array([0.644, 0.3442920843])
MW = np.array([46.06844, 18.015268]) # kg/kmol
ANTOINE = [(4.92531,1432.526,-61.819,364.8,513.91),
           (3.55959,643.748,-198.043,379.0,573.0)]
AIJ = np.array([[0.0,-0.8009],[3.4578,0.0]])
BIJ = np.array([[0.0,246.18],[-586.0809,0.0]])
ALPHA = np.array([[0.0,0.3],[0.3,0.0]])
# Low-confidence component volume proxies, m3/mol.
VL_COMPONENT = np.array([7.19087e-5,2.41893e-5])

def psat_bar(i, T):
    A,B,C,Tmin,Tmax = ANTOINE[i]
    if not Tmin <= T <= Tmax:
        raise ValueError(f'Antoine temperature out of validity range for component {i}: {T} K')
    return 10.0**(A-B/(T+C))

def nrtl(x, T):
    tau = AIJ + BIJ/T
    G = np.exp(-ALPHA*tau)
    lng = np.zeros(2)
    for i in range(2):
        s1 = sum(x[j]*tau[j,i]*G[j,i] for j in range(2))/sum(x[k]*G[k,i] for k in range(2))
        s2 = 0.0
        for j in range(2):
            den = sum(x[k]*G[k,j] for k in range(2))
            inn = sum(x[m]*tau[m,j]*G[m,j] for m in range(2))/den
            s2 += x[j]*G[i,j]/den*(tau[i,j]-inn)
        lng[i] = s1+s2
    return lng, np.exp(lng), tau, G

def srk_phi(comp, T, P, kij=0.0):
    m = 0.480+1.574*omega-0.176*omega**2
    alpha = (1+m*(1-np.sqrt(T/Tc)))**2
    a = 0.42747*R**2*Tc**2/Pc*alpha
    b = 0.08664*R*Tc/Pc
    kijm = np.array([[0.0,kij],[kij,0.0]])
    am = sum(comp[i]*comp[j]*np.sqrt(a[i]*a[j])*(1-kijm[i,j]) for i in range(2) for j in range(2))
    bm = float(comp@b)
    A = am*P/(R**2*T**2); B = bm*P/(R*T)
    roots = np.roots([1.0,-1.0,A-B-B**2,-A*B])
    real = np.sort(roots.real[np.abs(roots.imag)<1e-8])
    admissible = real[real>B]
    if len(admissible)==0:
        raise ValueError(f'No admissible SRK root; T={T}, P={P}, A={A}, B={B}, roots={roots}')
    Z = float(admissible[-1])
    lnphi = np.empty(2)
    for i in range(2):
        asum = sum(comp[j]*np.sqrt(a[i]*a[j])*(1-kijm[i,j]) for j in range(2))
        lnphi[i] = (b[i]/bm)*(Z-1)-np.log(Z-B) - (A/B)*(2*asum/am-b[i]/bm)*np.log(1+B/Z)
    return {'Z':Z,'phi':np.exp(lnphi),'lnphi':lnphi,'A':A,'B':B,'roots':roots,'real_roots':real}

def main():
    raw = pd.read_csv(DATA)
    base = pd.read_csv(BASE).set_index('result') if 'result' in pd.read_csv(BASE,nrows=0).columns else pd.read_csv(BASE).set_index('result')
    # For this table the first column may be named 'result'; support the canonical generated layout.
    if 'value' in base.columns:
        get = lambda key: float(base.loc[key,'value'])
    else:
        raise ValueError('Base-case results CSV must contain result,value,unit,status,notes columns.')
    T = get('basis_T'); P = get('basis_P'); F = get('feed_F'); z = np.array([0.5,0.5])
    iso = raw[np.isclose(raw['pressure_Pa'],P)].sort_values('temperature_K')
    xE = float(np.interp(T, iso['temperature_K'], iso['x_ethanol_mole_fraction']))
    yE = float(np.interp(T, iso['temperature_K'], iso['y_ethanol_mole_fraction']))
    x = np.array([xE,1-xE]); y=np.array([yE,1-yE])
    beta=(z[0]-x[0])/(y[0]-x[0]); V=F*beta; L=F*(1-beta)
    nF=F*z; nL=L*x; nV=V*y
    massF=nF*MW; massL=nL*MW; massV=nV*MW
    total_closure=F-(L+V)
    comp_closure=nF-nL-nV
    mass_closure=float(np.sum(massF)-np.sum(massL)-np.sum(massV))
    Ps=np.array([psat_bar(i,T)*1e5 for i in range(2)])
    lng,gamma,tau,G=nrtl(x,T)
    vap=srk_phi(y,T,P,0.0)
    pure_e=srk_phi(np.array([1.0,0.0]),T,Ps[0],0.0)
    pure_w=srk_phi(np.array([0.0,1.0]),T,Ps[1],0.0)
    phi_sat=np.array([pure_e['phi'][0],pure_w['phi'][1]])
    poy=np.exp(VL_COMPONENT*(P-Ps)/(R*T))
    fL=x*gamma*Ps*phi_sat*poy
    fV=y*vap['phi']*P
    lnres=np.log(fV/fL); ratio=fV/fL
    maxres=float(np.max(np.abs(lnres)))
    records=[]
    comps=['Ethanol','Water']
    for i,c in enumerate(comps):
        records.append({'item':f'{c} log fugacity residual','independent_result':float(lnres[i]),'reference_result':float(pd.read_csv(OUT/'CPS-22_Fugacity_Residuals.csv').loc[i,'ln_fV_over_fL']),'absolute_difference':float(abs(lnres[i]-pd.read_csv(OUT/'CPS-22_Fugacity_Residuals.csv').loc[i,'ln_fV_over_fL'])),'unit':'dimensionless','status':'FAIL: magnitude exceeds 1e-6' if abs(lnres[i])>1e-6 else 'PASS'})
    records += [
      {'item':'Reference temperature','independent_result':T,'reference_result':get('basis_T'),'absolute_difference':0.0,'unit':'K','status':'PASS: configured reference state'},
      {'item':'Ethanol liquid mole fraction','independent_result':x[0],'reference_result':get('x_ethanol'),'absolute_difference':abs(x[0]-get('x_ethanol')),'unit':'mol/mol','status':'PASS' if abs(x[0]-get('x_ethanol'))<1e-10 else 'FAIL'},
      {'item':'Ethanol vapour mole fraction','independent_result':y[0],'reference_result':get('y_ethanol'),'absolute_difference':abs(y[0]-get('y_ethanol')),'unit':'mol/mol','status':'PASS' if abs(y[0]-get('y_ethanol'))<1e-10 else 'FAIL'},
      {'item':'Vapour fraction','independent_result':beta,'reference_result':get('beta_vapour'),'absolute_difference':abs(beta-get('beta_vapour')),'unit':'mol/mol','status':'PASS' if abs(beta-get('beta_vapour'))<1e-10 else 'FAIL'},
      {'item':'Total molar closure','independent_result':total_closure,'reference_result':0.0,'absolute_difference':abs(total_closure),'unit':'kmol/h','status':'PASS' if abs(total_closure)<1e-9 else 'FAIL'},
      {'item':'Maximum component closure','independent_result':float(np.max(np.abs(comp_closure))),'reference_result':0.0,'absolute_difference':float(np.max(np.abs(comp_closure))),'unit':'kmol/h','status':'PASS' if np.max(np.abs(comp_closure))<1e-9 else 'FAIL'},
      {'item':'Mass closure','independent_result':mass_closure,'reference_result':0.0,'absolute_difference':abs(mass_closure),'unit':'kg/h','status':'PASS' if abs(mass_closure)<1e-8 else 'FAIL'},
      {'item':'Max absolute log fugacity residual','independent_result':maxres,'reference_result':1e-6,'absolute_difference':maxres-1e-6,'unit':'dimensionless','status':'FAIL: exceeds criterion'},
      {'item':'Residual exceedance factor','independent_result':maxres/1e-6,'reference_result':1.0,'absolute_difference':maxres/1e-6-1.0,'unit':'fold','status':'FAIL: exceedance'},
    ]
    pd.DataFrame(records).to_csv(OUT/'CPS-22_Independent_Recalculation.csv',index=False)
    details={
      'T_K':T,'P_Pa':P,'F_kmol_h':F,'z':z.tolist(),'x':x.tolist(),'y':y.tolist(),'beta':beta,'L_kmol_h':L,'V_kmol_h':V,
      'component_feed_kmol_h':nF.tolist(),'component_liquid_kmol_h':nL.tolist(),'component_vapour_kmol_h':nV.tolist(),
      'component_mass_feed_kg_h':massF.tolist(),'component_mass_liquid_kg_h':massL.tolist(),'component_mass_vapour_kg_h':massV.tolist(),
      'Psat_Pa':Ps.tolist(),'ln_gamma':lng.tolist(),'gamma':gamma.tolist(),'tau':tau.tolist(),'G':G.tolist(),
      'SRK_Z_vapour':vap['Z'],'SRK_phi_vapour':vap['phi'].tolist(),'SRK_A':vap['A'],'SRK_B':vap['B'],
      'phi_sat':phi_sat.tolist(),'vL_component_m3_mol':VL_COMPONENT.tolist(),'Poynting':poy.tolist(),
      'f_liquid_Pa':fL.tolist(),'f_vapour_Pa':fV.tolist(),'ln_fV_over_fL':lnres.tolist(),'fV_over_fL':ratio.tolist(),
      'total_closure_kmol_h':total_closure,'component_closure_kmol_h':comp_closure.tolist(),'mass_closure_kg_h':mass_closure,
      'max_abs_ln_fugacity_residual':maxres,'criterion':1e-6,'model_disposition':'FAIL; empirical tie-line is a reference fixture, not an accepted NRTL-SRK prediction'
    }
    (OUT/'CPS-22_Independent_Recalculation_Details.json').write_text(json.dumps(details,indent=2),encoding='utf-8')
    print(json.dumps({'T_K':T,'x_ethanol':x[0],'y_ethanol':y[0],'beta':beta,'L_kmol_h':L,'V_kmol_h':V,'total_closure':total_closure,'component_closure':comp_closure.tolist(),'mass_closure':mass_closure,'max_abs_ln_fugacity_residual':maxres,'threshold':1e-6,'status':'FAIL model; PASS arithmetic fixture'},indent=2))

if __name__=='__main__': main()
