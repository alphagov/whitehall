var GOVUK = GOVUK || {}

GOVUK.paginateDocument = function() {

  var navigation = $(".contextual-info #document_sections");

  navigation.find(">li").each(function(el){
    var li = $(this),
        pageNav = li.find('>ol');

    pageNav.remove();
  });
};
