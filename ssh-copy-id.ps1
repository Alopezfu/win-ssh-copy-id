$id_rsa = "C:\Users\$env:UserName\.ssh\id_rsa.pub"
if (Test-Path $id_rsa)
{
    Clear-Host
    $server = Read-Host -Prompt 'Input your server  name or Ip'
    $user = Read-Host -Prompt 'Username ssh'
    scp $id_rsa $user@$server':'/home/$user/
    ssh $user@$server "if [ ! -f /home/alejandro/.ssh/authorized_keys ]; then mkdir /home/alejandro/.ssh ; touch /home/alejandro/.ssh/authorized_keys ; fi"
    ssh $user@$server "cat /home/$user/id_rsa.pub >> /home/$user/.ssh/authorized_keys && rm -f /home/$user/id_rsa.pub && chmod 700 /home/$user/.ssh/ && chmod 600 /home/$user/.ssh/authorized_keys"
    
    Clear-Host
    Write-Host "Process completed successfully!"
    Write-Host "Now you can connect with - ssh $user@$server"

}else{

    Clear-Host
    Write-Host "You need create a public key.";
    $q = Read-Host -Prompt "Generate now? (yes/no)"
    if ($q -eq "yes"){

        mkdir C:\Users\$env:UserName\.ssh\ 2>&1 $null
        ssh-keygen -f "C:\Users\$env:UserName\.ssh\id_rsa"
        .\ssh-copy-id.ps1
    }else{

        exit 0
    }

}
