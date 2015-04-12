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
        obj.created_at = new Date(); //B // call getdistance here isntead of post
        the_collection.update({Name: obj.name}, obj, {upsert:true}, // C 
        this.getDistance(collectionName, obj.name, function(){ //D
          callback(null, obj);
        }) 
        );
      }
    });
};

// what we need to do is get the json from the request object, store the json into our db
// parse the json, iterate across every other json in our db
// if any of the jsons are too close, less than a certain threshold,
// place certain things in certain palces

calculateDistance = function(obj1, obj2){ 
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


//Calculate the person closest to personName using distance formula
CollectionDriver.prototype.getDistance = function(collectionName, personName, callback){
  var threshold = 1000000000 //Assume farthest distance, 
  var lastPerson;
  

  var closestPeople = []

  this.getCollection(collectionName, function(error, collection){
    if(error){callBack(error, false);
    } else {
      //Grab object by playerName
      collection.findOne({"name" : personName}, function(error, playerObject){
        if (error){
          callback(error, false);
        }
        //Grab db size
        collection.count({}, function(error, count) {

          collection.find().sort({'Score' : -1}).toArray(function(error, results) { //B
            if( error ) callback(error)
            else {
              for (var i = 0; i<count ;i++){
              // iterate through, getting every object from the collection,
              // and passing it in to the distance function
                var comparator = results[i]
                  if(playerObject.name != comparator.name){
                    //calculate distance between the the param person and the current item in the list.
                    var distance = calculateDistance(comparator, playerObject);
                    if(distance < threshold){ // difference in distance
                        lowestDistance = distance;
                        lastPerson = comparator


                      //create new json object
                          var closestPerson = {
                              "name" : lastPerson.name,
                              "distance" : lowestDistance,
                              "x" : comparator.location.x,
                              "y" : comparator.location.y
                          }
                          console.log(closestPerson)
                          closestPeople.push(closestPerson)
                        
                      }
                    }
                } 

              closestPeople = JSON.stringify(closestPeople);
        //Return document in collection we ar trying to get.
            //return new made object; //case if it's false, nothing else matters
             callback(closestPeople, true); // true case

            }
          })


            

            
      // ..
        });
      })
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