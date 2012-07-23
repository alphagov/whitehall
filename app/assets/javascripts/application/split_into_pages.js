(function($) {
  $.fn.splitIntoPages = function(split_selector) {
    var container = $(this);
    var pages = [];
    container.children(split_selector).each(function(i, heading) {
      var content = $(heading).nextUntil("h2");
      var page = $("<div></div>");
      page.addClass("page");
      page.append(heading);
      page.append(content);
      pages.push(page);
    })
    $(pages).each(function(i, page) {
      container.append(page);
    })
    if (container.children().first()[0] != container.children(".page").first()[0]) {
      container.children(".page").first().prepend(
        container.children().first(),
        container.children().first().nextUntil(".page")
      );
    }
  }
})(jQuery);
