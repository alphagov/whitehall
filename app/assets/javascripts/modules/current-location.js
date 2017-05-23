(function(root) {
  "use strict";
  root.GOVUK = root.GOVUK || {};

  root.GOVUK.getCurrentLocation = function(){
    return root.location;
  };
}(window));
