Ply.FrameObservers.NewsObserver = new function() {
  this.frameReady = function(payload) {
    // extend existing model
    var model = payload.model;
    Ply.FrameObservers.NewsObserver.activeModel = model;
    model.addObserver("services", Ply.FrameObservers.NewsObserver.updateViewBindings);

    var NewsView = Ember.View.extend({
      defaultTemplate: Ember.Handlebars.compile($("[data-template-name=news-items]").html()),
    });

    Ply.FrameObservers.NewsObserver.activeView = NewsView.create();
    Ply.FrameObservers.NewsObserver.activeView.set("items", model.services.headlines)
    Ply.FrameObservers.NewsObserver.activeView.appendTo("#news_items");
  }

  this.bumpOut = function(payload) {
    payload.removeObserver("services", Ply.FrameObservers.NewsObserver.updateViewBindings);
  }

  this.updateViewBindings = function(payload) {
    Ply.FrameObservers.NewsObserver.activeView.set("items", payload.services.headlines);
  }
}