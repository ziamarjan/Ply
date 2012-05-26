$( function() {

  Ply.App.Boot();
});

var Ply = (function (Ply) {


  Ply.Utilities = new function() {

    this.checkAndEnableRetina = function(event) {
      if ( (window.devicePixelRatio) && (window.devicePixelRatio >= 2) ) {
        var target = $('body');

        if (!(event === undefined))
          target = $(event.currentTarget);

        target.addClass("retina");
      }
    }

    this.swapImagesToRetina = function(event) {
      var target = $('body');

      if (!(event === undefined))
        target = $(event.currentTarget);

      var targets = target.find('img').not('[retina="active"]');
      var replace_regex = new RegExp("(.*)([.])(png|jpg|gif)");

      targets.each(function (index, dom_obj) {
        var target_img = $(dom_obj);
        var url = target_img.attr("src").replace(replace_regex, "$1@2x.$3");
        Ply.Utilities.testAssetExists(url, Ply.Utilities.replaceImageWithNew, {previous_src: target_img.attr("src")});
      });
    }

    this.replaceImageWithNew = function(resource_url, params) {
      debugger;
    }

    this.testAssetExists = function(resource_url, callback, params) {
      if (params === undefined)
        params = {};
      var http = new XMLHttpRequest();
      http.open('HEAD', resource_url);
      http.onreadystatechange = function() {
        if (this.readyState == this.DONE)
            callback(resource_url, params);
      };
      http.send();
    };

  };

  return Ply
}(Ply || {}));


var Ply = (function(Ply) {

  Ply.App = new function() {

    this.Boot = function() {
      Ply.Utilities.checkAndEnableRetina();
    }
  };

  return Ply
}(Ply || {}));