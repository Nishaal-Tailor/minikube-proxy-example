const express = require('express');
const app = express();

app.get('/', (req, res) => { 
  res.send('Hello from service exposed internally to k8s cluster via ClusterIP');
});

app.listen(3001, () => console.log('listening on port 3001'));
