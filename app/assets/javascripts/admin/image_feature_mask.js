(function ($) {
  var _enableImageFeatureMask = function() {
    $(this).each(function() {
      var section = $(this);
      var image = $(section.find("img")[0]).wrap('<div class="featuring_mask_container">');
      image.before('<div class="featuring_mask_top"></div><div class="featuring_mask_bottom"><p class="explanation">feature mask (hover to hide)</p></div>');
    })
  };

  $.fn.extend({
    enableImageFeatureMask: _enableImageFeatureMask
  });
})(jQuery);

jQuery(function($) {
  $(".image_feature_mask").enableImageFeatureMask();
});