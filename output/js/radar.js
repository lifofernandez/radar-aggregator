angular.module('radarApp', [])

  .filter('stringify', function() {
    return function(input, lowercase) {
      var out = input.join(" ");
      return out;
    };

  })

  .controller('feedsController', function() {
      var feedsList = this;  
      /*
      feedsList.feeds = [
        {title:'Create Digital Music', categories:['Musica','Arte','Cosas'], description:'Making music with technology', url:'http://createdigitalmusic.com', lang:'en-US', n_items:10,}, 
        {title:'Dataisnature', categories:['Arte'], description:'Interrelationships between natural processes, computational systems and procedural-based art practices', url:'http://www.dataisnature.com', lang:'en-US', n_items:10,}, 
      ];  
      */

      feedsList.feeds = {
      "Dataisnature":{"description":"Interrelationships between natural processes, computational systems and procedural-based art practices","n_items":"10","categories":["Arte"],"lang":"en-US","url":"http://www.dataisnature.com"},
      "Create Digital Music":{"description":"Making music with technology","n_items":"10","categories":["Musica","Arte","Cosas"],"url":"http://createdigitalmusic.com","lang":"en-US"}
      }
      
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