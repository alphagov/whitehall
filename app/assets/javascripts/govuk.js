(function($) {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.instances = {};

  window.GOVUK.init = function init(object, params) {
    if (typeof(object) == 'function') {
      return init_constructor(object, params);
    }
    else {
      return init_singleton(object, params);
    }

    function init_constructor(constructor, params) {
      GOVUK.instances[constructor.name] = GOVUK.instances[constructor.name] || [];
      var instance = new constructor(params);
      GOVUK.instances[constructor.name].push(instance);
      return instance;
    }

    function init_singleton(singleton, params) {
      singleton.init(params);
      return singleton;
    }
  }
})(jQuery);
