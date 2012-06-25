(function($) {
  $.fn.navigationList = function(heading_selector, custom_class) {
    var list = $("<ul></ul>");
    if (custom_class != undefined) {
      list.addClass(custom_class);
    }
    $(this).find(heading_selector).each(function(i, heading) {
      var li = $("<li></li>");
      var link = $("<a>" + $(heading).text() + "</a>");
      link.attr("href", "#" + $(heading).attr("id"));
      li.append(link);
      list.append(li);
    })
    return list;
  }
})(jQuery);
