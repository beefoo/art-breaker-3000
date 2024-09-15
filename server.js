// > node server.js 8888
var port = 2222;
if (process.argv.length > 2) port = parseInt(process.argv[2]);

const express = require('express');
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.static('./html/')); //Tells the app to serve static files from ./

app.listen(port, () => console.log('Listening on port '+port));
