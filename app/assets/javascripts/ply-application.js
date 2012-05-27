var Ply = (function(Ply) {

  Ply.Models = new function() {
    this.buildModels = function() {
      Ply.Models.Serializable = Ember.Object.extend({
        publicAttributes: ["currentFrame"],
        asObject: function() {
          return this.getProperties(this.publicAttributes);
        }
      })


      Ply.Models.ApplicationModel = Ply.Models.Serializable.extend({
        publicAttributes: ["currentFrame"],
        currentFrame: "",
        frameClassName: "",
        moveToNextFrame: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       '/info/next_frame',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.set('currentFrame', result.next_frame);
                                this_model.populateInfoFromServer();
                              },
                   async:     false
          });
        },
        populateInfoFromServer: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       '/frames/info',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.set("frameClassName", result.frame_class_name);
                                this_model.set("updateEvery", result.update_every);
                                this_model.set("showFor", result.show_for);
                              },
                   async:     false
          });          
        }
      });
    }
  }

  Ply.Models.FrameModels = new function() {

  }

  Ply.FrameObservers = new function() {

  }

  Ply.Application = new function() {
    this.activateEmber = function() {
      Ply.Application.instance = Em.Application.create();

      Ply.Models.buildModels();

      Ply.Application.initializeAppModel();
    }

    this.initializeAppModel = function() {
      window.App = Ply.Models.ApplicationModel.create();

      // need observers for this model
      Ply.Application.bindAppModelObservers();

      if ($("#content_area").data('default-to-frame').length > 0)
        window.App.set('currentFrame', $("#content_area").data('default-to-frame'));
      else
        window.App.moveToNextFrame();
    }


    this.bindAppModelObservers = function() {
      window.App.addObserver('currentFrame', Ply.Application.bringFrameIntoView);
      window.App.addObserver('updateEvery', Ply.Application.bindUpdateServices);
      window.App.addObserver('currentFrame', Ply.Application.bindFrameMover);
    }

    this.bindFrameMover = function(payload) {
      setTimeout(Ply.Application.runFrameMove, (payload.showFor * 1000));
    }

    this.runFrameMove = function() {
      window.App.moveToNextFrame();
    }

    this.bindUpdateServices = function(payload) {
      if (!(window.App.updateServicesIntervalId === undefined))
        clearInterval(window.App.updateServicesIntervalId);

      if (window.App.updateEvery > 0) {
        window.App.updateServicesIntervalId = setInterval(Ply.Application.updateServices, (window.App.updateEvery * 1000));
      }
    }

    this.updateServices = function(payload) {
      window.App.currentFrameObj.populateServices();
    }

    this.bringFrameIntoView = function(app_model) {
      // shut down current frame
      if (!(Ply.Application.activeObserver === undefined))
        Ply.Application.activeObserver.bumpOut(app_model);

      // bring in new info
      window.App.populateInfoFromServer();

      // clear out old
      var head_target = $("head");
      head_target.find('script[type=text/x-handlebars][data-template-specific=true]').remove();

      // grab templates for new
      jQuery.ajax({
               url:       '/frames/templates?layout=false',
               data:       {app: window.App.getProperties(window.App.publicAttributes)},
               dataType:  'html',
               success:   function(result) {
                            $("head").append(result);
                          },
               async:     false
      });

      // bring in initial view
      var content = "";
      jQuery.ajax({
               url:       '/frames/view?layout=false',
               data:       {app: window.App.getProperties(window.App.publicAttributes)},
               dataType:  'html',
               success:   function(result) {
                            content = result;
                          },
               async:     false
      });

      // place view content in
      $("#content_area").html(content);

      // construct model for this frame (there must be a better way)
      var new_model = eval("Ply.Models.FrameModels." + window.App.frameClassName + " = Ply.Models.Serializable.extend()");

      // fetch services and instantiate
      window.App.currentFrameObj = new_model.create({
        publicAttributes: ["currentFrame"],
        populateServices: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       '/frames/services',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.set('services', result)
                              },
                   async:     false
          }); 
        }
      });

      window.App.currentFrameObj.set("currentFrame", window.App.currentFrame);
      window.App.currentFrameObj.populateServices();

      // notify respective namespace
      var ns = Ply.FrameObservers[window.App.frameClassName + "Observer"];

      if (!(ns === undefined)) {
        ns.frameReady({model: window.App.currentFrameObj});
        Ply.Application.activeObserver = ns;
      }
    }
  };

  return Ply;
}(Ply || {}));