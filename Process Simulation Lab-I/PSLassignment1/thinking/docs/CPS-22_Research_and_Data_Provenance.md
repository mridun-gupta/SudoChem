# CPS-22 Industrial Re-run: Research and Data Provenance Dossier

Generated 26 October 2026. This document separates published measurements, database correlations, model equations, fitted or candidate parameters, assumptions and screening estimates.

## Experimental mixture evidence
Susial Badajoz et al. (2021), J. Chem. Eng. Data 66(2), 928-946, DOI 10.1021/acs.jced.0c00686, reports ethanol-water VLE measurements at 100, 1500 and 2000 kPa; the paper describes low- and high-pressure consistency tests and gives azeotropes x=y=0.899, T=351.39 K at 100 kPa; x=y=0.857, T=440.70 K at 1500 kPa; x=y=0.850, T=453.83 K at 2000 kPa. The article evaluates PR variants and PC-SAFT, not an independently implemented NRTL-SRK package. URL: https://doi.org/10.1021/acs.jced.0c00686

## NIST and critical-property basis
- Ethanol Antoine correlation from NIST SRD 69, Ambrose and Sprake et al. (1975): log10(Psat/bar)=4.92531-1432.526/(T-61.819), 364.8-513.91 K. URL: https://webbook.nist.gov/cgi/cbook.cgi?ID=C64175&Mask=1E9F
- Ethanol ΔHvap correlation from NIST SRD 69, Majer and Svoboda (1985): A exp(-alpha Tr)(1-Tr)^beta, A=50.43 kJ/mol, alpha=-0.4475, beta=.4989, Tc=513.9K; range 298-469K. Same URL.
- Water Antoine correlation from NIST SRD 69, Liu and Lindsay (1970): log10(Psat/bar)=3.55959-643.748/(T-198.043), 379-573K. URL: https://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Plot=&Type=ANTOINE
- Water liquid Cp from NIST-JANAF data as exposed by SRD 69, Chase (1998), 298-500K. Shomate coefficients are frozen in the property register. URL: https://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Mask=1F&Plot=on&Type=JANAFL
- Critical properties and acentric factors in this rerun use CoolProp documented fluid constants, for consistency across the SRK implementation: ethanol Tc=514.709284881K, Pc=6267914.583Pa, omega=0.6440000; water Tc=647.096000K, Pc=22064000Pa, omega=0.3442920843. Ethanol: https://coolprop.org/fluid_properties/fluids/Ethanol.html; Water: https://coolprop.org/fluid_properties/fluids/Water.html

## Model foundations
NRTL: Renon and Prausnitz (1968), DOI 10.1002/aic.690140124. SRK: Soave (1972), DOI 10.1016/0009-2509(72)80096-4. Phase stability: Michelsen (1982), DOI 10.1016/0378-3812(82)85001-2. These references support formulation/method selection, not the validity of this project's candidate parameter set.

## Candidate NRTL parameters
The reported parameter convention is tau_ij=a_ij+b_ij/T, G_ij=exp(-alpha_ij*tau_ij); a12=-0.8009, b12=246.18 K, a21=3.4578, b21=-586.0809 K, alpha12=alpha21=0.3. Source: 2017 paper on salt extractive distillation reproducing Aspen Plus VLE-IG binary parameters, https://www.mdpi.com/1996-1073/10/9/1276. Candidate only: not accepted for prediction at 445K and 1.5MPa. A recent data-set comparison paper also reports NRTL fit sensitivity to experimental dataset: https://doi.org/10.1021/acs.iecr.4c00484.

## Industrial calculation method references
IAPWS-IF97 is the industrial formulation for steam/water properties; actual utility design should calculate enthalpy differences from selected supply and return states, not use the assumed hfg scenario in this report. URL: https://iapws.org/technical-guidance/release/IF97-Rev
GPSA Engineering Data Book includes typical Souders-Brown K comparison values; service/vendor and high-pressure de-rating are required. URL: https://dl.eiepd.com/libraries/manuals/separator-design/pressure-vessel/GPSA.pdf
OpenPyTEA documents volume-based vertical-vessel cost correlations citing Turton et al. (2018) and states the nominal size range and ambient-pressure basis. URL: https://openpytea.readthedocs.io/en/latest/user_guide/equipment.html
CEPCI sources used for historical context: 2019 annual average 607.5 https://www.chemengonline.com/2019-chemical-engineering-plant-cost-index-annual-average/; June 2024 preliminary CEPCI 798.8 https://www.chemengonline.com/wp-content/uploads/2024/08/19_CHE_0924_EconInd_p45.pdf. No 2025/2026 index was invented.

## Evidence limitations
No accessible vendor datasheet, site design condition, component contaminant specification, selected mechanical code/material, current installed-cost database, guaranteed utility pricing, validated high-pressure liquid density, binary excess enthalpy or stable NRTL-SRK fit was provided. Accordingly, the project includes engineering screens and transparent formulas, not certified industrial design.


## Final rerun correction note (26 October 2026)
The Poynting correction in the latest audit/report build uses component-specific liquid molar-volume proxies, vL_i, in exp[vL_i(P-Psat_i)/(RT)], rather than a mixture-average volume reused for both species. The recalculated residual table is `validation/CPS-22_Fugacity_Residuals.csv`. These molar volumes remain provisional estimates, so the correction improves convention consistency but does not establish model acceptance.


## Final rerun correction note (26 October 2026)
The Poynting correction in the latest audit/report build uses component-specific liquid molar-volume proxies, vL_i, in exp[vL_i(P-Psat_i)/(RT)], rather than a mixture-average volume reused for both species. The recalculated residual table is `validation/CPS-22_Fugacity_Residuals.csv`. These molar volumes remain provisional estimates, so the correction improves convention consistency but does not establish model acceptance.


## Final rerun correction note (26 October 2026)
The Poynting correction in the latest audit/report build uses component-specific liquid molar-volume proxies, vL_i, in exp[vL_i(P-Psat_i)/(RT)], rather than a mixture-average volume reused for both species. The recalculated residual table is `validation/CPS-22_Fugacity_Residuals.csv`. These molar volumes remain provisional estimates, so the correction improves convention consistency but does not establish model acceptance.
