// if (Meteor.isClient) {
//   // This code only runs on the client
//   Template.body.helpers({
//     tasks: [
//       { text: "This is task 1" },
//       { text: "This is task 2" },
//       { text: "This is task 3" }
//     ]
//   });
// }
// pass data into templates by defining helpers.
// tasks returns an array, {{#each tasks}} to iterate over the array
// {{text}} inside of #each block will display each index text property

Tasks = new Mongo.Collection("tasks");

if (Meteor.isClient) {
  // This code only runs on the client
  Template.body.helpers({
    tasks: function() {
      return Tasks.find({}, {sort: {createdAt: -1}}); // sort: by newest task first
    }
  });


// collections are a way of storing persistent data
// can be accessed from both server and client
// update themselves automatically, view will display most up to date info
//
// adding data to Mongo Collection
// meteor Mongo - opens a console into your app's local development database.
// db.tasks.insert({ text: "Hello world!", createdAt: new Date() });


Template.body.events({
  "submit .new-task": function(event) {
    // Prevent default browser form submit
    event.preventDefault();

    // Get value from form element
    var text = event.target.text.value;

    // Insert a task into the collection
    Tasks.insert({
      text: text,
      createdAt: new Date() // current time
    });

    // Clear form
    event.target.text.value = "";
  }
});
}
// listening to the submit event on any element that matches the CSS selector .new-task.
// event.target - is form element, get value using event.target.text.value
// event.target.text.value = "", is clearing input for new entrys
