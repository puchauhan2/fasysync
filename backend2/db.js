require('dotenv').config();
const { MongoClient } = require('mongodb');

const uri = process.env.uri;

const clientt = new MongoClient(uri);

const insertData = async (data) => {
  try {
    await clientt.connect();
    console.log('Connected to MongoDB');

    const db = clientt.db('fastsync');
    const collection = db.collection('migration_form_data');

    await collection.insertOne(data);
  } finally {
    clientt.close();
    console.log('MongoDB connection closed');
  }
};


// const fetchSSHDataByProjectName = async (projectName) => {
  
//   try {
//     await client.connect();
//     console.log('Connected to MongoDB');

//     const db = client.db('fastsync');
//     const collection = db.collection('migration_form_data');
//     const query = { projectName: projectName };
//     const result = await collection.find(query).toArray;

//     console.log('results: ', result);
//     return result;
//   } catch (error) {
//       console.error('Error Fetching the Data: ', error);
//   } finally {
//     client.close();
//     console.log('MongoDB connection closed');
//   }
// };


// const fetchSSHDataByProjectName = async (projectName, callback) => {
//   try {
//     await client.connect();
//     const db = client.db('fastsync'); // Replace with your database name
//     const collection = db.collection('migration_form_data'); // Replace with your collection name

//     const results = await collection.find({ projectname: projectName }).toArray();
//     console.log('SSH data fetched successfully');
//     callback(null, results[0]);
//   } catch (err) {
//     console.error('Error fetching SSH data:', err);
//     callback(err, null);
//   } finally {
//     await client.close();
//   }
// };

module.exports = { insertData, clientt
  // fetchSSHDataByProjectName 
};
