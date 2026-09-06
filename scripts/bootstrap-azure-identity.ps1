#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [guid]$SubscriptionId,

    [Parameter(Mandatory)]
    [guid]$TenantId,

    [ValidatePattern('^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')]
    [string]$GitHubRepository = 'WiktorL123/devops-lab',

    [ValidatePattern('^[1-9][0-9]*$')]
    [string]$GitHubOwnerId = '123184089',

    [ValidatePattern('^[1-9][0-9]*$')]
    [string]$GitHubRepositoryId = '1346681774',

    [ValidatePattern('^[A-Za-z0-9_.-]+$')]
    [string]$GitHubEnvironment = 'dev',

    [ValidateSet('polandcentral')]
    [string]$Location = 'polandcentral',

    [ValidatePattern('^[A-Za-z0-9._()\-]+$')]
    [string]$ResourceGroupName = 'rg-devopslab-dev-polandcentral',

    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
}
catch {
    # Output still works in hosts that do not allow changing console encoding.
}

$issuer = 'https://token.actions.githubusercontent.com'
$audience = 'api://AzureADTokenExchange'
$repositoryParts = $GitHubRepository -split '/', 2
$immutableRepository = "$($repositoryParts[0])@${GitHubOwnerId}/$($repositoryParts[1])@${GitHubRepositoryId}"
$subject = "repo:${immutableRepository}:environment:${GitHubEnvironment}"
$federatedCredentialName = "github-${GitHubEnvironment}"

$identityNames = @(
    'id-gh-tf-plan-dev',
    'id-gh-tf-apply-dev',
    'id-gh-frontend-deploy-dev',
    'id-gh-backend-deploy-dev'
)

# Built-in role IDs are stable across Microsoft Entra tenants.
$roleIds = [ordered]@{
    Reader                                  = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    Contributor                             = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    'Role Based Access Control Administrator' = 'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
    'Container Registry Repository Writer'  = '2a1e307c-b015-4ebd-883e-5b7698a07328'
    'Container Registry Repository Reader'  = 'b93aa761-3e63-49ed-ac28-beffa264f7ac'
    AcrPush                                 = '8311e382-0749-4cb8-b61a-304f252e45ec'
    AcrPull                                 = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    'Container Apps Contributor'             = '358470bc-b998-42bd-ab17-a7e34c199c0f'
    'Container Apps Jobs Operator'           = 'b9a307c4-5aa3-4b52-ba60-2b17c136cd7b'
    'Key Vault Secrets User'                 = '4633458b-17de-408a-b874-0445c86b69e6'
    'Key Vault Secrets Officer'              = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
}

$changes = [System.Collections.Generic.List[object]]::new()
$identityResults = [System.Collections.Generic.List[object]]::new()
$federationResults = [System.Collections.Generic.List[object]]::new()
$roleResults = [System.Collections.Generic.List[object]]::new()

function Write-Banner {
    Write-Host ''
    Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Magenta
    Write-Host '║  🚀 devops-lab · Azure identity bootstrap · Stage 4       ║' -ForegroundColor Magenta
    Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Magenta
    Write-Host ''
}

function Write-Step {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Cyan
}

function Invoke-AzureCli {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $output = & az @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI failed: az $($Arguments -join ' ')"
    }

    return ($output -join "`n")
}

function Invoke-AzureCliJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $json = Invoke-AzureCli -Arguments ($Arguments + @('--output', 'json', '--only-show-errors'))
    if ([string]::IsNullOrWhiteSpace($json)) {
        return $null
    }

    return $json | ConvertFrom-Json
}

function Add-Change {
    param(
        [Parameter(Mandatory)][string]$Type,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][string]$Details
    )

    $changes.Add([pscustomobject]@{
            Type    = $Type
            Name    = $Name
            Action  = $Action
            Details = $Details
        })
}

