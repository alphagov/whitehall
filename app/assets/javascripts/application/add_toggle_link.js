(function($) {
  var _addToggleLink = function(contentSelector) {
    var section = $(this);
    var content = $(contentSelector, section);

    content.hide();
    var toggleLink = $.a("show", {class: "toggle", href: "#"});
    $("h1", section).append(toggleLink);
    toggleLink.click(function() {
      var currentLinkText = $(this).text();
      if (currentLinkText == "show") {
        $(this).text("hide");
      } else {
        $(this).text("show");
      }
      content.toggle();
    });
  };

  $.fn.extend({
    addToggleLink: _addToggleLink
  });
})(jQuery);