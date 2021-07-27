# Author: Alejandro López - 2021
# GitHub: https://github.com/Alopezfu/win-ssh-copy-id

function spawnBanner {

    Clear-Host;
    Write-Host -ForegroundColor Green "    __          ___          _____     _        _____                    _____    _
    \ \        / (_)        / ____|   | |      / ____|                  |_   _|  | |
     \ \  /\  / / _ _ __   | (___  ___| |__   | |     ___  _ __  _   _    | |  __| |
      \ \/  \/ / | | '_ \   \___ \/ __| '_ \  | |    / _ \| '_ \| | | |   | | / _` |
       \  /\  /  | | | | |  ____) \__ \ | | | | |___| (_) | |_) | |_| |  _| || (_| |
        \/  \/   |_|_| |_| |_____/|___/_| |_|  \_____\___/| .__/ \__, | |_____\__,_|
                                                          | |     __/ |
               Author: github.com/alopezfu                |_|    |___/

";
}

function help {
    spawnBanner;
    Write-Host -ForegroundColor DarkCyan "Usage: .\ssh-copy-id.ps1 [OPTIONS]

Options:
  -h, --host    Set remote hostname or IP.
  -u, --user    Set remote username.
  -p, --port    Set remote port with '' (If not set default value is 22).
  --help        Show help.

Examples:
  .\ssh-copy-id.ps1 --host srv0.mydoamin.com --user admin --port '25'
  .\ssh-copy-id.ps1 -h srv0.myanotherdoamin.com -u pepe
  "

}

function checkInput($options) {

    if (($options[0] -and $options[0] -eq "-h" -or $options[0] -eq "--host" -and $options[1]::IsNullOrEmpty) -and
        ($options[2] -and $options[2] -eq "-u" -or $options[2] -eq "--user" -and $options[3]::IsNullOrEmpty)) {

        $hostname = $options[1];
        $username = $options[3];

        if ($options[4] -and $options[4] -eq "-p" -or $options[4] -eq "--port" -and $options[5]::IsNullOrEmpty) {

            $port = $options[5];
        }
        else {

            $port = "22";
        }
    }
    else {

        help;
        exit 1;
    }

    $out = @($hostname, $username, $port);

    return $out;

}

function publicKey {

    spawnBanner;
    if (!Test-Path $env:USERPROFILE\.ssh\id_rsa) {

        Write-Host -NoNewline -ForegroundColor Yellow "[*] "
        Write-Host -NoNewline -ForegroundColor DarkCyan "You need create a public key. Generate now? (yes/no): "
        $q = Read-Host;
        spawnBanner;
        Write-Host -NoNewline -ForegroundColor Yellow "[*] "
        Write-Host -ForegroundColor DarkCyan "Generate public key..."
        if ($q -eq "yes") {

            mkdir $env:USERPROFILE\.ssh\ 2>&1> $null
            ssh-keygen -f "$env:USERPROFILE\.ssh\id_rsa"
        }
    }
}

function configHost($data) {

    spawnBanner;
    Write-Host -NoNewline -ForegroundColor Yellow "[*] "
    Write-Host -ForegroundColor DarkCyan "Config remote ssh..."
    $hostname = $data[0];
    $username = $data[1];
    $port = $data[2];
    scp -o StrictHostKeyChecking=no -P $port $env:USERPROFILE\.ssh\id_rsa.pub $username'@'$hostname':/home/'$username

    spawnBanner;
    Write-Host -NoNewline -ForegroundColor Yellow "[*] "
    Write-Host -ForegroundColor DarkCyan "Config remote ssh..."
    ssh $username@$hostname -p $port "if [ ! -f /home/$username/.ssh/authorized_keys ]; then mkdir /home/$username/.ssh ; touch /home/$username/.ssh/authorized_keys ; fi ; cat /home/$username/id_rsa.pub >> /home/$username/.ssh/authorized_keys && rm -f /home/$username/id_rsa.pub && chmod 700 /home/$username/.ssh/ && chmod 600 /home/$username/.ssh/authorized_keys"

    if ($?) {

        spawnBanner;
        Write-Host -NoNewline -ForegroundColor Yellow "[*] "
        Write-Host -NoNewline -ForegroundColor DarkCyan "Successful. Connect with "
        Write-Host -ForegroundColor Green "ssh $username@$hostname -p $port"
    }
}

function main($data) {

    if ($data.Count -gt 3) {
        publicKey;
        configHost(checkInput($data));
    }
    else {

        help;
    }
}

main($args);
