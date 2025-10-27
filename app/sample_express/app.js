const express = require('express');
const app =express();
const port = 3000;

app.get('/health', (req, res) => {
  console.log('/health request');
  res.send(200, 'healty');
});

app.get('/', (req, res) => {
  console.log('/ request');
  res.send('express works!');
});

app.listen(port, () => {
  console.log(`server start. port: ${port}`);
});
