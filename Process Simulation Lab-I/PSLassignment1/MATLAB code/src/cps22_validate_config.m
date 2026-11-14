function report = cps22_validate_config(cfg)
% Validate dimensions and physical input constraints before any calculation.
errors = strings(0,1); warnings = strings(0,1);
if numel(cfg.components) ~= 2
    errors(end+1) = "This implementation supports exactly the approved binary ethanol-water benchmark.";
end
if numel(cfg.components) == 2
    if ~strcmpi(cfg.components(1).name, 'Ethanol') || ~strcmpi(cfg.components(2).name, 'Water')
        errors(end+1) = "Component order is fixed as ethanol (1), water (2); reorder all data consistently before changing it.";
    end
    for iComp = 1:2
        c = cfg.components(iComp);
        if ~isfinite(c.MW_kg_mol) || c.MW_kg_mol <= 0 || ...
                ~isfinite(c.Tc_K) || c.Tc_K <= 0 || ...
                ~isfinite(c.Pc_Pa) || c.Pc_Pa <= 0 || ~isfinite(c.omega)
            errors(end+1) = "Component molecular weight, critical properties and acentric factor must be finite and physically bounded.";
            break
        end
    end
end
if ~isfinite(cfg.feed.flow_kmol_h) || cfg.feed.flow_kmol_h <= 0
    errors(end+1) = "Feed flow must be finite and greater than zero.";
end
z = cfg.feed.z(:);
if numel(z) ~= numel(cfg.components) || any(~isfinite(z)) || any(z < 0) || any(z > 1)
    errors(end+1) = "Feed composition must contain one mole fraction per component in [0,1].";
elseif abs(sum(z)-1) > 1e-10
    errors(end+1) = "Feed mole fractions must sum to one within 1e-10; they are not silently normalized.";
end
if ~isfinite(cfg.conditions.temperature_K) || cfg.conditions.temperature_K <= 0
    errors(end+1) = "Temperature must be finite and greater than zero K.";
end
if ~isfinite(cfg.conditions.pressure_Pa) || cfg.conditions.pressure_Pa <= 0
    errors(end+1) = "Pressure must be finite and greater than zero Pa.";
end
if numel(cfg.model.nrtl.a_ij) ~= 4 || ~isequal(size(cfg.model.nrtl.a_ij), [2 2])
    errors(end+1) = "NRTL a_ij must be a 2-by-2 matrix.";
end
if ~isequal(size(cfg.model.nrtl.b_ij_K), [2 2]) || ~isequal(size(cfg.model.nrtl.alpha_ij), [2 2])
    errors(end+1) = "NRTL b_ij_K and alpha_ij must be 2-by-2 matrices.";
end
if isequal(size(cfg.model.nrtl.a_ij),[2 2]) && isequal(size(cfg.model.nrtl.b_ij_K),[2 2]) && isequal(size(cfg.model.nrtl.alpha_ij),[2 2])
    if any(~isfinite(cfg.model.nrtl.a_ij(:))) || any(~isfinite(cfg.model.nrtl.b_ij_K(:))) || any(~isfinite(cfg.model.nrtl.alpha_ij(:))) || any(cfg.model.nrtl.alpha_ij(:)<0)
        errors(end+1) = "NRTL parameters must be finite and non-randomness factors nonnegative.";
    end
end
if isequal(size(cfg.model.nrtl.a_ij),[2 2]) && isequal(size(cfg.model.nrtl.b_ij_K),[2 2]) && isequal(size(cfg.model.nrtl.alpha_ij),[2 2])
    if any(abs(diag(cfg.model.nrtl.a_ij)) > 1e-12) || ...
            any(abs(diag(cfg.model.nrtl.b_ij_K)) > 1e-12) || ...
            any(abs(diag(cfg.model.nrtl.alpha_ij)) > 1e-12)
        errors(end+1) = "NRTL self-interaction diagonal convention requires a_ii=b_ii=alpha_ii=0.";
    end
end
if ~isequal(size(cfg.model.srk.kij_matrix), [2 2])
    errors(end+1) = "SRK kij_matrix must be 2-by-2.";
elseif any(~isfinite(cfg.model.srk.kij_matrix(:)))
    errors(end+1) = "SRK kij entries must be finite.";
else
    kij = cfg.model.srk.kij_matrix;
    if any(any(abs(kij-kij.') > 1e-12))
        errors(end+1) = "SRK binary interaction matrix must be symmetric for the selected mixing rule.";
    end
    if any(abs(diag(kij)) > 1e-12)
        errors(end+1) = "SRK kij diagonal entries must be zero.";
    end
end
if numel(cfg.saturation_correlations) ~= 2
    errors(end+1) = "One saturation-pressure correlation per component is required.";
elseif numel(cfg.components) == 2
    for iComp = 1:2
        if ~strcmpi(cfg.saturation_correlations(iComp).component, cfg.components(iComp).name)
            errors(end+1) = "Saturation-pressure correlations must follow the fixed component order: ethanol then water.";
            break
        end
    end
end
report = struct('valid', isempty(errors), 'errors', errors, 'warnings', warnings);
if isempty(errors)
    % Candidate interaction parameters are not accepted merely because inputs validate.
    if ~cfg.model.parameters_accepted
        warnings(end+1) = "NRTL-SRK model parameters are explicitly marked not accepted for predictive use.";
    end
    % Use segmented NIST SRD 69 Antoine correlations; the active range is
    % checked against the actual component-specific published segments.
    try
        cps22_antoine_psat(cfg.conditions.temperature_K, cfg);
    catch ME
        errors(end+1) = string(ME.message);
    end
    report.valid = isempty(errors);
    report.errors = errors;
    report.warnings = warnings;
end
end
