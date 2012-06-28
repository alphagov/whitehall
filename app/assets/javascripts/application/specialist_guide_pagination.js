$(function() {
  var container = $(".specialistguide .govspeak");
  var navigation = $(".specialistguide #document_sections");

  container.splitIntoPages("h2");
  pages = container.find(".page");
  pageLinks = navigation.find("a");

  $(pages[0]).prepend($(".specialistguide .summary"));

  var showSubPage = function(e) {
    e.preventDefault();
    container.find(".page").hide();
    navigation.find(".pageNavigation").hide();
    $(this).data("page").show();
    if ($(this).data("pageNavigation")) {
      $(this).data("pageNavigation").show();
    }
  }

  pageLinks.each(function (i, pageLink) {
    pages.each(function(i, page) {
      if ($(page).find($(pageLink).attr("href")).length > 0) {
        var pageNavigation = $(page).navigationList("h3", "pageNavigation");

        $(pageLink).data("page", $(page));
        $(pageLink).data("pageNavigation", $(pageNavigation));

        $(pageLink).after(pageNavigation);

        $(pageLink).click(showSubPage)
      }
    })
  })

  $(".specialist_guide_parts li:first-child a").click();
})
