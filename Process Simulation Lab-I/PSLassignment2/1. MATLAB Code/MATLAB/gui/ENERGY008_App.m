classdef ENERGY008_App < handle
    %ENERGY008_APP Programmatic MATLAB GUI for the ENERGY-008 engineering model.
    % The UI delegates all calculations to the Prompt 19 engine modules.
    % This is an engineering/screening interface, not a live plant HMI.

    properties (SetAccess = private)
        ProjectRoot
        Config
        InitialModel
        CaseRecords
        CaseLabels
        CaseIds
        DefaultCaseId
        CurrentResults = []
        CurrentRunMeta = []
        CurrentReportDirectory = ''
        IsBusy = false
        UIFigure
        UI = struct()
    end

    methods
        function app = ENERGY008_App(projectRoot, cfg)
            app.ProjectRoot = char(projectRoot);
            app.Config = cfg;
            app.InitialModel = load_model_inputs(app.ProjectRoot, cfg, 'GUI-INITIALISE');
            app.CaseRecords = app.InitialModel.cases;
            app.CaseRecords(end+1) = app.InitialModel.case_data;
            [~, uniqueIdx] = unique({app.CaseRecords.case_id}, 'stable');
            app.CaseRecords = app.CaseRecords(uniqueIdx);
            app.CaseIds = {app.CaseRecords.case_id};
            app.CaseLabels = cell(size(app.CaseRecords));
            for k = 1:numel(app.CaseRecords)
                c = app.CaseRecords(k);
                app.CaseLabels{k} = sprintf('%s | %s | %s', char(c.route_id), ...
                    char(c.scenario_name), char(c.case_status));
            end
            app.DefaultCaseId = char(app.InitialModel.case_data.case_id);
            app.buildUI();
            app.onCaseChanged();
            app.updateStatus('NOT RUN', ...
                'No calculation has been executed in this MATLAB session.', 'neutral');
        end

        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                app.UIFigure.CloseRequestFcn = [];
                delete(app.UIFigure);
            end
        end
    end

    methods (Access = private)
        function buildUI(app)
            app.UIFigure = uifigure('Name', 'ENERGY-008 | Engineering Model GUI', ...
                'Position', [35 35 1290 680], 'Color', [0.96 0.97 0.98]);
            app.UIFigure.CloseRequestFcn = @(~,~)delete(app);

            rootGrid = uigridlayout(app.UIFigure, [3 1]);
            rootGrid.RowHeight = {48, 66, '1x'};
            rootGrid.Padding = [10 10 10 10];
            rootGrid.RowSpacing = 8;

            header = uigridlayout(rootGrid, [1 5]);
            header.Layout.Row = 1;
            header.ColumnWidth = {'1x', 112, 112, 112, 112};
            header.Padding = [0 0 0 0];
            titleLabel = uilabel(header, 'Text', 'ENERGY-008 | Green Methanol Engineering Model', ...
                'FontSize', 18, 'FontWeight', 'bold', 'FontColor', [0.12 0.18 0.25]);
            titleLabel.Layout.Column = 1;
            app.UI.RunButton = uibutton(header, 'push', 'Text', 'Run / Calculate', ...
                'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~)app.onRun());
            app.UI.RunButton.Layout.Column = 2;
            app.UI.ResetButton = uibutton(header, 'push', 'Text', 'Reset defaults', ...
                'ButtonPushedFcn', @(~,~)app.onReset());
            app.UI.ResetButton.Layout.Column = 3;
            app.UI.ExportButton = uibutton(header, 'push', 'Text', 'Export run', ...
                'Enable', 'off', 'ButtonPushedFcn', @(~,~)app.onExport());
            app.UI.ExportButton.Layout.Column = 4;
            helpButton = uibutton(header, 'push', 'Text', 'User guide', ...
                'ButtonPushedFcn', @(~,~)app.openUserGuide());
            helpButton.Layout.Column = 5;

            statusPanel = uipanel(rootGrid, 'Title', 'Calculation state and traceability');
            statusPanel.Layout.Row = 2;
            statusGrid = uigridlayout(statusPanel, [2 3]);
            statusGrid.RowHeight = {25, 22};
            statusGrid.ColumnWidth = {245, '1x', 320};
            statusGrid.Padding = [8 4 8 4];
            app.UI.StatusLabel = uilabel(statusGrid, 'Text', 'NOT RUN', ...
                'FontWeight', 'bold', 'FontSize', 14, 'HorizontalAlignment', 'center', ...
                'BackgroundColor', [0.88 0.90 0.92], 'FontColor', [0.18 0.22 0.26]);
            app.UI.StatusLabel.Layout.Row = 1;
            app.UI.StatusLabel.Layout.Column = 1;
            app.UI.StatusMessage = uilabel(statusGrid, 'Text', 'No run has been performed.', ...
                'WordWrap', 'on');
            app.UI.StatusMessage.Layout.Row = 1;
            app.UI.StatusMessage.Layout.Column = 2;
            app.UI.RunMetaLabel = uilabel(statusGrid, 'Text', 'Run ID: none | Model: 0.1.0', ...
                'HorizontalAlignment', 'right', 'FontSize', 10);
            app.UI.RunMetaLabel.Layout.Row = 1;
            app.UI.RunMetaLabel.Layout.Column = 3;
            disclaimer = uilabel(statusGrid, 'Text', ...
                'ENGINEERING / REFERENCE GUI ONLY. NOT A LIVE DCS, PLC, SIS, FGS OR OPERATING HMI.', ...
                'FontWeight', 'bold', 'FontColor', [0.50 0.22 0.08], 'FontSize', 10);
            disclaimer.Layout.Row = 2;
            disclaimer.Layout.Column = [1 3];

            app.UI.Tabs = uitabgroup(rootGrid);
            app.UI.Tabs.Layout.Row = 3;
            app.buildDesignBasisTab();
            app.buildStreamsTab();
            app.buildOperatingConditionsTab();
            app.buildProcessModelTab();
            app.buildBalancesTab();
            app.buildEquipmentTab();
            app.buildUtilitiesTab();
            app.buildEconomicsTab();
            app.buildAutomationTab();
            app.buildSensitivityTab();
            app.buildReportsTab();
        end

        function buildDesignBasisTab(app)
            tab = uitab(app.UI.Tabs, 'Title', 'Design Basis');
            grid = uigridlayout(tab, [1 2]);
            grid.ColumnWidth = {'1x', '1x'};
            grid.Padding = [10 10 10 10];
            left = uipanel(grid, 'Title', 'Case and user-selectable reference basis');
            right = uipanel(grid, 'Title', 'Design status, provenance and assumptions');
            left.Layout.Column = 1; right.Layout.Column = 2;
            L = uigridlayout(left, [8 2]);
            L.RowHeight = {26, 34, 26, 34, 26, 34, 26, '1x'};
            L.ColumnWidth = {190, '1x'};
            L.Padding = [8 8 8 8];
            uilabel(L, 'Text', 'Approved case/model');
            app.UI.CaseDropdown = uidropdown(L, 'Items', app.CaseLabels, ...
                'Value', app.labelForCase(app.DefaultCaseId), ...
                'ValueChangedFcn', @(~,~)app.onCaseChanged());
            uilabel(L, 'Text', 'Methanol component-equivalent basis');
            app.UI.ThroughputEdit = uieditfield(L, 'numeric', 'Value', 50000, ...
                'ValueDisplayFormat', '%.6g');
            uilabel(L, 'Text', 'Throughput unit');
            app.UI.ThroughputUnit = uidropdown(L, 'Items', {'kg/day','t/day'}, ...
                'Value', 'kg/day', 'ValueChangedFcn', @(~,~)app.onThroughputUnitChanged());
            app.UI.PreviousThroughputUnit = 'kg/day';
            uilabel(L, 'Text', 'Operating hours');
            app.UI.OperatingHoursEdit = uieditfield(L, 'numeric', 'Value', 24, ...
                'ValueDisplayFormat', '%.6g');
            uilabel(L, 'Text', 'Units / basis note');
            uilabel(L, 'Text', 'kg/day or t/day; h/day');
            uilabel(L, 'Text', 'Temperature / pressure');
            uilabel(L, 'Text', 'Not assigned; physical state is BLOCKED');
            uilabel(L, 'Text', 'Input validation');
            app.UI.InputValidationText = uilabel(L, 'Text', 'Waiting for input.', ...
                'FontColor', [0.30 0.34 0.38]);
            app.UI.DesignNotes = uitextarea(L, 'Editable', 'off', ...
                'Value', {'Throughput is a reference/scenario input, not an approved plant capacity.', ...
                'No user-editable reactor temperature, pressure, trip limits or alarm thresholds are provided.', ...
                'Changing throughput scales the stoichiometric reference only; it does not solve a physical flowsheet.'});
            app.UI.DesignNotes.Layout.Row = 8;
            app.UI.DesignNotes.Layout.Column = [1 2];

            R = uigridlayout(right, [2 1]);
            R.RowHeight = {'1x', '1x'};
            R.Padding = [8 8 8 8];
            app.UI.DesignStatusText = uitextarea(R, 'Editable', 'off', 'Value', ...
                {'Route C is a provisional working basis; route approval is not evidenced.', ...
                'G3 design basis remains Rev 0.1-DRAFT and is not frozen.', ...
                'PFD Rev 0.1-DRAFT is conceptual, not a P&ID or construction document.', ...
                'The 50 t/day case is an illustrative ideal stoichiometric reference.', ...
                'CASE STUDY | Kassø: commercial e-methanol precedent for renewable H2 + biogenic CO2 integration; not a scale-up basis.', ...
                'CASE STUDY | Piteå: black-liquor syngas demonstration; highlights gas analysis, sulphur/tar cleanup and catalyst protection for Route B.', ...
                'CASE STUDY | Skive: biomass gasification CHP analogue only; it does not demonstrate methanol synthesis or methanol yield.', ...
                'Source and limitations: Sources/Engineering_Notes/ENERGY008_Real_World_Case_Studies.md'});
            app.UI.ProvenanceText = uitextarea(R, 'Editable', 'off', 'Value', ...
                {'SOURCED: source-attributed property and thermochemical register values.', ...
                'CALCULATED: stoichiometric balances, reference enthalpy and unit conversions executed by engine modules.', ...
                'ASSUMED: reference throughput, ideal conversion and explicit screening assumptions.', ...
                'FITTED: no fitted kinetic or VLE parameter set is active.', ...
                'ESTIMATED: no plant estimate is currently enabled.', ...
                'UNCERTAINTY: source-property uncertainty is shown where available; model-form and plant-state uncertainty remain unquantified.'});
        end

        function buildStreamsTab(app)
            tab = uitab(app.UI.Tabs, 'Title', 'Streams');
            grid = uigridlayout(tab, [2 1]);
            grid.RowHeight = {'1x', 96};
            grid.Padding = [10 10 10 10];
            app.UI.StreamTable = uitable(grid, 'Data', {}, 'ColumnName', {}, 'RowName', {});
            app.UI.StreamTable.Layout.Row = 1;
            note = uitextarea(grid, 'Editable', 'off', 'Value', ...
                {'The table is the engine-calculated stoichiometric component / ledger reference, not the 55-stream plant stream register.', ...
                'Physical stream flow, composition, phase, temperature, pressure and enthalpy are unavailable and remain null / BLOCKED.', ...
                'S-209 recycle and S-207 purge are BLOCKED_NOT_COMPUTED. They are not zero-flow streams.'});
            note.Layout.Row = 2;
        end

        function buildOperatingConditionsTab(app)
            tab = uitab(app.UI.Tabs, 'Title', 'Operating Conditions');
            grid = uigridlayout(tab, [2 2]);
            grid.RowHeight = {190, '1x'};
            grid.ColumnWidth = {'1x', '1x'};
            grid.Padding = [10 10 10 10];
            p1 = uipanel(grid, 'Title', 'Physical state and envelope');
            p1.Layout.Row = 1; p1.Layout.Column = 1;
            g1 = uigridlayout(p1, [5 2]); g1.ColumnWidth = {220,'1x'};
            uilabel(g1,'Text','Synthesis temperature');
            uilabel(g1,'Text','TBD / BLOCKED (K)');
            uilabel(g1,'Text','Synthesis pressure');
            uilabel(g1,'Text','TBD / BLOCKED (MPa(a))');
            uilabel(g1,'Text','Reactor reference point');
            uilabel(g1,'Text','250 degC, 7 MPa(a), screening only');
            uilabel(g1,'Text','ALK H2 interface reference');
            uilabel(g1,'Text','20 bar(a), screening only');
            uilabel(g1,'Text','Feed purity / ratio');
            uilabel(g1,'Text','Screening targets, not setpoints');
            p2 = uipanel(grid, 'Title', 'Operating mode and model use');
            p2.Layout.Row = 1; p2.Layout.Column = 2;
            g2 = uigridlayout(p2,[4 1]);
            uilabel(g2,'Text','Current GUI mode: OFFLINE ENGINEERING CALCULATION', ...
                'FontWeight','bold');
            uilabel(g2,'Text','No live instrument values, controller setpoints or package feedback are connected.');
            uilabel(g2,'Text','No automatic control, startup, shutdown, trip reset or safety bypass command is implemented.');
            uilabel(g2,'Text','The selected case and throughput are model inputs only.');
            app.UI.OperatingNotes = uitextarea(grid,'Editable','off','Value', ...
                {'The design basis includes capacity references of 25 / 50 / 55 t/day and a 60.5 t/day process design reference. These are not approved rate limits.', ...
                'The 5-10 MPa(a), 200-300 degC reactor literature envelope is not a mechanical design envelope or operating control range.', ...
                'Actual limits require approved stream balances, vendor maps, mechanical design, HAZOP/LOPA and operating procedures.'});
            app.UI.OperatingNotes.Layout.Row = 2;
            app.UI.OperatingNotes.Layout.Column = [1 2];
        end

        function buildProcessModelTab(app)
            tab = uitab(app.UI.Tabs, 'Title', 'Process Model');
            grid = uigridlayout(tab,[2 1]);
            grid.RowHeight = {'1x', 130};
            grid.Padding = [10 10 10 10];
            app.UI.ModelStatusTable = uitable(grid,'Data',{},'ColumnName',{},'RowName',{});
            app.UI.ModelStatusTable.Layout.Row = 1;
            app.UI.ModelWarnings = uitextarea(grid,'Editable','off','Value', ...
                {'PR78 is not enabled: active binary kij data are incomplete.', ...
                'Methanol-water VLE is not enabled: no fitted / validated Wilson or NRTL parameter set is available.', ...
                'R-301 PFR kinetics are not enabled: catalyst-matched kinetic parameters and reactor geometry are absent.', ...
                'Physical recycle / purge and dynamic simulation are not enabled.', ...
                'Generic numerical solver utilities are not evidence of a validated physical model.'});
            app.UI.ModelWarnings.Layout.Row = 2;
        end

        function buildBalancesTab(app)
            tab = uitab(app.UI.Tabs,'Title','Balances');
            grid = uigridlayout(tab,[2 2]);
            grid.RowHeight = {'1x','1x'};
            grid.ColumnWidth = {'1x','1x'};
            grid.Padding = [10 10 10 10];
            p1=uipanel(grid,'Title','Mass and elemental closure'); p1.Layout.Row=1; p1.Layout.Column=1;
            g1=uigridlayout(p1,[2 1]); g1.RowHeight={'1x',80};
            app.UI.ElementTable=uitable(g1,'Data',{},'ColumnName',{},'RowName',{});
            app.UI.MassClosureText=uitextarea(g1,'Editable','off','Value',{'Not calculated.'});
            p2=uipanel(grid,'Title','Energy reference calculations'); p2.Layout.Row=1; p2.Layout.Column=2;
            g2=uigridlayout(p2,[2 1]); g2.RowHeight={'1x',85};
            app.UI.EnergyTable=uitable(g2,'Data',{},'ColumnName',{},'RowName',{});
            app.UI.EnergyWarnings=uitextarea(g2,'Editable','off','Value',{'Plant energy closure remains blocked.'});
            p3=uipanel(grid,'Title','Entropy / exergy'); p3.Layout.Row=2; p3.Layout.Column=1;
            app.UI.EntropyText=uitextarea(p3,'Editable','off','Value', ...
                {'Plant entropy generation: BLOCKED (kW/K).', ...
                'Plant exergy destruction: BLOCKED (kW).', ...
                'Entropy and exergy closure: BLOCKED.', ...
                'No stream entropy, chemical exergy or dead-state environment is available.'});
            p4=uipanel(grid,'Title','Balance interpretation'); p4.Layout.Row=2; p4.Layout.Column=2;
            app.UI.BalanceNotes=uitextarea(p4,'Editable','off','Value', ...
                {'The material calculation is an ideal stoichiometric reaction-block reference.', ...
                'The small mass residual from independently rounded molecular weights is retained and reported, not forced to zero.', ...
                'Standard-state reaction rates are not reactor cooling duty or purchased electricity.', ...
                'Pure-component sensible / latent values are not process heater or distillation duties.'});
        end

        function buildEquipmentTab(app)
            tab = uitab(app.UI.Tabs,'Title','Equipment');
            grid = uigridlayout(tab,[2 1]); grid.RowHeight={'1x',130}; grid.Padding=[10 10 10 10];
            app.UI.EquipmentTable=uitable(grid,'Data',{},'ColumnName',{},'RowName',{});
            app.UI.EquipmentTable.Layout.Row=1;
            app.UI.EquipmentNotes=uitextarea(grid,'Editable','off','Value', ...
                {'HX-A01 area and W-201 pump power are explicitly illustrative Prompt 17 calculations, not the actual HX-301 or W-201 package rating.', ...
                'Compressor powers, reactor volume/catalyst loading, vessels, column, relief devices, mechanical design and materials remain BLOCKED.', ...
                'Equipment datasheet register rows list required inputs and data status; they are not completed vendor datasheets.'});
            app.UI.EquipmentNotes.Layout.Row=2;
        end

        function buildUtilitiesTab(app)
            tab = uitab(app.UI.Tabs,'Title','Utilities & Environment');
            grid = uigridlayout(tab,[2 2]); grid.RowHeight={'1x','1x'}; grid.ColumnWidth={'1x','1x'}; grid.Padding=[10 10 10 10];
            p1=uipanel(grid,'Title','Utility register and reference requirements'); p1.Layout.Row=1; p1.Layout.Column=1;
            g1=uigridlayout(p1,[1 1]); app.UI.UtilityTable=uitable(g1,'Data',{},'ColumnName',{},'RowName',{});
            p2=uipanel(grid,'Title','Environmental KPI status'); p2.Layout.Row=1; p2.Layout.Column=2;
            g2=uigridlayout(p2,[1 1]); app.UI.EnvironmentTable=uitable(g2,'Data',{},'ColumnName',{},'RowName',{});
            p3=uipanel(grid,'Title','Water and oxygen reference values'); p3.Layout.Row=2; p3.Layout.Column=1;
            app.UI.WaterOxygenText=uitextarea(p3,'Editable','off','Value',{'Not calculated.'});
            p4=uipanel(grid,'Title','Unresolved utility and MRV data'); p4.Layout.Row=2; p4.Layout.Column=2;
            app.UI.UtilityNotes=uitextarea(p4,'Editable','off','Value', ...
                {'Electrolyser kWh/day and plant electricity: BLOCKED.', ...
                'Cooling water / steam / hot utility duties: BLOCKED.', ...
                'Grid emissions, carbon-chain accounting and green-methanol certification: BLOCKED.', ...
                'No metered data, tariff, site emission factor or verified MRV boundary is loaded.'});
        end

        function buildEconomicsTab(app)
            tab = uitab(app.UI.Tabs,'Title','Economics');
            grid=uigridlayout(tab,[2 1]); grid.RowHeight={'1x',150}; grid.Padding=[10 10 10 10];
            app.UI.EconomicsSummary=uitextarea(grid,'Editable','off','Value', ...
                {'CAPEX: BLOCKED (INR).', 'OPEX: BLOCKED (INR/year).', 'LCOM: BLOCKED (INR/t MeOH).'});
            app.UI.EconomicsSummary.Layout.Row=1;
            app.UI.EconomicsNotes=uitextarea(grid,'Editable','off','Value', ...
                {'The economics module is source-gated and will calculate only from dated equipment quotations, escalation indices, location/installation factors, tariffs, annual operating cost drivers and finance assumptions.', ...
                'The current cost-basis template is intentionally incomplete. No generic cost correlation, tariff, CAPEX or OPEX has been invented.', ...
                'No failed or incomplete cost calculation is presented as a zero or a valid estimate.'});
            app.UI.EconomicsNotes.Layout.Row=2;
        end

        function buildAutomationTab(app)
            tab=uitab(app.UI.Tabs,'Title','Automation & Control');
            grid=uigridlayout(tab,[2 2]); grid.RowHeight={'1x','1x'}; grid.ColumnWidth={'1x','1x'}; grid.Padding=[10 10 10 10];
            p1=uipanel(grid,'Title','Modelled disturbance / control screening'); p1.Layout.Row=1; p1.Layout.Column=1;
            app.UI.ControlSummary=uitextarea(p1,'Editable','off','Value', ...
                {'DB-059 status: NOT RUN.', 'This is linear H2 deficit arithmetic only, not a dynamic control simulation.'});
            p2=uipanel(grid,'Title','Prompt 14 candidate register scale'); p2.Layout.Row=1; p2.Layout.Column=2;
            app.UI.ControlRegisterTable=uitable(p2,'Data', ...
                {'Control loops',88,'CANDIDATE';'Alarms',70,'CANDIDATE';'Cause/effect functions',37,'CANDIDATE'}, ...
                'ColumnName',{'Register','Entries','Approval status'},'RowName',{});
            p3=uipanel(grid,'Title','Status ownership and protection boundaries'); p3.Layout.Row=2; p3.Layout.Column=1;
            app.UI.ControlStatus=uitextarea(p3,'Editable','off','Value', ...
                {'BPCS / DCS: no live controller connection.', ...
                'Package PLCs: no live OEM interface.', ...
                'SIS / ESD / FGS: independent protection status is not connected or simulated.', ...
                'Alarm, trip, permissive, bypass and first-out state: NOT AVAILABLE.', ...
                'No start, stop, reset, bypass or setpoint command is provided.'});
            p4=uipanel(grid,'Title','HMI design guardrails'); p4.Layout.Row=2; p4.Layout.Column=2;
            app.UI.HMIGuardrails=uitextarea(p4,'Editable','off','Value', ...
                {'Offline engineering calculation mode only.', ...
                'Candidate registers are not an approved alarm database or executable cause/effect logic.', ...
                'TBD alarm/trip limits are not populated with default values.', ...
                'No control action is marked successful based on a request alone; this application issues no field command.', ...
                'Prompt 14 HMI requirements remain conceptual design inputs.'});
        end

        function buildSensitivityTab(app)
            tab=uitab(app.UI.Tabs,'Title','Sensitivity & Optimisation');
            grid=uigridlayout(tab,[3 1]); grid.RowHeight={'1x',165,28}; grid.Padding=[10 10 10 10];
            app.UI.SensitivityAxes=uiaxes(grid);
            title(app.UI.SensitivityAxes,'Reference throughput sensitivity');
            xlabel(app.UI.SensitivityAxes,'Methanol component-equivalent basis (t/day)');
            ylabel(app.UI.SensitivityAxes,'CO2 lower-bound reference (kg/day)');
            app.UI.SensitivityTable=uitable(grid,'Data',{},'ColumnName',{},'RowName',{});
            app.UI.SensitivityTable.Layout.Row=2;
            app.UI.SensitivityNotes=uilabel(grid,'Text', ...
                'Always based on the registered Route C 50 t/day reference, independent of the selected case. Linear stoichiometric scaling only; nonlinear optimisation and capacity feasibility remain BLOCKED.', ...
                'FontWeight','bold','FontColor',[0.50 0.22 0.08]);
            app.UI.SensitivityNotes.Layout.Row=3;
        end

        function buildReportsTab(app)
            tab=uitab(app.UI.Tabs,'Title','Reports');
            grid=uigridlayout(tab,[2 1]); grid.RowHeight={'1x',235}; grid.Padding=[10 10 10 10];
            app.UI.ReportTable=uitable(grid,'Data',{},'ColumnName',{},'RowName',{});
            app.UI.ReportTable.Layout.Row=1;
            p=uipanel(grid,'Title','Run diagnostics and exports'); p.Layout.Row=2;
            pg=uigridlayout(p,[5 1]); pg.RowHeight={22,22,'1x',22,'1x'}; pg.Padding=[8 6 8 6];
            app.UI.ReportStatus=uilabel(pg,'Text','No run exports are available.','FontWeight','bold');
            app.UI.ReportStatus.Layout.Row=1;
            diagnosticsLabel=uilabel(pg,'Text','Warnings, errors and module status');
            diagnosticsLabel.Layout.Row=2;
            app.UI.DiagnosticsText=uitextarea(pg,'Editable','off','Value',{'No run diagnostics.'});
            app.UI.DiagnosticsText.Layout.Row=3;
            exportsLabel=uilabel(pg,'Text','Exported files');
            exportsLabel.Layout.Row=4;
            app.UI.ReportFiles=uitextarea(pg,'Editable','off','Value', ...
                {'After a run, only files generated by completed engine modules are listed here.'});
            app.UI.ReportFiles.Layout.Row=5;
        end

        function onCaseChanged(app)
            idx = find(strcmp(app.CaseLabels,app.UI.CaseDropdown.Value),1);
            if isempty(idx), return; end
            c = app.CaseRecords(idx);
            valueKgDay = c.methanol_component_equivalent_kg_day;
            app.UI.ThroughputUnit.Value = 'kg/day';
            app.UI.PreviousThroughputUnit = 'kg/day';
            app.UI.ThroughputEdit.Value = valueKgDay;
            app.UI.OperatingHoursEdit.Value = c.operating_hours_per_day;
            app.UI.InputValidationText.Text = sprintf('Selected case: %s (%s).',char(c.case_id),char(c.case_status));
        end

        function onThroughputUnitChanged(app)
            value = app.UI.ThroughputEdit.Value;
            if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value)
                return;
            end
            previous = app.UI.PreviousThroughputUnit;
            current = app.UI.ThroughputUnit.Value;
            if strcmp(previous,current)
                return;
            end
            try
                if strcmp(previous,'kg/day') && strcmp(current,'t/day')
                    converted = unit_conversions(struct('conversion','kg_day_to_t_day','value',value));
                elseif strcmp(previous,'t/day') && strcmp(current,'kg/day')
                    converted = unit_conversions(struct('conversion','t_day_to_kg_day','value',value));
                else
                    return;
                end
                app.UI.ThroughputEdit.Value = converted;
                app.UI.PreviousThroughputUnit = current;
            catch ME
                app.UI.InputValidationText.Text = ME.message;
            end
        end

        function onRun(app)
            if app.IsBusy, return; end
            app.CurrentResults = [];
            app.CurrentRunMeta = [];
            app.CurrentReportDirectory = '';
            app.UI.ReportStatus.Text = 'No exports for this run yet.';
            app.setArea(app.UI.ReportFiles,{'No current run results.'});
            app.refreshAll();
            [ok, selectedCase, throughputKgDay, hoursPerDay, message] = app.validateInputs();
            if ~ok
                app.updateStatus('INPUT INVALID',message,'error');
                app.UI.InputValidationText.Text = message;
                uialert(app.UIFigure,message,'Input validation failed','Icon','error');
                app.UI.ExportButton.Enable = 'off';
                return;
            end
            app.IsBusy = true;
            app.UI.RunButton.Enable = 'off';
            app.UI.ResetButton.Enable = 'off';
            app.UI.StatusMessage.Text = 'Validating project inputs and executing the calculation engine...';
            drawnow;
            try
                [R, meta] = gui_run_engine(app.ProjectRoot,app.Config,selectedCase,throughputKgDay,hoursPerDay);
                app.CurrentResults = R;
                app.CurrentRunMeta = meta;
                if isfield(meta,'report_directory')
                    app.CurrentReportDirectory = char(meta.report_directory);
                end
                app.refreshAll();
                app.updateStatus(char(meta.status),app.statusMessage(meta),'warning');
                app.UI.RunMetaLabel.Text = sprintf('Run ID: %s | Model: %s | Data: %s', ...
                    char(meta.run_id),char(meta.model_version),char(meta.data_version));
                app.UI.InputValidationText.Text = ['Validated input case: ' char(meta.case_id)];
                if isfield(meta,'report_directory') && exist(meta.report_directory,'dir')==7
                    app.UI.ExportButton.Enable = 'on';
                    app.UI.ReportStatus.Text = ['Exports created in ' char(meta.report_directory)];
                else
                    app.UI.ExportButton.Enable = 'off';
                    app.UI.ReportStatus.Text = 'No report directory was created.';
                end
                if strcmp(meta.status,'RUN_FAILED')
                    app.updateStatus('RUN FAILED',app.statusMessage(meta),'error');
                    uialert(app.UIFigure,app.statusMessage(meta),'Calculation failed','Icon','error');
                elseif strcmp(meta.status,'BLOCKED_SELECTED_CASE')
                    uialert(app.UIFigure, ...
                        'The selected case has no supported material model. Its status is BLOCKED and no process results have been fabricated.', ...
                        'Calculation blocked','Icon','warning');
                else
                    uialert(app.UIFigure, ...
                        'Reference / screening calculations completed. Physical flowsheet calculations remain blocked and Prompt 21 validation is still required.', ...
                        'Run completed with engineering blockers','Icon','warning');
                end
            catch ME
                app.CurrentResults = [];
                app.CurrentRunMeta = struct('status','RUN_FAILED','calculation_status','FAILED_GUI_OR_ENGINE_EXCEPTION', ...
                    'errors',{{struct('identifier',ME.identifier,'message',ME.message)}},'warnings',{{}});
                app.UI.InputValidationText.Text = [ME.identifier ': ' ME.message];
                app.updateStatus('RUN FAILED',[ME.identifier ': ' ME.message],'error');
                app.refreshAll();
                uialert(app.UIFigure,[ME.identifier newline ME.message],'GUI execution error','Icon','error');
            end
            app.IsBusy = false;
            app.UI.RunButton.Enable = 'on';
            app.UI.ResetButton.Enable = 'on';
        end

        function [ok, selectedCase, throughputKgDay, hoursPerDay, message] = validateInputs(app)
            ok = false; selectedCase = []; throughputKgDay = NaN; hoursPerDay = NaN; message = '';
            idx = find(strcmp(app.CaseLabels,app.UI.CaseDropdown.Value),1);
            if isempty(idx)
                message = 'Select a case from the registered case list.';
                return;
            end
            selectedCase = app.CaseRecords(idx);
            value = app.UI.ThroughputEdit.Value;
            if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value) || value<=0
                message = 'Methanol component-equivalent basis must be a positive finite number.';
                return;
            end
            if strcmp(app.UI.ThroughputUnit.Value,'t/day')
                throughputKgDay = unit_conversions(struct('conversion','t_day_to_kg_day','value',value));
            elseif strcmp(app.UI.ThroughputUnit.Value,'kg/day')
                throughputKgDay = value;
            else
                message = 'Unsupported throughput unit. Select kg/day or t/day.';
                return;
            end
            hoursPerDay = app.UI.OperatingHoursEdit.Value;
            if ~isnumeric(hoursPerDay) || ~isscalar(hoursPerDay) || ~isfinite(hoursPerDay) || ...
                    hoursPerDay<=0 || hoursPerDay>24
                message = 'Operating hours must be finite and greater than 0 and no greater than 24 h/day.';
                return;
            end
            ok = true;
            message = sprintf('Inputs valid: %.6g kg/day, %.6g h/day.',throughputKgDay,hoursPerDay);
        end

        function onReset(app)
            app.UI.CaseDropdown.Value = app.labelForCase(app.DefaultCaseId);
            app.UI.ThroughputUnit.Value = 'kg/day';
            app.UI.PreviousThroughputUnit = 'kg/day';
            app.UI.ThroughputEdit.Value = 50000;
            app.UI.OperatingHoursEdit.Value = 24;
            app.CurrentResults = [];
            app.CurrentRunMeta = [];
            app.CurrentReportDirectory = '';
            app.refreshAll();
            app.UI.ExportButton.Enable = 'off';
            app.UI.RunMetaLabel.Text = sprintf('Run ID: none | Model: %s',char(app.Config.model_version));
            app.updateStatus('NOT RUN','Inputs reset to the registered Route C ideal reference basis.','neutral');
            app.UI.InputValidationText.Text = 'Defaults restored.';
        end

        function onExport(app)
            if isempty(app.CurrentRunMeta) || ~isfield(app.CurrentRunMeta,'run_directory') || ...
                    ~isfield(app.CurrentRunMeta,'report_directory')
                uialert(app.UIFigure,'There is no completed run to export.','Export unavailable','Icon','warning');
                return;
            end
            destination = uigetdir(app.ProjectRoot,'Select a destination folder for the run export');
            if isequal(destination,0), return; end
            exportFolder = fullfile(destination,char(app.CurrentRunMeta.run_id));
            if exist(exportFolder,'file')==2 || exist(exportFolder,'dir')==7
                uialert(app.UIFigure,['Export destination already exists: ' exportFolder], ...
                    'Export refused','Icon','error');
                return;
            end
            [ok,msg] = mkdir(exportFolder);
            if ~ok
                uialert(app.UIFigure,['Could not create export folder: ' msg],'Export failed','Icon','error');
                return;
            end
            try
                reportFolder = fullfile(exportFolder,'results');
                outputFolder = fullfile(exportFolder,'run_metadata_and_logs');
                copyfile(app.CurrentRunMeta.report_directory,reportFolder);
                copyfile(app.CurrentRunMeta.run_directory,outputFolder);
                if isfield(app.CurrentRunMeta,'log_json') && exist(app.CurrentRunMeta.log_json,'file')==2
                    copyfile(app.CurrentRunMeta.log_json,fullfile(outputFolder,'project_run_log.json'));
                end
                if isfield(app.CurrentRunMeta,'log_text') && exist(app.CurrentRunMeta.log_text,'file')==2
                    copyfile(app.CurrentRunMeta.log_text,fullfile(outputFolder,'project_run_log.txt'));
                end
                app.UI.ReportStatus.Text = ['Export copied to ' exportFolder];
                uialert(app.UIFigure,['Traceable run export copied to:' newline exportFolder], ...
                    'Export complete','Icon','success');
            catch ME
                uialert(app.UIFigure,[ME.identifier newline ME.message],'Export failed','Icon','error');
            end
        end

        function openUserGuide(app)
            guide = fullfile(app.ProjectRoot,'MATLAB','docs','GUI_User_Guide.md');
            if exist(guide,'file')~=2
                uialert(app.UIFigure,'MATLAB/docs/GUI_User_Guide.md was not found.','Guide unavailable','Icon','warning');
                return;
            end
            try
                if ispc
                    winopen(guide);
                elseif ismac
                    system(['open "' guide '"']);
                else
                    system(['xdg-open "' guide '"']);
                end
            catch ME
                uialert(app.UIFigure,['Could not open guide: ' ME.message],'Guide open failed','Icon','warning');
            end
        end

        function refreshAll(app)
            R = app.CurrentResults;
            app.clearOutputTables();
            if isempty(R) || ~isstruct(R)
                app.setArea(app.UI.ReportFiles,{'No current run results.'});
                if isfield(app.UI,'ReportStatus') && isvalid(app.UI.ReportStatus)
                    app.UI.ReportStatus.Text = 'No numerical result files for the current run.';
                end
                app.refreshReports();
                return;
            end
            if isfield(R,'material') && isfield(R.material,'value') && ...
                    isfield(R.material.value,'tables')
                flowTable = R.material.value.tables.component_flows;
                flowTable.Provenance = repmat({'CALCULATED_FROM_VERSIONED_STOICHIOMETRY'},height(flowTable),1);
                flowTable.Result_Status = repmat({char(R.material.status)},height(flowTable),1);
                elementTable = R.material.value.tables.element_closure;
                elementTable.Provenance = repmat({'CALCULATED_FROM_VERSIONED_REACTION_MATRIX'},height(elementTable),1);
                elementTable.Result_Status = repmat({char(R.material.status)},height(elementTable),1);
                app.setTable(app.UI.StreamTable,flowTable);
                app.setTable(app.UI.ElementTable,elementTable);
                mb = R.material.value.mass_balance;
                app.setArea(app.UI.MassClosureText,{ ...
                    sprintf('Overall component-ledger input: %.12g kg/day',mb.input_kg_day), ...
                    sprintf('Overall component-ledger output: %.12g kg/day',mb.output_kg_day), ...
                    sprintf('Residual (input - output): %.12g kg/day',mb.residual_input_minus_output_kg_day), ...
                    ['Material module status: ' char(R.material.status)]});
            else
                app.setArea(app.UI.MassClosureText,app.blockersFrom(R,'material'));
            end
            if isfield(R,'energy') && isfield(R.energy,'value') && isfield(R.energy.value,'reaction_reference')
                e=R.energy.value; x=e.reaction_reference; u=e.reaction_reference_uncertainty;
                metric={'R-01 standard-state rate';'E-01 thermoneutral reference';'NET-01 standard-state rate'; ...
                    'CO2 sensible pure-gas reference';'Methanol latent reference'};
                value=[x.R01_rate_GJ_day;x.E01_rate_GJ_day;x.net_rate_GJ_day; ...
                    e.co2_sensible_heating.duty_kW;e.methanol_latent_reference.duty_kW];
                units={'GJ/day';'GJ/day';'GJ/day';'kW';'kW'};
                status={'REFERENCE_ONLY';'REFERENCE_ONLY';'REFERENCE_ONLY';'SCREENING_ONLY';'SCREENING_ONLY'};
                provenance={'CALCULATED_FROM_SOURCED_REACTION_THERMOCHEMISTRY'; ...
                    'CALCULATED_FROM_SOURCED_ELECTROLYSIS_THERMOCHEMISTRY'; ...
                    'CALCULATED_STANDARD_STATE_IDENTITY'; ...
                    'CALCULATED_FROM_SOURCED_PURE_COMPONENT_CORRELATION'; ...
                    'CALCULATED_FROM_SOURCED_PURE_COMPONENT_CORRELATION'};
                sigma=[u.R01_rate_sigma_GJ_day;u.E01_rate_sigma_GJ_day;u.net_rate_sigma_GJ_day;NaN;NaN];
                T=table(metric,value,sigma,units,status,provenance,'VariableNames', ...
                    {'Metric','Value','Source_Uncertainty','Units','Status','Provenance'});
                app.setTable(app.UI.EnergyTable,T);
                app.setArea(app.UI.EnergyWarnings,{ ...
                    'These rates are thermochemical / pure-component references, not equipment duties.', ...
                    ['Energy module status: ' char(R.energy.status)], ...
                    'Throughput, model-form and state uncertainty are not included in property uncertainty.'});
            else
                app.setArea(app.UI.EnergyWarnings,app.blockersFrom(R,'energy'));
            end
            app.setArea(app.UI.EntropyText,app.moduleValueLines(R,'entropy', ...
                {'Plant S_gen: BLOCKED (kW/K).','Plant exergy destruction: BLOCKED (kW).','Entropy/exergy closure: BLOCKED.'}));
            if isfield(R,'properties')
                modelRows = {'PR78 mixture / flash',app.requestedStatus(R.properties,'pr78_mixture'); ...
                    'Methanol-water VLE',app.requestedStatus(R.properties,'methanol_water_vle'); ...
                    'Pure-component reference correlations',char(R.properties.status); ...
                    'R-301 kinetics',app.statusOf(R,'reactor'); ...
                    'Physical recycle / purge',app.statusOf(R,'recycle'); ...
                    'Dynamic control simulation','BLOCKED'; ...
                    'Full plant energy closure','BLOCKED'};
                app.setTable(app.UI.ModelStatusTable,cell2table(modelRows,'VariableNames',{'Model_Domain','Status'}));
            end
            if isfield(R,'equipment') && isfield(R.equipment,'value') && ...
                    isfield(R.equipment.value,'datasheet_register')
                app.setTable(app.UI.EquipmentTable,R.equipment.value.datasheet_register);
                hx=R.equipment.value.HX_example; pump=R.equipment.value.W201_pump_example;
                app.setArea(app.UI.EquipmentNotes,{ ...
                    sprintf('HX-A01 illustrative area: %.6g m2 (SCREENING_ONLY)',hx.area_m2), ...
                    sprintf('W-201 illustrative pump shaft power: %.6g kW (SCREENING_ONLY)',pump.shaft_power_kW), ...
                    'These are textbook screening examples with declared assumptions, not actual equipment ratings.', ...
                    ['Equipment module status: ' char(R.equipment.status)]});
            else
                app.setArea(app.UI.EquipmentNotes,app.blockersFrom(R,'equipment'));
            end
            if isfield(R,'utilities') && isfield(R.utilities,'value')
                if isfield(R.utilities.value,'utility_register')
                    app.setTable(app.UI.UtilityTable,R.utilities.value.utility_register);
                end
                if isfield(R.utilities.value,'water') && isfield(R.utilities.value,'oxygen')
                    w=R.utilities.value.water; o=R.utilities.value.oxygen;
                    app.setArea(app.UI.WaterOxygenText,{ ...
                        sprintf('Electrolyser DI-water lower bound: %.6g kg/day',w.electrolyser_DI_water_lower_bound_kg_day), ...
                        sprintf('Reaction water formed: %.6g kg/day',w.reaction_water_formed_kg_day), ...
                        sprintf('Net chemical water consumption: %.6g kg/day',w.net_chemical_water_consumption_kg_day), ...
                        sprintf('Theoretical O2 co-product: %.6g kg/day',o.theoretical_coproduct_kg_day), ...
                        'Water and O2 are stoichiometric reference values, not full utility or by-product balances.'});
                end
            else
                app.setArea(app.UI.WaterOxygenText,app.blockersFrom(R,'utilities'));
            end
            if isfield(R,'environmental') && isfield(R.environmental,'value') && ...
                    isfield(R.environmental.value,'kpi_table')
                app.setTable(app.UI.EnvironmentTable,R.environmental.value.kpi_table);
            end
            app.setArea(app.UI.EconomicsSummary,app.moduleValueLines(R,'economics', ...
                {'CAPEX: BLOCKED (INR).','OPEX: BLOCKED (INR/year).','LCOM: BLOCKED (INR/t MeOH).'}));
            if isfield(R,'control') && isfield(R.control,'value') && ...
                    isfield(R.control.value,'screening_h2_deficit_kg')
                c=R.control.value;
                app.setArea(app.UI.ControlSummary,{ ...
                    ['Control / DB-059 module: ' char(R.control.status)], ...
                    sprintf('Assumed available power fraction: %.6g',c.available_power_fraction), ...
                    sprintf('Assumed disturbance duration: %.6g h',c.duration_s/3600), ...
                    sprintf('Linear-screening H2 deficit: %.6g kg/event',c.screening_h2_deficit_kg), ...
                    'This is not a buffer size, dynamic response, control limit or trip setpoint.'});
            else
                app.setArea(app.UI.ControlSummary,app.blockersFrom(R,'control'));
            end
            if isfield(R,'sensitivity') && isfield(R.sensitivity,'value') && ...
                    isfield(R.sensitivity.value,'stoichiometric_sensitivity')
                T=R.sensitivity.value.stoichiometric_sensitivity;
                app.setTable(app.UI.SensitivityTable,T);
                cla(app.UI.SensitivityAxes);
                bar(app.UI.SensitivityAxes,T.Methanol_t_day,T.CO2_lower_bound_kg_day);
                title(app.UI.SensitivityAxes,'CO2 stoichiometric lower-bound reference');
                xlabel(app.UI.SensitivityAxes,'Methanol component-equivalent basis (t/day)');
                ylabel(app.UI.SensitivityAxes,'CO2 lower bound (kg/day)');
                grid(app.UI.SensitivityAxes,'on');
            else
                cla(app.UI.SensitivityAxes);
                title(app.UI.SensitivityAxes,'Sensitivity not available');
                app.setAreaFromLabel(app.UI.SensitivityNotes,app.blockersFrom(R,'sensitivity'));
            end
            app.refreshReports();
        end

        function refreshReports(app)
            meta = app.CurrentRunMeta;
            if isempty(meta) || ~isstruct(meta)
                app.setArea(app.UI.DiagnosticsText,{'No run diagnostics.'});
                return;
            end
            keys={'run_id','case_id','case_register_id','timestamp_local','run_finished_local', ...
                'matlab_version','matlab_release','model_version','data_version','design_basis_version', ...
                'status','calculation_status','data_integrity','physical_flowsheet_validated', ...
                'prompt21_validation_required'};
            values=cell(numel(keys),1);
            for k=1:numel(keys)
                if isfield(meta,keys{k}) && ~isempty(meta.(keys{k}))
                    values{k}=char(string(meta.(keys{k})));
                else
                    values{k}='N/A';
                end
            end
            app.setTable(app.UI.ReportTable,cell2table([keys(:),values], ...
                'VariableNames',{'Metadata_Field','Value'}));
            detailLines={'RUN INPUT BASIS'};
            if isfield(meta,'input_basis'), detailLines{end+1}=jsonencode(meta.input_basis); end %#ok<AGROW>
            detailLines{end+1}='MODEL ASSUMPTIONS'; %#ok<AGROW>
            if isfield(meta,'assumptions'), detailLines{end+1}=jsonencode(meta.assumptions); end %#ok<AGROW>
            if isfield(meta,'source_hashes'), detailLines{end+1}=['Source hashes: ' jsonencode(meta.source_hashes)]; end %#ok<AGROW>
            detailLines{end+1}='MODULE STATUS'; %#ok<AGROW>
            if isfield(meta,'module_statuses') && isstruct(meta.module_statuses)
                names=fieldnames(meta.module_statuses);
                for k=1:numel(names)
                    detailLines{end+1}=[names{k} ': ' char(meta.module_statuses.(names{k}))]; %#ok<AGROW>
                end
            elseif isfield(meta,'failure_module_ids')
                detailLines{end+1}=['Failed modules: ' strjoin(meta.failure_module_ids,', ')]; %#ok<AGROW>
            end
            detailLines{end+1}='WARNINGS'; %#ok<AGROW>
            if isfield(meta,'warnings') && ~isempty(meta.warnings)
                for k=1:numel(meta.warnings), detailLines{end+1}=char(meta.warnings{k}); end %#ok<AGROW>
            else
                detailLines{end+1}='No run-level warnings recorded.'; %#ok<AGROW>
            end
            detailLines{end+1}='ERRORS'; %#ok<AGROW>
            if isfield(meta,'errors') && ~isempty(meta.errors)
                for k=1:numel(meta.errors)
                    e=meta.errors{k};
                    if isstruct(e) && isfield(e,'identifier') && isfield(e,'message')
                        detailLines{end+1}=[char(e.identifier) ': ' char(e.message)]; %#ok<AGROW>
                    else
                        detailLines{end+1}=char(string(e)); %#ok<AGROW>
                    end
                end
            else
                detailLines{end+1}='No run-level errors recorded.'; %#ok<AGROW>
            end
            app.setArea(app.UI.DiagnosticsText,detailLines);
            if isfield(meta,'exports') && ~isempty(meta.exports)
                app.setArea(app.UI.ReportFiles,meta.exports);
            elseif isfield(meta,'report_directory')
                app.setArea(app.UI.ReportFiles,{ ...
                    ['Report directory: ' char(meta.report_directory)], ...
                    'No numerical export list was returned; inspect status and run logs.'});
            else
                app.setArea(app.UI.ReportFiles,{'No export directory was created for this run.'});
            end
            if isfield(meta,'status')
                app.UI.ReportStatus.Text=['Run state: ' char(meta.status)];
            end
        end

        function clearOutputTables(app)
            names={'StreamTable','ElementTable','EnergyTable','ModelStatusTable','EquipmentTable', ...
                'UtilityTable','EnvironmentTable','SensitivityTable','ReportTable'};
            for k=1:numel(names)
                f=names{k};
                if isfield(app.UI,f) && isvalid(app.UI.(f))
                    app.UI.(f).Data={};
                    app.UI.(f).ColumnName={};
                end
            end
            if isfield(app.UI,'SensitivityAxes') && isvalid(app.UI.SensitivityAxes)
                cla(app.UI.SensitivityAxes);
                title(app.UI.SensitivityAxes,'No current run data');
            end
        end

        function setTable(app, ui, T)
            if isempty(ui) || ~isvalid(ui), return; end
            if istable(T)
                data=table2cell(T);
                for r=1:size(data,1)
                    for c=1:size(data,2)
                        value=data{r,c};
                        if isnumeric(value) && isscalar(value) && ~isfinite(value)
                            data{r,c}='N/A';
                        elseif ismissingValue(value)
                            data{r,c}='N/A';
                        end
                    end
                end
                ui.Data=data;
                ui.ColumnName=T.Properties.VariableNames;
                ui.RowName={};
            elseif iscell(T)
                ui.Data=T;
            else
                ui.Data={};
                ui.ColumnName={};
            end
        end

        function setArea(app, ui, lines)
            if isempty(ui) || ~isvalid(ui), return; end
            if ischar(lines), lines={lines}; end
            if isstring(lines), lines=cellstr(lines(:)); end
            if isempty(lines), lines={'No detail available.'}; end
            ui.Value=lines(:)';
        end

        function setAreaFromLabel(app, ui, lines)
            if isempty(lines), lines={'Not available.'}; end
            ui.Text=strjoin(lines,' ');
        end

        function updateStatus(app, status, message, severity)
            app.UI.StatusLabel.Text=char(status);
            app.UI.StatusMessage.Text=char(message);
            switch char(severity)
                case 'error'
                    app.UI.StatusLabel.BackgroundColor=[0.85 0.25 0.22];
                    app.UI.StatusLabel.FontColor=[1 1 1];
                case 'warning'
                    app.UI.StatusLabel.BackgroundColor=[0.98 0.82 0.45];
                    app.UI.StatusLabel.FontColor=[0.20 0.18 0.12];
                otherwise
                    app.UI.StatusLabel.BackgroundColor=[0.88 0.90 0.92];
                    app.UI.StatusLabel.FontColor=[0.18 0.22 0.26];
            end
        end

        function message = statusMessage(app,meta)
            message='Run finished. Review module statuses and physical blockers.';
            if isfield(meta,'calculation_status')
                message=char(meta.calculation_status);
            end
            if isfield(meta,'errors') && ~isempty(meta.errors)
                e=meta.errors{1};
                if isstruct(e) && isfield(e,'message')
                    message=[message ' | ' char(e.message)];
                end
            elseif isfield(meta,'warnings') && ~isempty(meta.warnings)
                message=[message ' | ' char(meta.warnings{1})];
            end
        end

        function lines = blockersFrom(app,R,moduleName)
            lines={'Result not available.'};
            if isfield(R,moduleName) && isfield(R.(moduleName),'warnings') && ~isempty(R.(moduleName).warnings)
                lines=R.(moduleName).warnings;
            elseif isfield(R,moduleName) && isfield(R.(moduleName),'value') && ...
                    isfield(R.(moduleName).value,'blockers')
                lines=R.(moduleName).value.blockers;
            end
        end

        function lines = moduleValueLines(app,R,moduleName,defaults)
            lines=defaults;
            if isfield(R,moduleName) && isfield(R.(moduleName),'status')
                lines{end+1}=['Module status: ' char(R.(moduleName).status)];
                if isfield(R.(moduleName),'warnings')
                    w=R.(moduleName).warnings;
                    for k=1:numel(w), lines{end+1}=char(w{k}); end %#ok<AGROW>
                end
            end
        end

        function s = statusOf(app,R,moduleName)
            if isfield(R,moduleName) && isfield(R.(moduleName),'status')
                s=char(R.(moduleName).status);
            else
                s='NOT RUN';
            end
        end

        function s = requestedStatus(app,propertyResult,requestName)
            % The engine reports availability through the versioned model policy.
            % An unavailable property request is explicitly marked BLOCKED in the UI.
            s='BLOCKED';
            if strcmp(requestName,'pure_component') && isfield(propertyResult,'status')
                s=char(propertyResult.status);
            end
        end

        function label = labelForCase(app,caseId)
            idx=find(strcmp(app.CaseIds,caseId),1);
            if isempty(idx)
                label=app.CaseLabels{end};
            else
                label=app.CaseLabels{idx};
            end
        end
    end

end

function tf = ismissingValue(value)
tf = false;
try
    tf = ismissing(value);
    if numel(tf)>1, tf=all(tf(:)); end
catch
    tf = isempty(value);
end
end
