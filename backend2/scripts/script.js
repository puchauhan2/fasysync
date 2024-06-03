const fs = require('fs');
const { spawn, exec } = require('child_process');
const sshCommand = "timeout 35s ssh -o StrictHostKeyChecking=no -i C:/Users/Vedanth.Mugalihal/Downloads/at_GE.pem ec2-user@ec2-34-229-176-168.compute-1.amazonaws.com 'bash -s' < usercreate.bash;"


const sshKeyFilePath = 'C:/Users/Vedanth.Mugalihal/Downloads/at_GE.pem';
fs.chmodSync(sshKeyFilePath, '400');


// const sshProcess = spawn('ssh', [orgument,'-i', sshKeyFilePath, `${sshUser}@${sshIpAddress}`, 'ls', '-lh'],'sudo -n bash -s < );

// const sshProcess = exec('ssh', [orgument,'-i', sshKeyFilePath, `${sshUser}@${sshIpAddress}`, 'sudo -n bash -s < usercreate.bash ']);


const sshProcess = exec(sshCommand, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`SSH command stderr: ${stderr}`);
      return;
    }
    console.log(`SSH command output: ${stdout}`);
  });

sshProcess.stdout.on('data', (data) => {
    console.log(`output:\n${data}`);
});

sshProcess.stderr.on('data', (data) => {
    console.error(`Error: ${data}`);
});

sshProcess.on('close', (code) => {
    console.log(`SSH command exited with code ${code}`);
});



const port = 8081;

console.log(`Server running on port ${port}`);
