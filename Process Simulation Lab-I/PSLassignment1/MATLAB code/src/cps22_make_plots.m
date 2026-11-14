function cps22_make_plots(cfg, sensitivity, outputDir)
% Export reproducible reference/sensitivity visualizations with provenance labels.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
D=cps22_read_reference_data(cfg.paths.reference_data_abs);
% Plot 1: experimental T-x-y isobars.
f=figure('Visible','off','Color','w'); ax=axes(f); hold(ax,'on');
pressures=unique(D.pressure_kPa);
for p=pressures(:).'
    m=abs(D.pressure_kPa-p)<1e-6; q=D(m,:); [T,ix]=sort(q.temperature_K);
    plot(ax,q.x_ethanol_mole_fraction(ix),T,'o-','DisplayName',sprintf('Liquid x, %g kPa',p));
    plot(ax,q.y_ethanol_mole_fraction(ix),T,'s--','DisplayName',sprintf('Vapor y, %g kPa',p));
end
xlabel(ax,'Ethanol mole fraction'); ylabel(ax,'Temperature (K)'); title(ax,'Experimental ethanol-water T-x-y reference data');
grid(ax,'on'); legend(ax,'Location','best'); saveas(f,fullfile(outputDir,'P3_Fig1_Experimental_Txy.png')); close(f);
% Plot 2: empirical reference temperature sensitivity.
f=figure('Visible','off','Color','w'); ax=axes(f); m=strcmp(sensitivity.study_id,'S1_TEMPERATURE') & isfinite(sensitivity.beta);
plot(ax,sensitivity.varied_value(m),sensitivity.beta(m),'o-'); xlabel(ax,'Temperature (K)'); ylabel(ax,'Vapor fraction');
title(ax,'Temperature sensitivity, experimental reference interpolation only'); grid(ax,'on'); saveas(f,fullfile(outputDir,'P3_Fig2_Temperature_Sensitivity.png')); close(f);
% Plot 3: composition sweep.
f=figure('Visible','off','Color','w'); ax=axes(f); m=strcmp(sensitivity.study_id,'S3_FEED_COMPOSITION') & isfinite(sensitivity.beta);
plot(ax,sensitivity.varied_value(m),sensitivity.beta(m),'o-'); xlabel(ax,'Feed ethanol mole fraction'); ylabel(ax,'Vapor fraction');
title(ax,'Feed composition sweep, empirical tie-line screen'); grid(ax,'on'); saveas(f,fullfile(outputDir,'P3_Fig3_Composition_Sensitivity.png')); close(f);
% Plot 4: flow scaling.
f=figure('Visible','off','Color','w'); ax=axes(f); m=strcmp(sensitivity.study_id,'S4_FEED_FLOW') & isfinite(sensitivity.V_kmol_h);
plot(ax,sensitivity.varied_value(m),sensitivity.V_kmol_h(m),'o-'); xlabel(ax,'Feed flow (kmol/h)'); ylabel(ax,'Vapor flow (kmol/h)');
title(ax,'Feed flow scaling at fixed empirical split'); grid(ax,'on'); saveas(f,fullfile(outputDir,'P3_Fig4_Flow_Sensitivity.png')); close(f);
% Plot 5: SRK kij residual diagnostic.
f=figure('Visible','off','Color','w'); ax=axes(f); m=strcmp(sensitivity.study_id,'S5_SRK_KIJ_DIAGNOSTIC') & isfinite(sensitivity.response_value);
plot(ax,sensitivity.varied_value(m),sensitivity.response_value(m),'o-'); xlabel(ax,'SRK binary interaction parameter k_{ij}'); ylabel(ax,'RMS log-fugacity residual');
title(ax,'k_{ij} diagnostic on empirical tie-line, not accepted model fit'); grid(ax,'on'); saveas(f,fullfile(outputDir,'P3_Fig5_Kij_Diagnostic.png')); close(f);
% Plot 6: pressure scenarios.
f=figure('Visible','off','Color','w'); ax=axes(f); m=strcmp(sensitivity.study_id,'S2_PRESSURE') & isfinite(sensitivity.beta);
plot(ax,sensitivity.varied_value(m)/1e6,sensitivity.beta(m),'o'); xlabel(ax,'Pressure (MPa)'); ylabel(ax,'Vapor fraction');
title(ax,'Pressure cases on measured isobars; unavailable states are omitted'); grid(ax,'on'); saveas(f,fullfile(outputDir,'P3_Fig6_Pressure_Sensitivity.png')); close(f);
end
