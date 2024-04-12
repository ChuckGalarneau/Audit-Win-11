### Fonctions

# Fonction qui demande a l'utilisateur l'ordinateur a auditer, vérifie la communication avec celui-ci et vérifie si l'ordinateur cible est joignable
function PingTarget {
    <#
    .SYNOPSIS  
        Choix de l'ordinateur à auditer et vérification de la communication avec celui-ci
    .DESCRIPTION
        Choix de l'ordinateur à auditer et vérification de la communication avec celui-ci
    .EXAMPLE
        Target -target "Serveur1"
    .NOTES
        Nom du fichier : Audit-cis.psm1
        Auteur : Charles&Flavien
        Date : 02.03.2024
    #>
    param (
        [string]$target
    )
    # Vérification de la joignabilité de l'ordinateur cible 
    if (Test-Connection -ComputerName $target -Count 1 -Quiet) {
        Write-Host "L'ordinateur cible est joignable, continuons..." -ForegroundColor Green
    } else {
        Write-Host "Desole, nous ne pouvons continuer, l'ordinateur n'est pas joignable" -ForegroundColor Red
        Break
    }
}

# Fonction ConnTarget - Connexion à l'ordinateur cible
function ConnTarget {
    <#
    .SYNOPSIS  
        Connexion à l'ordinateur cible
    .DESCRIPTION
        Connexion à l'ordinateur cible
    .EXAMPLE
        ConnTarget -target "Serveur1"
    .NOTES
        Nom du fichier : Audit-cis.psm1
        Auteur : Charles&Flavien
        Date : 02.03.2024
    #>
    param (
        [string]$target
    )
    # Vérification si une session est déjà ouverte
    $isSessionOpen = (get-pssession | Where-Object State -eq "Opened" | Where-Object ComputerName -eq $target | measure).Count

    # Si une session est déjà ouverte, on se connecte à cette session
    if ($isSessionOpen -gt 0) {
        # Récupération de la session ouverte pour l'ordinateur cible
        $sessionInUse = (get-pssession | Where-Object State -eq "Opened" | Where-Object ComputerName -eq $target)[0]
        # Mise en variable : Connection à la session ouverte
        $session = Enter-PSSession -Session $sessionInUse
        # Affichage de la réussite de la connexion
        Write-Host "Connexion a l'ordinateur" $target "a reussi" -ForegroundColor Green
        Write-Host "L'audit peut commencer" -ForegroundColor Green
        # Connexion à la session ouverte
        return $session
    }

    # Si aucune session n'est ouverte, on demande les credentials administrateurs de l'ordinateur cible, et on se connecte à l'ordinateur cible
    else {

        # Demander les credentials administrateurs de l'ordinateur cible
        Write-Host "Entrez les credentials administrateurs de l'ordinateur cible" $target  -ForegroundColor Blue
        # Récupération des credentials
        $credential = Get-Credential
        # Création de la session pour l'ordinateur cible
        $session = New-PSSession -ComputerName $target -Credential $credential -ErrorAction SilentlyContinue
            if ($session -eq $null) {
                Write-Host "La connexion a l'ordinateur" $target "a echoue" -ForegroundColor Red
                Break
            }
            else {
                # Affichage de la réussite de la connexion
                Write-Host "La connexion a l'ordinateur" $target "a reussi" -ForegroundColor Green
                Write-Host "L'audit peut commencer" -ForegroundColor Green
                # Connexion à la session créée
                return Enter-PSSession -Session $session
            }
    }
}

# Fonction PasswordPolicy1 - Audit de la partie 1.1.1 du CIS Benchmark Password Policy
function PasswordPolicy1 {
    <#
    .SYNOPSIS  
        Audit de la partie 1.1.1 du CIS Benchmark Password Policy
    .DESCRIPTION
        Audit de la partie 1.1.1 du CIS Benchmark Password Policy
    .EXAMPLE
        PasswordPolicy1
    .NOTES
        Nom du fichier : Audit-cis.psm1
        Auteur : Charles&Flavien
        Date : 02.03.2024
    #>
    # Ecrit le titre du contrôle d'audit
    Write-Host "1.1.1 - Ensure 'Enforce password history' is set to '24 or more password(s)'" -ForegroundColor Yellow
    # Récupère la valeur de la stratégie de mot de passe
    $value = (Get-ADDefaultDomainPasswordPolicy).PasswordHistoryCount
    # Si la valeur de la stratégie de mot de passe est supérieure ou égale à 24, le contrôle est réussi
    if ($value -ge 24) {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Green
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "------------------------" -ForegroundColor Green
        # Retourne le résultat du contrôle dans une variable
        $result111 = "SUCCESS"
    }
    # Sinon, le contrôle est échoué
    else {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Red
        Write-Host "FAILURE" -ForegroundColor Red
        Write-Host "------------------------" -ForegroundColor Red
        # Retourne le résultat du contrôle dans une variable
        $result111 = "FAILURE"
    }
}

