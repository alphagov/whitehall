$(function() {
  var container = $(".specialistguide .govspeak"),
      navigation = $(".specialistguide #document_sections"),
      pages, headings;

  container.splitIntoPages("h2");
  pages = container.find(".page");
  pages.hide();
  headings = container.find('h2');

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

  pages.each(function(i, el){
    var currentPage = $(el),
        prevNextNavigation = [],
        adjacentPage;

    // if there is a previous page
    if(i > 0){
      adjacentPage = $(headings.get(i-1));
      prevNextNavigation.push('<li><a href="#'+adjacentPage.attr('id')+'">Previous Chapter: <span>'+adjacentPage.text()+'</span></a></li>');
    }
    if(i < pages.length-1){
      adjacentPage = $(headings.get(i+1));
      prevNextNavigation.push('<li><a href="#'+adjacentPage.attr('id')+'">Next Chapter: <span>'+adjacentPage.text()+'</span></a></li>');
    }

    currentPage.append('<ul class="previous-next-navigation">' + prevNextNavigation.join('') + '</ul>');
  });

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