function Ensure-RoleAssignment {
    param(
        [Parameter(Mandatory)][string]$PrincipalId,
        [Parameter(Mandatory)][string]$PrincipalName,
        [Parameter(Mandatory)][string]$RoleName,
        [Parameter(Mandatory)][string]$Scope,
        [string]$Condition
    )

    $existing = Invoke-AzureCliJson -Arguments @(
        'role', 'assignment', 'list',
        '--assignee-object-id', $PrincipalId,
        '--scope', $Scope,
        '--role', $roleIds[$RoleName],
        '--query', '[0]'
    )

    if ($null -ne $existing) {
        if ($Condition -and $existing.condition -ne $Condition) {
            throw "Existing '$RoleName' assignment for '$PrincipalName' has a different or missing condition. Refusing to overwrite it."
        }

        $roleResults.Add([pscustomobject]@{
                Principal = $PrincipalName
                Role      = $RoleName
                Scope     = $Scope
                Action    = 'existing'
            })
        Add-Change -Type 'RBAC' -Name "$PrincipalName → $RoleName" -Action 'existing' -Details $Scope
        return
    }

    $arguments = @(
        'role', 'assignment', 'create',
        '--assignee-object-id', $PrincipalId,
        '--assignee-principal-type', 'ServicePrincipal',
        '--role', $roleIds[$RoleName],
        '--scope', $Scope,
        '--description', "devops-lab Stage 4 bootstrap: $PrincipalName"
    )

    if ($Condition) {
        $arguments += @('--condition', $Condition, '--condition-version', '2.0')
    }

    $null = Invoke-AzureCliJson -Arguments $arguments
    $roleResults.Add([pscustomobject]@{
            Principal = $PrincipalName
            Role      = $RoleName
            Scope     = $Scope
            Action    = 'created'
        })
    Add-Change -Type 'RBAC' -Name "$PrincipalName → $RoleName" -Action 'created' -Details $Scope
}

Write-Banner

Write-Step 'Checking local tools and authenticated Azure context'
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw 'Azure CLI was not found in PATH.'
}

$account = Invoke-AzureCliJson -Arguments @('account', 'show')
if ($account.tenantId -ne $TenantId.ToString()) {
    throw "Wrong tenant. Expected '$TenantId', active tenant is '$($account.tenantId)'."
}
if ($account.id -ne $SubscriptionId.ToString()) {
    throw "Wrong subscription. Expected '$SubscriptionId', active subscription is '$($account.id)'."
}
if ($account.state -ne 'Enabled') {
    throw "Subscription '$($account.name)' is not enabled (state: $($account.state))."
}

Write-Host "   ✅ Tenant:       $TenantId" -ForegroundColor Green
Write-Host "   ✅ Subscription: $($account.name) ($SubscriptionId)" -ForegroundColor Green
Write-Host "   ✅ GitHub OIDC:  $subject" -ForegroundColor Green
Write-Host "   ✅ Scope:        /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName" -ForegroundColor Green

Write-Host ''
Write-Host 'Planned Azure objects:' -ForegroundColor Yellow
Write-Host "  • resource group: $ResourceGroupName ($Location)"
foreach ($identityName in $identityNames) {
    Write-Host "  • managed identity: $identityName"
    Write-Host "    federated credential: $federatedCredentialName → $subject"
}
Write-Host '  • Reader: id-gh-tf-plan-dev at application resource-group scope'
Write-Host '  • Contributor: id-gh-tf-apply-dev at application resource-group scope'
Write-Host '  • constrained RBAC Administrator: id-gh-tf-apply-dev at application resource-group scope'

if (-not $Execute) {
    Write-Host ''
    Write-Host '🧭 Preview complete. Nothing was changed.' -ForegroundColor Yellow
    Write-Host 'Run again with -Execute only after reviewing this plan.' -ForegroundColor Yellow
    return
}

Write-Step "Ensuring resource group '$ResourceGroupName'"
$groupExists = Invoke-AzureCli -Arguments @('group', 'exists', '--name', $ResourceGroupName, '--output', 'tsv', '--only-show-errors')
if ($groupExists.Trim() -eq 'true') {
    $resourceGroup = Invoke-AzureCliJson -Arguments @('group', 'show', '--name', $ResourceGroupName)
    Add-Change -Type 'Resource group' -Name $ResourceGroupName -Action 'existing' -Details $resourceGroup.id
}
else {
    $resourceGroup = Invoke-AzureCliJson -Arguments @(
        'group', 'create',
        '--name', $ResourceGroupName,
        '--location', $Location,
        '--tags', 'project=devopslab', 'environment=dev', 'managed-by=bootstrap'
    )
    Add-Change -Type 'Resource group' -Name $ResourceGroupName -Action 'created' -Details $resourceGroup.id
}

$resourceGroupScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"

