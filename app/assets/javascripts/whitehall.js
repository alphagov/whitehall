(function($) {
  window.Whitehall = {};
  window.Whitehall.Frontend = {};
  window.Whitehall.Admin = {};

  window.Whitehall.instances = {};

  window.Whitehall.init = function init(constructor, params) {
    Whitehall.instances[constructor.name] = Whitehall.instances[constructor.name] || [];
    var instance = new constructor(params);
    Whitehall.instances[constructor.name].push(instance);
    return instance;
  }
})(jQuery);
