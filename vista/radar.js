var radarApp = angular.module('radarApp', []);

////////////
// Services

// Setting up a service to house our json file so that it can be called by the controllers
radarApp.factory('feedsService', 
  
  function($http) {
    var promise;

    var jsondata = {
        get: function() {
            if ( !promise ) {
                var promise =  $http.get('../data/feeds.json').success(function(response) {
                    return response.data;
                });
                return promise;
            }
        }
    };

    return jsondata;
  }

);


radarApp.factory('entriesService', function($http) {
    var promise;
    var jsondata = {
        get: function() {
            if ( !promise ) {
                var promise =  $http.get('../data/entries.json').success(function(response) {
                    return response.data;
                });
                return promise;
            }
        }
    };
    return jsondata;
});


////////////
// Controles

radarApp.controller('feedsController', function(feedsService, $scope) {

  var feedsList = this;  
  
  feedsService.get().then(function(d) {
    feedsList.feeds  = d.data;
    //console.log(d.data);
  })

});


radarApp.controller('entriesController', function(entriesService, $scope) {

  var entriesList = this;  
  
  entriesService.get().then(function(d) {
    entriesList.entries = d.data;
    //console.log(d.data);
  });

  
});

////////////
// Filters

radarApp.filter('stringify', function() {
  
  return function(input) {
    var out = "";
    if((input !== null) && ( typeof input !== 'string'))out = input.join(" ");
    return out;
  };


});




radarApp.filter('searchFor', function(){

  // All filters must return a function. The first parameter
  // is the data that is to be filtered, and the second is an
  // argument that may be passed with a colon (searchFor:searchString)

  return function(arr, searchString){

    if(!searchString){
      return arr;
    }

    var result = [];

    searchString = searchString.toLowerCase();

    // Using the forEach helper method to loop through the array
    angular.forEach(arr, function(item){

      // Search in titles and description strings...
      if((item.title.toLowerCase().indexOf(searchString) !== -1)||(item.descriptionClean.toLowerCase().indexOf(searchString) !== -1)){
        result.push(item);
      }
      
    });

    return result;
  };

});


radarApp.filter('feedsToggle', function(){

  // All filters must return a function. The first parameter
  // is the data that is to be filtered, and the second is an
  // argument that may be passed with a colon (searchFor:searchString)

  return function(arr, feedsSelected){
    
    //feedsSelected = ["Dataisnature","TechCrunch","Create Digital Music"];

    if((!feedsSelected) || (feedsSelected.length < 1)){
      //return arr;
      //feedsSelected = ["Dataisnature","TechCrunch","Create Digital Music"];
      console.log(feedsSelected);
    }

    var result = [];

    //feedsSelected = feedsSelected.toLowerCase();

    

    // Using the forEach helper method to loop through the array
    angular.forEach(arr, function(item){

      // Search in titles and description strings...
      if(feedsSelected.indexOf(item.feed) !== -1){
        result.push(item);
      }
      
    });

    return result;
  };

});



  



  ///RESERVA



   /*
    todoList.addTodo = function() {
      todoList.todos.push({text:todoList.todoText, done:false});
      todoList.todoText = '';
    };
 

    todoList.remaining = function() {
      var count = 0;
      angular.forEach(todoList.todos, function(todo) {
        count += todo.done ? 0 : 1;
      });
      return count;
    };
 
    todoList.archive = function() {
      var oldTodos = todoList.todos;
      todoList.todos = [];
      angular.forEach(oldTodos, function(todo) {
        if (!todo.done) todoList.todos.push(todo);
      });
    };
    */