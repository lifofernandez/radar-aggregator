var radarApp = angular.module('radarApp', []);

// Services
// Setting up a service to house our json file so that it can be called by the controllers
radarApp.factory('feedsService', function($http) {
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
});


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



// Controles

radarApp.controller('feedsController', function(feedsService, $scope) {

  var feedsList = this;  
  
  feedsService.get().then(function(d) {
    //$scope.header = d.data.PACKAGE.ITEM[0]

    feedsList.feeds  = d.data;
    console.log(d.data);
  })

  
  /*
  feedsList.feeds = {
    "Dataisnature":{"description":"Interrelationships between natural processes, computational systems and procedural-based art practices","n_items":"10","categories":["Arte"],"lang":"en-US","url":"http://www.dataisnature.com"},
    "Create Digital Music":{"description":"Making music with technology","n_items":"10","categories":["Musica","Arte","Cosas"],"url":"http://createdigitalmusic.com","lang":"en-US"}
  }
  */
});


radarApp.controller('entriesController', function(entriesService, $scope) {

  var entriesList = this;  
  
  entriesService.get().then(function(d) {
    entriesList.entries  = d.data;
    console.log(d.data);
  })
  
});


// Filters
radarApp.filter('stringify', function() {
  return function(input, lowercase) {
    var out = input.join(" ");
    return out;
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