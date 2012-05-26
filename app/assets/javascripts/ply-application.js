var Ply = (function(Ply) {

  Ply.Models = new function() {

  }

  Ply.Application = new function() {
    this.activateEmber = function() {
      Ply.Application.instance = Em.Application.create();

      Ply.Application.buildModels();

      Ply.Application.initializeAppModel();
    }

    this.initializeAppModel = function() {
      window.App = Ply.Models.ApplicationModel.create();
      window.App.moveToNextFrame();
    }

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
        moveToNextFrame: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       'info/next_frame',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.currentFrame = result.next_frame;
                              },
                   async:     false
          });
        }
      });
    }
  };

  return Ply;
}(Ply || {}));