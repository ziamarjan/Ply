Ply.BoardObservers.TimeObserver = new function() {
  this.boardReady = function(payload) {
    // extend existing model
    var model = payload.model;
    model.set('hour', function() {
      var d = new Date();
      return d.getHours();
    });
    model.set('minute', function() {
      var d = new Date();
      var min =  "" + d.getMinutes() + "";
      if (min.length == 1)
        min = "0" + min;
      return min;
    });

    var TimeView = Ember.View.extend({
      defaultTemplate: Ember.Handlebars.compile($("[data-template-name=time-display]").html()),
      updateTime: function() {
        this.set("hour", model.hour());
        this.set("minute", model.minute());
      }
    });

    var view = TimeView.create();
    view.updateTime();
    Ply.BoardObservers.TimeObserver.activeView = view;
    view.appendTo("#time_placeholder");

    // setup to update time every X
    Ply.BoardObservers.TimeObserver.updateTimer = setInterval(Ply.BoardObservers.TimeObserver.updateModelTime, 5 * 1000);
  }

  this.bumpOut = function(payload) {
    clearInterval(Ply.BoardObservers.TimeObserver.updateTimer);
  }

  this.updateModelTime = function() {
    Ply.BoardObservers.TimeObserver.activeView.updateTime();
  }
}