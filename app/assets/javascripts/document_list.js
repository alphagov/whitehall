(function ($) {

  var _documentList = function() {
    $(this).each(function() {
      var title_col = $(this).find('td.title');
      $(this).find('td.title').each(function () {
        var supporting_documents;
        if ((supporting_documents = $(this).find('.supporting_documents')).length > 0) {
          var toggle_link_str = supporting_documents.find('li').length + ' supporting documents';

          var grp = $.div('', {'class': 'toggle_group group'});
          var toggle_link = $.a(toggle_link_str, { 'class':'toggle', 'href':'#' });
          toggle_link.click(function () {
            supporting_documents.toggle();
            toggle_link.text(supporting_documents.is(':visible') ? 'hide' : toggle_link_str);
          });
          $(this).find('h2').wrap(grp).after(toggle_link);
          supporting_documents.hide();
        };
      });
    });
  };

  $.fn.extend({
    documentList: _documentList
  });
})(jQuery);

jQuery(function() {
  jQuery(".resource_list table.documents").documentList();
})