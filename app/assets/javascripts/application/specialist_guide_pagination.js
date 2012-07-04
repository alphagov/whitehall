$(function() {
  var container = $(".specialistguide .govspeak");
  var navigation = $(".specialistguide #document_sections");

  container.splitIntoPages("h2");
  pages = container.find(".page");
  pages.hide();

  var showDefaultPage = function() {
    pages.first().show();
  }

  var showPage = function(hash) {
    var heading = $(hash);

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

  $(window).hashchange(function() {
    if ((location.hash == "") || (location.hash == "#undefined")) {
      showDefaultPage();
    } else {
      showPage(location.hash);
    }
  })

  $(window).hashchange();
})
