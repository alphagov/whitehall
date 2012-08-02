$(function() {
  var container = $(".document .govspeak"),
      navigation = $(".contextual-info #document_sections"),
      mainstreamAlternative = $('.related-mainstream-content'),
      pages, headings, navigationLinks;

  var paginating = ($('.js-paginate-document').length > 0 && $(window).width() > 768);

  var escapeId = function(id) {
    return id.replace(/(:|\.)/g,'\\$1');
  }

  navigation.find(">li").each(function(el){
    var li = $(this),
        pageNav = li.find('>ol'),
        chapterSelector = '#' + li.find('>a').attr('href').split('#')[1],
        inPageNavigation = $("<div class='in-page-navigation'><nav role='navigation'><h3>On this page</h3></nav></div>");

    pageNav.remove();

    if (pageNav.length > 0 && paginating) {
      inPageNavigation.find('nav').append(pageNav);
      $(chapterSelector).after(inPageNavigation);
    };
  });

  if(mainstreamAlternative.length){
    mainstreamAlternative.insertAfter(container.children().get(1));
  }

  if (paginating) {
    container.splitIntoPages("h2");
    pages = container.find(".page");
    headings = container.find('h2');
    navigationLinks = navigation.find('a');

    var showPage = function(a) {
      var page = $(escapeId(location.hash)).parents(".page");
      var pageId = $(page).find('h2').attr('id')

      pages.not(page).addClass('hidden');
      navigationLinks.removeClass('active');

      if (page.length == 0) {
        pages.first().removeClass('hidden');
        navigationLinks.first().addClass('active')
      } else {
        page.removeClass('hidden');
        navigationLinks.filter('a[href$='+pageId+']').addClass('active');
        if (location.hash == ('#' + pageId)) {
          // html and body selector for IE 8.
          $('html, body').animate({scrollTop:0}, 0);
        } else {
          // This looks mad, but forces the browser to scroll to the anchor that may have been
          // invisible when the link was first clicked.  A footnote, for example.
          document.location = document.location
        }
      }
    }

    pages.each(function(i, el){
      var currentPage = $(el),
          prevNextNavigation = [],
          adjacentPage;

      // if there is a previous page
      if(i > 0){
        adjacentPage = $(headings.get(i-1));
        prevNextNavigation.push('<li class="previous"><a href="#'+adjacentPage.attr('id')+'">Previous page <span>'+adjacentPage.text()+'</span></a></li>');
      }
      if(i < pages.length-1){
        adjacentPage = $(headings.get(i+1));
        prevNextNavigation.push('<li class="next"><a href="#'+adjacentPage.attr('id')+'">Next page <span>'+adjacentPage.text()+'</span></a></li>');
      }

      currentPage.append('<nav role="navigation"><ul class="previous-next-navigation">' + prevNextNavigation.join('') + '</ul></nav>');
    });

    $(window).hashchange(showPage);
    $(window).hashchange();
  }
})
