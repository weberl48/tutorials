var todomvc = angular.module('todomvc', ['firebase']);
todomvc.controller('TodoCtrl', function TodoCtrl($scope, $firebase) {
    var fireRef = new Firebase('https://<NAME_OF_YOUR_FIREBASE>.firebaseio.com/');
    $scope.todos = $firebase(fireRef).$asArray();
    $scope.newTodo = '';

    $scope.addTodo = function(){
        var newTodo = $scope.newTodo.trim();
        if (!newTodo.length) {
            return;
        }

        // push to firebase
        $scope.todos.$add({
            title: newTodo,
            completed: false
        });
        $scope.newTodo = '';
    };

    $scope.removeTodo = function(todo){
        $scope.todos.$remove(todo);
    };

});
