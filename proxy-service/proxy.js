const express = require('express');
const app = express();
const axios = require('axios');

const INTERNALSERVICE = process.env.INTERNALSERVICE;


app.get('/', (req, res) => { 
  axios.get(INTERNALSERVICE)
  .then(response => {
    res.send(response.data);
  })   
});

app.listen(3000, () => console.log('listening on port 3000'));
