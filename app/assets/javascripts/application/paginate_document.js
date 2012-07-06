$(function() {
  var container = $(".document .govspeak"),
      navigation = $(".contextual_info #document_sections"),
      pages, headings;

  var paginating = ($('.document.js-paginate-document').length > 0);

  navigation.find(">li").each(function(el){
    var li = $(this),
        pageNav = li.find('>ol'),
        chapterSelector = '#' + li.find('>a').attr('href').split('#')[1],
        inPageNavigation = $("<div class='in-page-navigation'><h3>On this page</h3></div>");

    pageNav.remove();

    if (pageNav.length > 0 && paginating) {
      inPageNavigation.append(pageNav);
      $(chapterSelector).after(inPageNavigation);
    };
  });

  if (paginating) {
    container.splitIntoPages("h2");
    pages = container.find(".page");
    headings = container.find('h2');

    var showPage = function() {
      var page = $(location.hash).parents(".page");

      pages.hide();

      if (page.length == 0) {
        pages.first().show();
      } else {
        page.show();
        $('html, body').animate({scrollTop:page.offset().top}, 0);
      }
    }

    pages.each(function(i, el){
      var currentPage = $(el),
          prevNextNavigation = [],
          adjacentPage;

      // if there is a previous page
      if(i > 0){
        adjacentPage = $(headings.get(i-1));
        prevNextNavigation.push('<li><a href="#'+adjacentPage.attr('id')+'">Previous page: <span>'+adjacentPage.text()+'</span></a></li>');
      }
      if(i < pages.length-1){
        adjacentPage = $(headings.get(i+1));
        prevNextNavigation.push('<li><a href="#'+adjacentPage.attr('id')+'">Next page: <span>'+adjacentPage.text()+'</span></a></li>');
      }

      currentPage.append('<ul class="previous-next-navigation">' + prevNextNavigation.join('') + '</ul>');
    });

    $(window).hashchange(showPage);
    $(window).hashchange();
  }
})
