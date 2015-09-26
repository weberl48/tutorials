angular.module('app', []).controller('MainCtrl', function($scope){
  $scope.message ="hello";
  $scope.updateMessage = function(inputMessage){
    $scope.message = inputMessage;
  };
});
// angular.module
// the first parameter of angular.module defines the name of the module.
// the second parameter is an array which declares the module dependancies
// .controller
// register controller with angular module using the controller function privided by modules. \
// first param is a string that specifies the controller name
// second param is a funciton that represents the controller
// in order to pass data to out view inject $scope and add some data to it


angular.module('app').controller('MainAsCtrl', function (){
  var self = this;
  self.message ='hello';
  self.changeMessage = function(message){
    self.message = message;
  }
})
