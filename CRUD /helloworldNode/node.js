var http = require('http'); //add the http module
var myServer = http.createServer(function(request, response) {
  response.writeHead(200, {"Content-Type" : "text/html"});
  response.write("Hello");
  response.end();
}); //create a server
myServer.listen('3000');
console.log("Got to local host 3000 on browser");
