var http = require('http'),
    express = require('express'),
    path = require('path'),
    MongoClient = require('mongodb').MongoClient,
    Server = require('mongodb').Server,
    CollectionDriver = require('./collectionDriver').CollectionDriver;
 
var app = express();
app.set('port', process.env.PORT || 8080); 
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.bodyParser()); // <-- add

var mongoHost = 'localHost'; //A
var mongoPort = 27017; 
var collectionDriver;
 
var mongoClient = new MongoClient(new Server(mongoHost, mongoPort)); //B
mongoClient.open(function(err, mongoClient) { //C
  if (!mongoClient) {
      console.error("Error! Exiting... Must start MongoDB first");
      process.exit(1); //D
  }
  var db = mongoClient.db("MyDatabase");  //E
  collectionDriver = new CollectionDriver(db); //F
});

app.use(express.static(path.join(__dirname, 'public')));
 
app.get('/', function (req, res) {
  res.render('main')
});
 

app.get('/data', function(req, res) { //A
   var params = req.params; //B
   dbCollection = 'players'
   //console.log(req)
   collectionDriver.findAll(dbCollection, function(error, objs) { //C
        if (error) { res.send(400, error); } //D
        else { 
            if (req.accepts('html')) { //E
                res.render('data',{objects: objs, collection: dbCollection}); //F
              } else {
            res.set('Content-Type','application/json'); //G
                  res.send(200, objs); //H
              }
         }
    });
});

app.post('/data', function(req, res) { //A
    var object = req.body;
    console.log(object)
    var dbCollection = 'players';
    object.Score = parseInt(object.Score)
    collectionDriver.save(dbCollection, object, function(err,docs) {
          if (err) { res.send(400, err); } 
          else { res.send(201, docs); } //B
     });
});




 
app.get('/data/:collection', function(req, res) { //A
   var params = req.params; //B
   console.log(req.params.collection) //name
   var userName = req.params.collection
   var dbCollection = 'players'
   collectionDriver.getPercentile(dbCollection, userName, function(error, objs) { //C
    	  if (error) { res.send(400, error); } //D
	      else { 
                  res.send(200, objs); //H  
              }
   	});
});

app.post('/data/:collection', function(req, res) { //A
    var object = req.body;
    console.log(object);
    var collection = req.params.collection;
    collectionDriver.save(collection, object, function(err,docs) {
          if (err) { res.send(400, err); } 
          else { res.send(201, docs); } //B
     });
});

 
app.use(function (req,res) {
    res.render('404', {url:req.url});
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});