# Fonction PasswordPolicy2 - Audit de la partie 1.1.2 du CIS Benchmark Password Policy
function PasswordPolicy2 {
    <#
    .SYNOPSIS  
        Audit de la partie 1.1.2 du CIS Benchmark Password Policy
    .DESCRIPTION
        Audit de la partie 1.1.2 du CIS Benchmark Password Policy
    .EXAMPLE
        PasswordPolicy2
    .NOTES
        Nom du fichier : Audit-cis.psm1
        Auteur : Charles&Flavien
        Date : 02.03.2024
    #>
    # Ecrit le titre du contrôle d'audit
    Write-Host "1.1.2 - Ensure 'Maximum password age' is set to '365 or fewer days, but not 0'" -ForegroundColor Yellow
    # Importation du module ActiveDirectory
    Import-Module ActiveDirectory
    # Récupère la valeur de la stratégie de mot de passe
    $value = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
    # Si la valeur de la stratégie de mot de passe est inférieure ou égale à 365 et différente de 0, le contrôle est réussi
    if ($value -le 365 -and $value -ne 0) {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Green
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "------------------------" -ForegroundColor Green
        # Retourne le résultat du contrôle dans une variable
        $result112 = "SUCCESS"
    }
    # Sinon, le contrôle est échoué
    else {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Red
        Write-Host "FAILURE" -ForegroundColor Red
        Write-Host "------------------------" -ForegroundColor Red
        # Retourne le résultat du contrôle dans une variable
        $result112 = "FAILURE"
    }
}


# Fonction NetworkSecurity1 - Audit de la partie 2.3.11.1 du CIS Benchmark Network Security
function NetworkSecurity1 {
    
    # Ecrit le titre du contrôle d'audit
    Write-Host "2.3.11.1 - Allow Local System to use computer identity for NTLM is set to Enabled :" -ForegroundColor Yellow
    # Récupère la valeur de la clé de registre UseMachineId
    $exist = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\" | Select-Object -ExpandProperty UseMachineId) 
    # Si la valeur de la clé de registre est 1, le contrôle est réussi
    if ($exist -eq 1) {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Green
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "------------------------" -ForegroundColor Green
        # Retourne le résultat du contrôle dans une variable
        $result23111 = "SUCCESS"
    }
    # Sinon, le contrôle est échoué
    else {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Red
        Write-Host "FAILURE" -ForegroundColor Red
        Write-Host "------------------------" -ForegroundColor Red
        # Retourne le résultat du contrôle dans une variable
        $result23111 = "FAILURE"
    }
}

# Fonction NetworkSecurity2 - Audit de la partie 2.3.11.2 du CIS Benchmark Network Security
function NetworkSecurity2 {
    
    # Ecrit le titre du contrôle d'audit
    Write-Host "2.3.11.2 - Allow LocalSystem NULL session fallback is set to 'Disabled'" -ForegroundColor Yellow
    # Récupère la valeur de la clé de registre AllowNullSessionFallback
    $exist = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\" | Select-Object -ExpandProperty AllowNullSessionFallback) 
    # Si la valeur de la clé de registre est 0, le contrôle est réussi
    if ($exist -eq 0) {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Green
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "------------------------" -ForegroundColor Green
        # Retourne le résultat du contrôle dans une variable
        $result23112 = "SUCCESS"
    }
    # Sinon, le contrôle est échoué
    else {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Red
        Write-Host "FAILURE" -ForegroundColor Red
        Write-Host "------------------------" -ForegroundColor Red
        # Retourne le résultat du contrôle dans une variable
        $result23112 = "FAILURE"
    }

}

