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
      if (Session.get("hideCompleted")) {
          // If hide completed is checked, filter tasks
          return Tasks.find({checked: {$ne: true}}, {sort: {createdAt: -1}});
        } else {
          // Otherwise, return all of the tasks
          return Tasks.find({}, {sort: {createdAt: -1}}); // sort by newest first
        }
      },
      hideCompleted: function () {
        return Session.get("hideCompleted");
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
  },
  "change .hide-completed input": function (event) {
      Session.set("hideCompleted", event.target.checked);
    },
    incompleteCount: function () {
      return Tasks.find({checked: {$ne: true}}).count();
    }
  });

// listening to the submit event on any element that matches the CSS selector .new-task.
// event.target - is form element, get value using event.target.text.value
// event.target.text.value = "", is clearing input for new entrys
// session is a reactive data store for the client
  // - convienet place to store temporary UI state
Template.task.events({
    "click .toggle-checked": function () {
      // Set the checked property to the opposite of its current value
      Tasks.update(this._id, {
        $set: {checked: ! this.checked}
      });
    },
    "click .delete": function () {
      Tasks.remove(this._id);
    }
  });
}
// this refers to an individual task object
// _id - every inserted document has a unique _id.
