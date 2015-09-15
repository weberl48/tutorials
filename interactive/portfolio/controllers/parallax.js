//create a new instance and add to variable for later use
var controller = new ScrollMagic.Controller()
// ScrollMagic.Scene defines where the controller should react and how
var scene = new ScrollMagic.Scene({
  triggerElement: '#pinned-trigger1', // starting scene, when reaching this element
  duration: 400 // pin the element for a total of 400px
})
.setPin('#pinned-element1'); // the element we want to pin

// Add Scene to ScrollMagic Controller
controller.addScene(scene);
