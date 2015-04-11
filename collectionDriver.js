var ObjectID = require('mongodb').ObjectID;

CollectionDriver = function(db) {
  this.db = db;
};

CollectionDriver.prototype.getCollection = function(collectionName, callback) {
  this.db.collection(collectionName, function(error, the_collection) {
    if( error ) callback(error);
    else callback(null, the_collection);
  });
};

//find all objects for a collection
CollectionDriver.prototype.findAll = function(collectionName, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
      if( error ) callback(error)
      else { // function is anonymous
          the_collection.find().sort({'Score' : -1}).toArray(function(error, results) { //B
            if( error ) callback(error)
            else {
              callback(null, results)
            }
          })
        }
        });

};

//find a specific object
CollectionDriver.prototype.get = function(collectionName, id, callback) { //A
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
            var checkForHexRegExp = new RegExp("^[0-9a-fA-F]{24}$"); //B
            if (!checkForHexRegExp.test(id)) callback({error: "invalid id"});
            else the_collection.findOne({'_id':ObjectID(id)}, function(error,doc) { //C
            	if (error) callback(error)
            	else callback(null, doc);
            });
        }
    });
}

//save new object
CollectionDriver.prototype.save = function(collectionName, obj, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
      if( error ) callback(error)
      else {
        obj.created_at = new Date(); //B
        the_collection.update({Name: obj.name}, obj, {upsert:true}, function() { //C
          callback(null, obj);
        });
      }
    });
};

// what we need to do is get the json from the request object, store the json into our db
// parse the json, iterate across every other json in our db
// if any of the jsons are too close, less than a certain threshold,
// place certain things in certain palces

CollectionDriver.prototype.calculateDistance = function(obj1, obj2){ 
  // x1y1 has to be the larger number
  // var x1, x2, y1, y2 
  var x1 = obj1.location.x;
  var x2 = obj2.location.x;
  var y1 = obj1.location.y;
  var y2 = obj2.location.y;
  // grbs ll coordinates
  var x = x1-x2;
  var y = y1-y2;
  x = Math.pow(x, 2);
  y = Math.pow(y, 2);
  var result = x+y;
  var result = Math.pow(result, (1/2));
  return result;
}

CollectonDriver.prototype.fullCalculate = function(collectionName, obj, callback){
  // ths fucntion will clculate across all of the JSON's tht we have, treat them all as objects
  /// returns the distance, whos colliding as well as true or false k
  // everything is always done withn the callback
  var length;
  var i;
  var collection = getCollection(collectionName, function(error, collection){
    if(error){ callBack(error, false);
    } else () {
      i = collection.getLength();
      for (i; i!=0 ;i--){
    // iterate through, getting every object from the collection,
    // and passing it in to the distance function
      var comparator = collection.toArray[i]; 
        if(comparator.name =! obj.name){
          length = calculateDistance(comparator, obj);
          if(length < 1000){ // some arbitrary number 
            //return comparator; idk how to return ll these details
            // so imma assume that the code that clled me saves the json that is obj1
            //  
            callback(comparator, true); // true case
          }
      }
  } //return null; //case if it's false, nothing else matters
  callback(null, false); // false
} 
})

}

//update a specific object
CollectionDriver.prototype.update = function(collectionName, obj, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error) // fuck idont undertand what callback is but whatever
        else {
	        obj._id = ObjectID(entityId); //A convert to a real obj id
	        obj.updated_at = new Date(); //B
            the_collection.save(obj, function(error,doc) { //C
            	if (error) callback(error)
            	else callback(null, obj);
            });
        }
    });
}


//delete a specific object
CollectionDriver.prototype.delete = function(collectionName, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
        if (error) callback(error)
        else {
            the_collection.remove({'_id':ObjectID(entityId)}, function(error,doc) { //B
            	if (error) callback(error)
            	else callback(null, doc);
            });
        }
    });
}

exports.CollectionDriver = CollectionDriver;