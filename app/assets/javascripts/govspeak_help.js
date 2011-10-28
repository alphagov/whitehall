(function ($) {
  var _enableGovspeakHelp = function() {
    $(this).each(function() {
      var textarea = $(this);
      var label = $("label[for=" + textarea.attr("id") +"]");
      var helpContent = $("#govspeak_help");
      var helpLink = $(label.children("a.govspeak_help")[0]);

      helpContent.hide();
      label.after(helpContent)

      helpLink.click(function() {
        helpContent.slideToggle();
        return false;
      })
    })
  }

  $.fn.extend({
    enableGovspeakHelp: _enableGovspeakHelp
  });
})(jQuery);

jQuery(function() {
  jQuery("textarea.govspeak").enableGovspeakHelp();
})