# Fonction NetworkSecurity3 - Audit de la partie 2.3.11.3 du CIS Benchmark Network Security
function NetworkSecurity3 {
    
    # Ecrit le titre du contrôle d'audit
    Write-Host "2.3.11.3 - Allow PKU2U authentication requests to this computer to use online identities' is set to 'Disabled'" -ForegroundColor Yellow
    # Récupère la valeur de la clé de registre AllowOnlineID
    $exist = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" | Select-Object -ExpandProperty AllowOnlineID) 
    # Si la valeur de la clé de registre est 0, le contrôle est réussi
    if ($exist -eq 0) {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Green
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "------------------------" -ForegroundColor Green
        # Retourne le résultat du contrôle dans une variable
        $result23113 = "SUCCESS"
    }
    # Sinon, le contrôle est échoué
    else {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Red
        Write-Host "FAILURE" -ForegroundColor Red
        Write-Host "------------------------" -ForegroundColor Red
        # Retourne le résultat du contrôle dans une variable
        $result23113 = "FAILURE"
    }

}

# Fonction Bitlocker1 - Audit de la partie 18.10.9.1.1 du CIS Benchmark Bitlocker
function Bitlocker1 {
    # Ecrit le titre du contrôle d'audit
    Write-Host "18.10.9.1.1 - Allow access to BitLocker-protected fixed data drives from earlier versions of Windows' is set to 'Disabled" -ForegroundColor Yellow
    # Récupère la valeur de la clé de registre AllowOnlineID
    $exist = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" | Select-Object -ExpandProperty FDVDiscoveryVolumeType) 
    # Si la valeur de la clé de registre est 1, le contrôle est réussi
    if ($exist -eq 1) {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Green
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "------------------------" -ForegroundColor Green
        # Retourne le résultat du contrôle dans une variable
        $result1810911 = "SUCCESS"
    }
    # Sinon, le contrôle est échoué
    else {
        # Affiche le résultat du contrôle
        Write-Host "------------------------" -ForegroundColor Red
        Write-Host "FAILURE" -ForegroundColor Red
        Write-Host "------------------------" -ForegroundColor Red
        # Retourne le résultat du contrôle dans une variable
        $result1810911 = "FAILURE"
    }
}

### Processus d'audit

# Définit le niveau de verbosité des erreurs
    $Err = "SilentlyContinue"

# Demande a l'utilisateur le nom de la machine à auditer
    Write-Host "Entrez le nom de l'ordinateur cible :" -ForegroundColor Blue

# Récupère le nom rentrer pour le mettre dans la variable $target
    $target = Read-Host

#Exécute la fonction PingTarget avec le nom de la machine à auditer
    PingTarget -target $target

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Si l'ordinateur est joignable, on continue l'audit
# Exécute la fonction ConnTarget pour se connecter à l'ordinateur cible
    ConnTarget -target $target

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Exécute la fonction PasswordPolicy1 qui correspond au premier contrôle de la partie PasswordPolicy, sans afficher les erreurs
    PasswordPolicy1 -ErrorAction $Err

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Exécute la fonction PasswordPolicy2 qui correspond au deuxième contrôle de la partie PasswordPolicy, sans afficher les erreurs
    PasswordPolicy2 -ErrorAction $Err

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Exécute la fonction NetworkSecurity1 qui correspond au premier contrôle de la partie NetworkSecurity, sans afficher les erreurs
    NetworkSecurity1 -ErrorAction $Err

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Exécute la fonction NetworkSecurity2 qui correspond au deuxième contrôle de la partie NetworkSecurity, sans afficher les erreurs
    NetworkSecurity2 -ErrorAction $Err

 # Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Exécute la fonction NetworkSecurity2 qui correspond au deuxième contrôle de la partie NetworkSecurity, sans afficher les erreurs
    NetworkSecurity3 -ErrorAction $ErrorActionPreference

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Exécute la fonction NetworkSecurity2 qui correspond au deuxième contrôle de la partie NetworkSecurity, sans afficher les erreurs
    Bitlocker1 -ErrorAction $ErrorActionPreference

# Exécute une pause de deux secondes
    Start-Sleep -Seconds 2

# Ecrit le titre de la fin de l'audit
 Write-Host "Fin de l'audit" -ForegroundColor Green

 # Fin de la session
    Exit-PSSession