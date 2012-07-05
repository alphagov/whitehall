$(function() {
  var container = $(".specialistguide .govspeak");
  var navigation = $(".specialistguide #document_sections");

  container.splitIntoPages("h2");
  pages = container.find(".page");
  pages.hide();

  var showPage = function() {
    var heading = $(location.hash);

    if (heading.length == 0) {
      pages.first().show();
      return;
    }

    if (heading.is(":visible")) {
      return;
    }

    pages.hide();
    heading.parents(".page").show();
    $('html, body').animate({scrollTop:heading.offset().top}, 0);
  }

  navigation.find(">li").each(function(el){
    var li = $(this),
        pageNav = li.find('>ol'),
        chapterSelector = '#' + li.find('>a').attr('href').split('#')[1],
        inPageNavigation = $("<div class='in-page-navigation'><h3>On this page</h3></div>");

    if (pageNav.length > 0) {
      inPageNavigation.append(pageNav);
      $(chapterSelector).after(inPageNavigation);
    }
  });

  $(window).hashchange(showPage)
  $(window).hashchange();
})