Write-Step 'Ensuring GitHub user-assigned managed identities'
foreach ($identityName in $identityNames) {
    $identity = Invoke-AzureCliJson -Arguments @(
        'identity', 'list',
        '--resource-group', $ResourceGroupName,
        '--query', "[?name=='$identityName'] | [0]"
    )

    $identityAction = 'existing'
    if ($null -eq $identity) {
        $identity = Invoke-AzureCliJson -Arguments @(
            'identity', 'create',
            '--name', $identityName,
            '--resource-group', $ResourceGroupName,
            '--location', $Location,
            '--tags', 'project=devopslab', 'environment=dev', 'managed-by=bootstrap', 'purpose=github-oidc'
        )
        $identityAction = 'created'
    }

    $identityResults.Add([pscustomobject]@{
            Name        = $identityName
            ClientId    = $identity.clientId
            PrincipalId = $identity.principalId
            Action      = $identityAction
        })
    Add-Change -Type 'Managed identity' -Name $identityName -Action $identityAction -Details "clientId=$($identity.clientId)"

    $existingCredential = Invoke-AzureCliJson -Arguments @(
        'identity', 'federated-credential', 'list',
        '--identity-name', $identityName,
        '--resource-group', $ResourceGroupName,
        '--query', "[?name=='$federatedCredentialName'] | [0]"
    )

    $credentialAction = 'existing'
    if ($null -eq $existingCredential) {
        $existingCredential = Invoke-AzureCliJson -Arguments @(
            'identity', 'federated-credential', 'create',
            '--name', $federatedCredentialName,
            '--identity-name', $identityName,
            '--resource-group', $ResourceGroupName,
            '--issuer', $issuer,
            '--subject', $subject,
            '--audiences', $audience
        )
        $credentialAction = 'created'
    }
    elseif (
        $existingCredential.issuer -ne $issuer -or
        $existingCredential.subject -ne $subject -or
        $audience -notin $existingCredential.audiences
    ) {
        throw "Federated credential '$federatedCredentialName' on '$identityName' exists with different values. Refusing to overwrite it."
    }

    $federationResults.Add([pscustomobject]@{
            Identity = $identityName
            Name     = $federatedCredentialName
            Subject  = $subject
            Action   = $credentialAction
        })
    Add-Change -Type 'Federated credential' -Name "$identityName/$federatedCredentialName" -Action $credentialAction -Details $subject
}

Write-Step 'Ensuring least-privilege bootstrap role assignments'
$planIdentity = $identityResults | Where-Object Name -eq 'id-gh-tf-plan-dev'
$applyIdentity = $identityResults | Where-Object Name -eq 'id-gh-tf-apply-dev'

Ensure-RoleAssignment `
    -PrincipalId $planIdentity.PrincipalId `
    -PrincipalName $planIdentity.Name `
    -RoleName 'Reader' `
    -Scope $resourceGroupScope

Ensure-RoleAssignment `
    -PrincipalId $applyIdentity.PrincipalId `
    -PrincipalName $applyIdentity.Name `
    -RoleName 'Contributor' `
    -Scope $resourceGroupScope

$delegableRoleIds = @(
    $roleIds.Reader,
    $roleIds['Container Registry Repository Writer'],
    $roleIds['Container Registry Repository Reader'],
    $roleIds.AcrPush,
    $roleIds.AcrPull,
    $roleIds['Container Apps Contributor'],
    $roleIds['Container Apps Jobs Operator'],
    $roleIds['Key Vault Secrets User'],
    $roleIds['Key Vault Secrets Officer']
)
$roleIdSet = $delegableRoleIds -join ', '
$rbacCondition = "((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {$roleIdSet} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal'})) AND ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {$roleIdSet} AND @Resource[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal'}))"

Ensure-RoleAssignment `
    -PrincipalId $applyIdentity.PrincipalId `
    -PrincipalName $applyIdentity.Name `
    -RoleName 'Role Based Access Control Administrator' `
    -Scope $resourceGroupScope `
    -Condition $rbacCondition

Write-Host ''
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Magenta
Write-Host '║  🎆 BOOTSTRAP COMPLETE — identity fireworks deployed! 🎆  ║' -ForegroundColor Magenta
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Magenta
Write-Host ''

Write-Host '📦 Objects processed' -ForegroundColor Cyan
$changes | Format-Table Type, Name, Action -AutoSize

Write-Host '🪪 GitHub identity configuration values' -ForegroundColor Cyan
$identityResults | Format-Table Name, ClientId, PrincipalId, Action -AutoSize

Write-Host '🔗 Federated credentials' -ForegroundColor Cyan
$federationResults | Format-Table Identity, Name, Subject, Action -AutoSize

Write-Host '🔐 Role assignments' -ForegroundColor Cyan
$roleResults | Format-Table Principal, Role, Action -AutoSize

Write-Host '✅ No client secret was created.' -ForegroundColor Green
Write-Host '✅ No paid Azure service was created.' -ForegroundColor Green
Write-Host '⚠️  Save the client IDs as GitHub environment variables only in a separately approved change.' -ForegroundColor Yellow
