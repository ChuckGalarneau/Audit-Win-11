# Fonction pour vérifier qu'un NAS est valide avec l'algorithme de Luhn
function Test-NAS {
    param(
        [string]$NAS
    )
    if ($NAS -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
        return $true
    } else {
        return $false
    }
}

# Nettoyer le NAS en entrée
function Clean-NAS {
    param(
        [string]$NAS
    )
    $NAS = $NAS -replace "\.|\s+|\-", ""
    return $NAS
}

# Demander le NAS

$NAS = Read-Host "Quel est le NAS a verifier ?"

# Nettoyer le NAS
$NAS = Clean-NAS $NAS

# Vérifier le NAS
Test-NAS $NAS