var Ply = (function(Ply) {

  Ply.Models = new function() {
    this.buildModels = function() {
      Ply.Models.Serializable = Ember.Object.extend({
        publicAttributes: ["currentBoard"],
        asObject: function() {
          return this.getProperties(this.publicAttributes);
        }
      })


      Ply.Models.ApplicationModel = Ply.Models.Serializable.extend({
        publicAttributes: ["currentBoard"],
        currentBoard: "",
        boardClassName: "",
        moveToNextBoard: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       '/info/checkin',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.set('currentBoard', result.next_board);
                                this_model.set('currentUser', result.current_user);
                                this_model.populateInfoFromServer();
                              },
                   error:     function(result) {
                                setTimeout(Ply.Application.retryBoardMove, 2000);
                              }, 
                   async:     false
          });
        },
        populateInfoFromServer: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       '/boards/info',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.set("boardClassName", result.board_class_name);
                                this_model.set("updateEvery", result.update_every);
                                this_model.set("showFor", result.show_for);
                                this_model.set('currentUser', result.current_user);
                              },
                   async:     false
          });          
        }
      });
    }
  }

  Ply.Models.BoardModels = new function() {

  }

  Ply.BoardObservers = new function() {

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
      var content_area_data = $("body")
      if (content_area_data.data('default-to-board').length > 0)
        window.App.set('currentBoard', content_area_data.data('default-to-board'));
      else if (content_area_data.data('auto-load') === true)
        window.App.moveToNextBoard();

      window.App.set('autoMove', content_area_data.data('auto-load') === true)
    }


    this.bindAppModelObservers = function() {
      window.App.addObserver('currentBoard', Ply.Application.bringBoardIntoView);
      window.App.addObserver('updateEvery', Ply.Application.bindUpdateServices);
      window.App.addObserver('currentBoard', Ply.Application.bindBoardMover);
      window.App.addObserver('currentUser', Ply.Application.renderUserStatus);
    }

    this.bindBoardMover = function(payload) {
      setTimeout(Ply.Application.runBoardMove, (payload.showFor * 1000));
    }

    this.renderUserStatus = function(payload) {
      if ($("#user_status").length === 0) {
        var user_status = $("<div id=\"user_status\"></div>");
        $("body").append(user_status);
      }

      user_status.html(payload.currentUser);
      user_status.show("slide", { direction: "right" }, 1000);
      
      setTimeout(Ply.Application.hideUserStatus, 10 * 1000)
    }

    this.hideUserStatus = function(payload) {
      $("#user_status").hide("slide", { direction: "right" }, 500);
    }

    this.retryBoardMove = function() {
      window.App.moveToNextBoard();
    }

    this.runBoardMove = function() {
      if (window.App.autoMove === true)
        window.App.moveToNextBoard();
      else
        setTimeout(Ply.Application.runBoardMove, (window.App.showFor * 1000));
    }

    this.bindUpdateServices = function(payload) {
      if (!(window.App.updateServicesIntervalId === undefined))
        clearInterval(window.App.updateServicesIntervalId);

      if (window.App.updateEvery > 0) {
        window.App.updateServicesIntervalId = setInterval(Ply.Application.updateServices, (window.App.updateEvery * 1000));
      }
    }

    this.updateServices = function(payload) {
      window.App.currentBoardObj.populateServices();
    }

    this.bringBoardIntoView = function(app_model) {
      // shut down current board
      if (!(Ply.Application.activeObserver === undefined)) {
        Ply.Application.activeObserver.bumpOut(app_model);
        clearInterval(window.App.updateServicesIntervalId);
      }

      // bring in new info
      window.App.populateInfoFromServer();

      // clear out old
      var head_target = $("head");
      head_target.find('script[type=text/x-handlebars][data-template-specific=true]').remove();

      // grab templates for new
      jQuery.ajax({
               url:       '/boards/templates?layout=false',
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
               url:       '/boards/view?layout=false',
               data:       {app: window.App.getProperties(window.App.publicAttributes)},
               dataType:  'html',
               success:   function(result) {
                            content = result;
                          },
               async:     false
      });

      // place view content in
      $("#content_area").attr("id", "previous_content");
      $("body").prepend("<div id=\"content_area\" style=\"display: none\"></div>")
      $("#content_area").html(content);

      // construct model for this board (there must be a better way)
      var new_model = eval("Ply.Models.BoardModels." + window.App.boardClassName + " = Ply.Models.Serializable.extend()");

      // fetch services and instantiate
      window.App.currentBoardObj = new_model.create({
        publicAttributes: ["currentBoard"],
        populateServices: function() {
          var this_model = this;
          jQuery.ajax({
                   url:       '/boards/services',
                   data:       {app: this_model.getProperties(this_model.publicAttributes)},
                   dataType:  'json',
                   success:   function(result) {
                                this_model.set('services', result)
                              },
                   async:     false
          }); 
        }
      });

      window.App.currentBoardObj.set("currentBoard", window.App.currentBoard);
      window.App.currentBoardObj.populateServices();

      // notify respective namespace
      var ns = Ply.BoardObservers[window.App.boardClassName + "Observer"];

      if (!(ns === undefined)) {
        ns.boardReady({model: window.App.currentBoardObj});
        Ply.Application.activeObserver = ns;
      }

      $("#previous_content").transition({
        opacity: 0,
        scale: 4.0
      }, Ply.Application.showNewContent)
    }

    this.showNewContent = function() {
      $("#content_area").fadeIn('slow', Ply.Application.wipePreviousContent);
    }

    this.wipePreviousContent = function() {
      $("#previous_content").remove();
    }
  };

  return Ply;
}(Ply || {}));