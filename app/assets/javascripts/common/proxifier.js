(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.Proxifier = {
    proxifyMethod: function proxifyMethod(object, methodName) {
      object[methodName] = $.proxy(object[methodName], object);
    },

    proxifyMethods: function proxifyMethods(object, methodNames) {
      for (var i=0; i<methodNames.length; i++) {
        this.proxifyMethod(object, methodNames[i]);
      }
    },

    proxifyAllMethods: function proxifyAllMethods(object) {
      for (var attrName in object) {
        if ( typeof object[attrName] == 'function' && attrName.match(/^[a-z]/) ) this.proxifyMethod(object, attrName);
      }
    }
  };
}());
