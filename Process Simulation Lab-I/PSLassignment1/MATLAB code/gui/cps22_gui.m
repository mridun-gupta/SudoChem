function cps22_gui()
% CPS22_GUI Interactive T/P/composition/flow GUI for the ethanol-water system.
% Supports continuous numeric inputs wherever the selected property correlations
% and solver are defined. Outputs are exploratory because NRTL-SRK parameters
% have NOT been accepted for predictive use and experimental VLE is only available at the ingested literature isobars.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root,'-begin'); addpath(fullfile(root,'src'),'-begin');
P=cps22_find_project_files(root); cfg=cps22_load_config(P.config_file); D=cps22_read_reference_data(P.reference_data);
fig=uifigure('Name','CPS-22 | Wide-Range T-P VLE Explorer','Position',[100 80 1180 760]);
fig.Color=[0.97 0.98 0.99];
g=uigridlayout(fig,[1 2]); g.ColumnWidth={300,'1x'}; g.Padding=[12 12 12 12]; g.ColumnSpacing=12;
left=uipanel(g,'Title','Operating inputs','FontWeight','bold'); left.Layout.Row=1; left.Layout.Column=1;
lg=uigridlayout(left,[13 2]); lg.RowHeight={28,28,28,28,28,28,28,38,38,38,38,'1x',42}; lg.ColumnWidth={120,'1x'}; lg.Padding=[10 10 10 10];
lab=uilabel(lg,'Text','Temperature'); lab.Layout.Row=1; lab.Layout.Column=1; Tedit=uieditfield(lg,'numeric','Value',cfg.conditions.temperature_K,'Limits',[273 513.91]); Tedit.Layout.Row=1; Tedit.Layout.Column=2;
lab=uilabel(lg,'Text','Temperature unit'); lab.Layout.Row=2; lab.Layout.Column=1; Tunit=uidropdown(lg,'Items',{'K','°C'},'Value','K','ValueChangedFcn',@temperatureUnitChanged); Tunit.Layout.Row=2; Tunit.Layout.Column=2;
lab=uilabel(lg,'Text','Pressure'); lab.Layout.Row=3; lab.Layout.Column=1; Pedit=uieditfield(lg,'numeric','Value',cfg.conditions.pressure_Pa/1000,'Limits',[1 50000]); Pedit.Layout.Row=3; Pedit.Layout.Column=2;
lab=uilabel(lg,'Text','Pressure unit'); lab.Layout.Row=4; lab.Layout.Column=1; Punit=uidropdown(lg,'Items',{'kPa','bar','MPa','Pa'},'Value','kPa','ValueChangedFcn',@pressureUnitChanged); Punit.Layout.Row=4; Punit.Layout.Column=2; previousPUnit='kPa';
lab=uilabel(lg,'Text','Feed ethanol z'); lab.Layout.Row=5; lab.Layout.Column=1; zedit=uieditfield(lg,'numeric','Value',cfg.feed.z(1),'Limits',[0 1]); zedit.Layout.Row=5; zedit.Layout.Column=2;
lab=uilabel(lg,'Text','Feed flow'); lab.Layout.Row=6; lab.Layout.Column=1; Fedit=uieditfield(lg,'numeric','Value',cfg.feed.flow_kmol_h,'Limits',[eps 1e9]); Fedit.Layout.Row=6; Fedit.Layout.Column=2;
lab=uilabel(lg,'Text','Flow unit'); lab.Layout.Row=7; lab.Layout.Column=1; Funit=uidropdown(lg,'Items',{'kmol/h'},'Value','kmol/h'); Funit.Layout.Row=7; Funit.Layout.Column=2;
calcBtn=uibutton(lg,'push','Text','Calculate at T and P','ButtonPushedFcn',@calculate); calcBtn.Layout.Row=8; calcBtn.Layout.Column=[1 2];
plotBtn=uibutton(lg,'push','Text','Show bundled experimental T-x-y data','ButtonPushedFcn',@plotData); plotBtn.Layout.Row=9; plotBtn.Layout.Column=[1 2];
exportBtn=uibutton(lg,'push','Text','Export current results','ButtonPushedFcn',@exportResults); exportBtn.Layout.Row=10; exportBtn.Layout.Column=[1 2];
resetBtn=uibutton(lg,'push','Text','Reset to base case','ButtonPushedFcn',@resetInputs); resetBtn.Layout.Row=11; resetBtn.Layout.Column=[1 2];
cov=uilabel(lg,'Text','Bundled VLE isobars: 100, 101, 300, 500, 700, 1500, 2000 kPa','WordWrap','on'); cov.Layout.Row=12; cov.Layout.Column=[1 2];
status=uilabel(lg,'Text','Candidate model only; not accepted for predictive use.','FontColor',[0.65 0.15 0.1],'WordWrap','on'); status.Layout.Row=13; status.Layout.Column=[1 2];
right=uigridlayout(g,[2 1]); right.Layout.Row=1; right.Layout.Column=2; right.RowHeight={'1.2x','1x'}; right.Padding=[0 0 0 0];
ax=uiaxes(right); ax.Layout.Row=1; ax.Box='on'; title(ax,'Experimental VLE reference data'); xlabel(ax,'Ethanol mole fraction'); ylabel(ax,'Temperature (K)'); grid(ax,'on');
resArea=uitextarea(right,'Editable','off','FontName','Consolas','FontSize',12); resArea.Layout.Row=2; resArea.Value={'Enter temperature and pressure, then Calculate.';'Model status: parameters not accepted for predictive use.'};
last=struct(); plotData();
    function temperatureUnitChanged(~,~)
        % Keep the numeric entry in the unit currently displayed.
        % Temporarily widen Limits so a valid unit conversion can cross the
        % old unit's limits without triggering a numeric-field validation error.
        oldValue=Tedit.Value; Tedit.Limits=[-0.15 513.91];
        if strcmp(Tunit.Value,'°C')
            Tedit.Value=oldValue-273.15; Tedit.Limits=[-0.15 240.76];
        else
            Tedit.Value=oldValue+273.15; Tedit.Limits=[273 513.91];
        end
    end
    function pressureUnitChanged(~,~)
        % Preserve the absolute pressure when the displayed unit changes.
        oldUnit=previousPUnit; newUnit=Punit.Value;
        switch oldUnit, case 'kPa', oldScale=1e3; case 'bar', oldScale=1e5; case 'MPa', oldScale=1e6; case 'Pa', oldScale=1; end
        switch newUnit, case 'kPa', newScale=1e3; case 'bar', newScale=1e5; case 'MPa', newScale=1e6; case 'Pa', newScale=1; end
        absolutePressurePa=Pedit.Value*oldScale;
        % Widen temporarily so conversion is valid before installing unit limits.
        Pedit.Limits=[0.001 5e7]; Pedit.Value=absolutePressurePa/newScale;
        switch newUnit
            case 'kPa', Pedit.Limits=[1 50000];
            case 'bar', Pedit.Limits=[0.01 500];
            case 'MPa', Pedit.Limits=[0.001 50];
            case 'Pa',  Pedit.Limits=[1000 5e7];
        end
        previousPUnit=newUnit;
    end
    function calculate(~,~)
        try
            T=Tedit.Value; if strcmp(Tunit.Value,'°C'), T=T+273.15; end
            switch Punit.Value, case 'kPa', P=Pedit.Value*1000; case 'bar', P=Pedit.Value*1e5; case 'MPa', P=Pedit.Value*1e6; case 'Pa', P=Pedit.Value; end
            z=zedit.Value; F=Fedit.Value;
            if z<0||z>1||~isfinite(z)||F<=0||P<=0||T<=0, error('Inputs must be finite and physically positive; ethanol feed fraction must be in [0,1].'); end
            c=cfg; c.conditions.temperature_K=T; c.conditions.pressure_Pa=P; c.feed.z=[z;1-z]; c.feed.flow_kmol_h=F;
            v=cps22_validate_config(c); if ~v.valid, error(strjoin(cellstr(v.errors),newline)); end
            r=cps22_flash_tp(T,P,[z;1-z],c); last=struct('config',c,'result',r,'T_K',T,'P_Pa',P,'z',z,'F_kmol_h',F);
            pSat=cps22_antoine_psat(T,c);
            inside=any(abs(D.pressure_kPa-P/1000)<max(1e-4,1e-6*P/1000));
            tempCoverage=false; if inside, dd=D(abs(D.pressure_kPa-P/1000)<max(1e-4,1e-6*P/1000),:); tempCoverage=T>=min(dd.temperature_K)&&T<=max(dd.temperature_K); end
            if inside&&tempCoverage, coverage='At a measured isobar and within its measured temperature span';
            elseif inside, coverage='Measured isobar, but temperature outside its measured span';
            else, coverage='Model evaluation only: pressure is not an experimental isobar'; end
            msg={sprintf('INPUT: T = %.5g K (%.5g °C), P = %.6g kPa',T,T-273.15,P/1000),sprintf('Feed: z_EtOH = %.5f, F = %.6g kmol/h',z,F),sprintf('NIST Psat: ethanol %.6g kPa; water %.6g kPa',pSat(1)/1000,pSat(2)/1000),['Reference coverage: ' coverage],['Solver status: ' char(r.status)],sprintf('Candidate beta = %.7g',r.beta),sprintf('x_EtOH = %.7g; y_EtOH = %.7g',r.x(1),r.y(1)),sprintf('Liquid flow = %.7g kmol/h; vapour flow = %.7g kmol/h',F*(1-r.beta),F*r.beta),sprintf('Max |ln fugacity residual| = %.6g',r.max_abs_log_fugacity_residual),'MODEL ACCEPTANCE: NOT ACCEPTED FOR PREDICTIVE USE.','Interpretation: exploratory NRTL-SRK candidate result, not an industrial design result.','Bundled experimental VLE isobars: 100, 101, 300, 500, 700, 1500 and 2000 kPa. Other pressures are model-only unless a separately documented literature source is added.'};
            if isfield(r,'warnings')&&~isempty(r.warnings), msg=[msg;cellstr(string(r.warnings(:)))]; end
            resArea.Value=msg; cov.Text=coverage;
            if isfinite(r.beta), status.Text='Calculated. Model remains unvalidated; inspect residual and coverage status.'; else, status.Text='No numeric phase split returned. Check solver status and temperature correlation range.'; end
            cla(ax); hold(ax,'on'); plotReference(ax,D); if inside, xline(ax,z,':','Feed z'); end; hold(ax,'off');
        catch ME
            resArea.Value=[{'CALCULATION STOPPED';ME.message;'No extrapolation or unsupported result was substituted.'}]; status.Text='Input/property/model evaluation failed; see diagnostic.'; last=struct();
        end
    end
    function plotData(~,~), cla(ax); hold(ax,'on'); plotReference(ax,D); hold(ax,'off'); title(ax,'Bundled experimental ethanol-water VLE (seven isobars)'); xlabel(ax,'Ethanol mole fraction'); ylabel(ax,'Temperature (K)'); grid(ax,'on'); end
    function exportResults(~,~)
        if isempty(fieldnames(last)), uialert(fig,'Run a calculation successfully before exporting.','Nothing to export'); return; end
        outdir=fullfile(root,'results','gui'); if ~exist(outdir,'dir'),mkdir(outdir);end
        stamp=datestr(now,'yyyymmdd_HHMMSS'); fn=fullfile(outdir,['CPS22_GUI_' stamp '.txt']);
        fid=fopen(fn,'w'); if fid<0, uialert(fig,'Cannot write result file.','Export failed'); return; end
        for ii=1:numel(resArea.Value), fprintf(fid,'%s\n',resArea.Value{ii}); end; fclose(fid);
        uialert(fig,['Saved: ' fn],'Export complete');
    end
    function resetInputs(~,~), if strcmp(Tunit.Value,'°C'), Tunit.Value='K'; end; Tedit.Limits=[273 513.91]; Tedit.Value=cfg.conditions.temperature_K; Tunit.Value='K'; Punit.Value='kPa'; Pedit.Value=cfg.conditions.pressure_Pa/1000; zedit.Value=cfg.feed.z(1); Fedit.Value=cfg.feed.flow_kmol_h; resArea.Value={'Inputs reset. Press Calculate at T and P.'}; status.Text='Candidate model only; not accepted for predictive use.'; end
end
function plotReference(ax,D)
pressures=unique(D.pressure_kPa);
for i=1:numel(pressures)
    S=D(abs(D.pressure_kPa-pressures(i))<1e-5,:);
    [xs,ix]=sort(S.x_ethanol_mole_fraction); [ys,iy]=sort(S.y_ethanol_mole_fraction);
    plot(ax,xs,S.temperature_K(ix),'-o','DisplayName',sprintf('Liquid x, %.0f kPa',pressures(i)),'MarkerSize',3);
    plot(ax,ys,S.temperature_K(iy),'--s','DisplayName',sprintf('Vapour y, %.0f kPa',pressures(i)),'MarkerSize',3);
end
legend(ax,'Location','best');
end
