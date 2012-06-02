Ply.BoardObservers.WeatherObserver = new function() {
  this.boardReady = function(payload) {
    // extend existing model
    var model = payload.model;
    Ply.BoardObservers.WeatherObserver.activeModel = model;

    var WeatherView = Ember.View.extend({
      defaultTemplate: Ember.Handlebars.compile($("[data-template-name=weather-render]").html()),
    });

    Ply.BoardObservers.WeatherObserver.activeView = WeatherView.create();
    Ply.BoardObservers.WeatherObserver.activeView.set("current", model.services.response.current);
    Ply.BoardObservers.WeatherObserver.activeView.set("future", model.services.response.future);
    Ply.BoardObservers.WeatherObserver.activeView.appendTo("#weather_status");
  }

  this.bumpOut = function(params) {
    
  }
}