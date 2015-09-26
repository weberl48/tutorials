function TestCtrl() {
  var self = this;
  self.myString = "hello world"
  self.people = [

    {
      name: 'Eric Simons',
      born: "Chicago"
    },
    {
      name: "Albert Pai",
      born: "Taiwan"
    },
    {
      name: "Matthew Greenster",
      born: "Virginia"
    }
  ];
}
// this is where the filter magic happens
function CapitalizeFilter(){
  // this is the function that Angular will execute wehn the expression is evaludated
  return function (text) {
    // test is the original string output of the Angular expression
    return text.toUpperCase()
    // and we simply return the text in upper case
  }
}
var app= angular.module('app', [])
app.controller('TestCtrl', TestCtrl)
// define a filter called 'capitalize' that will invoke the CapitalizeFilter function
app.filter('capitalize', CapitalizeFilter);
