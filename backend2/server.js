const express = require('express');
const multer = require('multer');
const path = require('path');
const bodyParser = require('body-parser');
const cors = require('cors');
const { insertData, clientt } = require('./db');
const fs = require('fs');
const { exec } = require('child_process');
const WebSocket = require('ws');

const app = express();
const port = 8000;
const wss = new WebSocket.Server({ port: 8080 });

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

app.use(bodyParser.json());
app.use(cors());

const clients = [];

wss.on('connection', (ws) => {
  clients.push(ws);
  ws.on('close', () => {
    const index = clients.indexOf(ws);
    if (index > -1) {
      clients.splice(index, 1);
    }
  });
});

const broadcast = (data) => {
  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });
};

app.post('/api/migrationForm', upload.fields([{ name: 'sshKeyFile' }, { name: 'targetSshKeyFile' }]), async (req, res) => {
  const { 
    projectName, awsSecretKey, awsAccessKey, region, sshUser, sshPassword, sshPort, sshIpAddress, sourcDirectoryPath,
    targetSshUser, targetAuthMethod, targetSshPassword, targetSshPort, targetIpAddress, targetDirectoryPath
  } = req.body;
  
  const sshKeyFilePath = req.files['sshKeyFile'] ? req.files['sshKeyFile'][0].path.replace(/\\/g, '/') : '';
  const targetSshKeyFilePath = req.files['targetSshKeyFile'] ? req.files['targetSshKeyFile'][0].path.replace(/\\/g, '/') : '';

  const data = {
    projectName,
    awsSecretKey,
    awsAccessKey,
    region,
    sshUser,
    sshPassword,
    sshPort: parseInt(sshPort),
    sshIpAddress,
    sshKeyFilePath,
    sourcDirectoryPath,
    targetSshUser,
    targetAuthMethod,
    targetSshPassword,
    targetSshPort: parseInt(targetSshPort),
    targetIpAddress,
    targetSshKeyFilePath,
    targetDirectoryPath
  };

  try {
    await insertData(data);
    console.log('Data inserted successfully');
    res.json({ success: true, message: 'Validation successful' });
  } catch (err) {
    console.error('Error inserting data:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

app.get('/api/sshData', (req, res) => {
  const command3 = req.query.find;
  const client = clientt;
  const dbName = 'fastsync';

  async function find_query(command3) {
    try {
      await client.connect();
      console.log('Connected successfully to server');
      const db = client.db(dbName);
      const migration_form_data = db.collection('migration_form_data');
      const findResult = await migration_form_data.find({ projectName: command3 }).toArray();

      if (typeof findResult !== 'object') {
        res.status(500).json({ msg: "Something went wrong" });
        return;
      }
      console.log('Found documents =>', findResult);
      client.close();

      if (findResult.length > 0) {
        console.log(findResult);
        res.send(findResult);
      } else {
        console.log("No documents found");
        res.send("No documents found");
      }
    } catch (error) {
      console.error("Error Fetching data:", error);
      res.status(500).send("Error Fetching data");
    }
  }

  find_query(command3);
});

app.post('/api/performActions', (req, res) => {
  const validateData = req.body;
  console.log(validateData);

  const logFileName = `ssh_${validateData.projectName}_${Date.now()}.txt`;
  const logFilePath = path.join('D:/Project/backend2/logfiles', logFileName);

  const executeSSHCommand = (sshCommand, description) => {
    return new Promise((resolve, reject) => {
      const sshProcess = exec(sshCommand, (error, stdout, stderr) => {
        if (error) {
          console.error(`Error: ${error.message}`);
          fs.appendFileSync(logFilePath, `${description} Error: ${error.message}\n`);
          broadcast({ type: 'log', message: `${description} Error: ${error.message}` });
          broadcast({ type: 'status', status: 'failure' });
          return reject(error);
        }
        if (stderr) {
          console.error(`SSH command stderr: ${stderr}`);
          fs.appendFileSync(logFilePath, `${description} stderr: ${stderr}\n`);
          broadcast({ type: 'log', message: `${description} stderr: ${stderr}` });
          broadcast({ type: 'status', status: 'failure' });
          return reject(new Error(stderr));
        }
        console.log(`SSH command output: ${stdout}`);
        fs.appendFileSync(logFilePath, `${description} output: ${stdout}\n`);
        broadcast({ type: 'log', message: `${description} output: ${stdout}` });
        resolve(stdout);
      });

      sshProcess.stdout.on('data', (data) => {
        console.log(`output:\n${data}`);
        broadcast({ type: 'log', message: `output:\n${data}` });
      });

      sshProcess.stderr.on('data', (data) => {
        console.error(`Error: ${data}`);
        broadcast({ type: 'log', message: `Error: ${data}` });
      });

      sshProcess.on('close', (code) => {
        console.log(`SSH command exited with code ${code}`);
        const status = code === 0 ? 'success' : 'failure';
        broadcast({ type: 'status', status });
      });
    });
  };

  const validateSSHCommand = `timeout 35s ssh -o StrictHostKeyChecking=no -i ${validateData.sshKeyFilePath} ${validateData.sshUser}@${validateData.sshIpAddress} 'bash -s' < sourceAccount.bash ${validateData.awsAccessKey} ${validateData.awsSecretKey} ${validateData.region} ${validateData.sourcDirectoryPath};`;
  const syncToTargetCommand = `timeout 35s ssh -o StrictHostKeyChecking=no -i ${validateData.targetSshKeyFilePath} ${validateData.targetSshUser}@${validateData.targetIpAddress} 'bash -s' < targetAccount.bash ${validateData.awsAccessKey} ${validateData.awsSecretKey} ${validateData.region} ${validateData.targetDirectoryPath};`;

  fs.chmodSync(validateData.sshKeyFilePath, '400');
  fs.chmodSync(validateData.targetSshKeyFilePath, '400');

  (async () => {
    try {
      await executeSSHCommand(validateSSHCommand, 'Validate SSH');
      await executeSSHCommand(syncToTargetCommand, 'Sync to Target');
      res.json({ success: true, message: 'Operations completed successfully' });
    } catch (error) {
      console.error('Error during operations:', error);
      res.status(500).json({ success: false, message: 'Internal server error' });
    }
  })();
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
