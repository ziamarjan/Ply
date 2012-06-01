Ply.FrameObservers.WeatherObserver = new function() {
  this.frameReady = function(payload) {
    // extend existing model
    var model = payload.model;
    Ply.FrameObservers.WeatherObserver.activeModel = model;

    var WeatherView = Ember.View.extend({
      defaultTemplate: Ember.Handlebars.compile($("[data-template-name=weather-render]").html()),
    });

    Ply.FrameObservers.WeatherObserver.activeView = WeatherView.create();
    Ply.FrameObservers.WeatherObserver.activeView.set("current", model.services.response.current);
    Ply.FrameObservers.WeatherObserver.activeView.set("future", model.services.response.future);
    Ply.FrameObservers.WeatherObserver.activeView.appendTo("#weather_status");
  }

  this.bumpOut = function(params) {
    
  }
}