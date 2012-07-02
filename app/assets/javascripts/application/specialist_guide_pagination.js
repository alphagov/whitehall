$(function() {
  var container = $(".specialistguide .govspeak");
  var navigation = $(".specialistguide #document_sections");

  container.splitIntoPages("h2");
  pages = container.find(".page");
  pageLinks = navigation.find("a");

  $(pages[0]).prepend($(".specialistguide .summary"));

  var showDefaultPage = function() {
    container.find(".page").hide();
    navigation.find(".pageNavigation").hide();

    pages.first().show();
  }

  var showPage = function(hash) {
    container.find(".page").hide();
    navigation.find(".pageNavigation").hide();

    var heading = $(hash);
    heading.parents(".page").show();

    var anchor = $("a[href$='" + hash + "']");
    var pageNavigation = anchor.parents(".pageNavigation").add(anchor.siblings(".pageNavigation"));
    pageNavigation.show();

    if (anchor.length > 0) {
      var newPosition = anchor.offset();
      window.scrollTo(newPosition.left, newPosition.top);
    }
  }

  pageLinks.each(function (i, pageLink) {
    pages.each(function(i, page) {
      if ($(page).find($(pageLink).attr("href")).length > 0) {
        var pageNavigation = $(page).navigationList("h3", "pageNavigation");
        $(pageLink).after(pageNavigation);
      }
    })
  })

  $(window).hashchange(function() {
    if ((location.hash == "") || (location.hash == "#undefined")) {
      showDefaultPage();
    } else {
      showPage(location.hash);
    }
  })

  $(window).hashchange();
})
