(function ($) {
  var _enableGovspeakHelp = function() {
    $(this).each(function() {
      var textarea = $(this);
      var label = $("label[for=" + textarea.attr("id") +"]");
      var helpContent = $("#govspeak_help");
      var helpLink = $(label.children("a.govspeak_help")[0]);

      helpContent.hide();
      var localHelpContent = helpContent.clone();
      localHelpContent.attr("id", null);
      localHelpContent.addClass("govspeak_help");
      label.after(localHelpContent);

      helpLink.click(function() {
        localHelpContent.slideToggle();
        return false;
      })
    })
  };

  $.fn.extend({
    enableGovspeakHelp: _enableGovspeakHelp
  });
})(jQuery);

jQuery(function($) {
  $("textarea.govspeak").enableGovspeakHelp();
});