/* Using jQuery */
// Hey scrollbar, animate the thing I’ll tell you when I’ll tell you.
// Init ScrollMagic
var ctrl = new ScrollMagic.Controller({
  globalSceneOptions: {
    triggerHook: 'onLeave'
  }
});
// Create scene
// this refers to the individual sections.
// triggerElement: this tells the scrollbar:
// when the section reaches the top of the viewport, pin it.
$("section").each(function() {

  var name = $(this).attr('id');

  new ScrollMagic.Scene({
    triggerElement: this
  })
  .setPin(this)
  .addIndicators({
    colorStart: "rgba(255,255,255,0.5)",
    colorEnd: "rgba(255,255,255,0.5)",
    colorTrigger : "rgba(255,255,255,1)",
    name:name
    })
  .loglevel(3)
  .addTo(ctrl);

});

// Get window height
var wh = window.innerHeight;

new ScrollMagic.Scene({
  offset: wh*3
})
.setClassToggle("section#four", "is-active")
.addTo(ctrl);
