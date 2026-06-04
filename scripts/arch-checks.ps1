# Architecture Checks Configuration (PowerShell) — mirrors arch-checks.conf.
# Dot-sourced by the check-*.ps1 scripts. Patterns are .NET regex.

# check-architecture.ps1 — layer hierarchy
$PagePattern    = 'web/src/app/.*page\.tsx$'
$RoutePattern   = 'api/Endpoints/.*\.cs$'
$ServicePattern = 'api/Services/.*Service\.cs$'

# Forbidden imports per layer (arrays of single-token regex patterns)
$PageForbidden    = @('@/lib/services', '@/lib/repositories', '@/lib/db')
$RouteForbidden   = @('Api\.Repositories', 'Api\.Data')
$ServiceForbidden = @('Api\.Data')

# check-validators.ps1 — validator location
$SchemaLocation      = 'api/Validation/'
$SchemaCheckRoutes   = 'api/Endpoints'
$SchemaCheckServices = 'api/Services'

# check-deep-architecture.ps1 — advanced checks
$RepoLayerPath     = 'api/Repositories'
$HttpModulePaths   = @('Microsoft\.AspNetCore', 'Api\.Http')
$RoutesPath        = 'api/Endpoints'
$ServicesPath      = 'api/Services'
$GenericThrow      = 'throw new Exception('
$RepoImportPattern = 'Api\.Repositories'
