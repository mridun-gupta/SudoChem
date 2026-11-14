# Configuration index

Runtime configuration remains next to its owning application to preserve package-relative paths:

- MATLAB: `MATLAB/project_config.json` and `MATLAB/data/*.json`
- Python package: `Python/pyproject.toml`, `Python/requirements.lock`, `Python/data/`
- Controlled raw source inputs and schemas: `data/raw/`, `data/reference/`, `data/schemas/`

Do not move these files independently. Use the entire repository root when extracting the package.
