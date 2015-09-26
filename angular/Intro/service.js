var app = angular.module('service', []);
app.factory('messages', function(){
// messages object that dependencies of this service will receive
  var messages ={}
  messages.list = [];
  messages.add = function(message){
    messages.list.push({id: messages.list.length, text: message});
  };
  return messages;
});
// ListCtrl injects out messages service and exposes the list from out service to out view
app.controller('ListCtrl', function(messages){
  var self = this;
  self.messages = messages.list;
})
//PostCtrl injects messages service, addMessage function uses add function made in service(factory)
app.controller('PostCtrl', function(messages){
  var self=this;
  self.addMessage= function(message){
    messages.add(message);
    // newMessage to an empty string after calling message.add to clear out the input field after it's been submitted.
    self.newMessage = " ";
  };
})
