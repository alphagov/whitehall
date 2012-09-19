var GOVUK = GOVUK || {}

GOVUK.paginateDocument = function() {

  var container = $(".document .govspeak"),
      navigation = $(".contextual-info #document_sections"),
      mainstreamAlternative = $('.related-mainstream-content');

  navigation.find(">li").each(function(el){
    var li = $(this),
        pageNav = li.find('>ol');

    pageNav.remove();
  });

  if(mainstreamAlternative.length){
    mainstreamAlternative.insertBefore(container.find('p').first().nextAll('p,h2,h3').first());
  }
};