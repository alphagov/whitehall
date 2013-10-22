(function($) {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.instances = {};

  window.GOVUK.init = function init(object, params) {
    if (typeof(object) == 'function') {
      return initConstructor(object, params);
    }
    else {
      return initSingleton(object, params);
    }

    function initConstructor(constructor, params) {
      var instance = new constructor(params);
      storeReferenceToInstance(instance);
      return instance;
    }

    function initSingleton(singleton, params) {
      singleton.init(params);
      return singleton;
    }

    function storeReferenceToInstance(instance) {
      GOVUK.instances[instance.constructor.name] = GOVUK.instances[instance.constructor.name] || [];
      GOVUK.instances[instance.constructor.name].push(instance);
    }
  }
})(jQuery);
