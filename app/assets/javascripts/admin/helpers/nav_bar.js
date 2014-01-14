(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.navBarHelper = {
    init: function init() {
      $('.js-create-new').toggler({header: ".toggler", content: "ul", showArrow: false, actLikeLightbox: true});
      $('.js-more-nav').toggler({header: ".toggler", content: "ul", showArrow: false, actLikeLightbox: true});
    }
  };
}());

