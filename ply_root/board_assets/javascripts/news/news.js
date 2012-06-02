Ply.BoardObservers.NewsObserver = new function() {
  this.boardReady = function(payload) {
    // extend existing model
    var model = payload.model;
    Ply.BoardObservers.NewsObserver.activeModel = model;
    model.addObserver("services", Ply.BoardObservers.NewsObserver.updateViewBindings);

    var NewsView = Ember.View.extend({
      defaultTemplate: Ember.Handlebars.compile($("[data-template-name=news-items]").html()),
    });

    Ply.BoardObservers.NewsObserver.activeView = NewsView.create();
    Ply.BoardObservers.NewsObserver.activeView.set("items", model.services.headlines)
    Ply.BoardObservers.NewsObserver.activeView.appendTo("#news_items");
  }

  this.bumpOut = function(payload) {
    payload.removeObserver("services", Ply.BoardObservers.NewsObserver.updateViewBindings);
  }

  this.updateViewBindings = function(payload) {
    Ply.BoardObservers.NewsObserver.activeView.set("items", payload.services.headlines);
  }
}