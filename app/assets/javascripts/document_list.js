(function ($) {
  var _documentInList = function(titleSel, supportingDocSel, toWrap) {
    $(this).each(function() {
      var document = $(this);
      var title_col = $(document).find(titleSel);
      $(this).find('td.title').each(function () {
        var supporting_documents;
        if ((supporting_documents = $(this).find(supportingDocSel)).length > 0) {
          var toggle_link_str = supporting_documents.find('li').length + ' supporting documents';
          var grp = $.div('', {'class': 'toggle_group group'});
          var toggle_link = $.a(toggle_link_str, { 'class':'toggle', 'href': "#"+document.attr('id') });
          toggle_link.click(function () {
            supporting_documents.toggle();
            toggle_link.text(supporting_documents.is(':visible') ? 'hide' : toggle_link_str);
            return false;
          });
          $(this).find(toWrap).wrap(grp).after(toggle_link);
          supporting_documents.hide();
        };
      });
    });
  };
  $.fn.extend({
    documentInList: _documentInList
  });
  $(function() {
    $(".resource_list table.documents tr").documentInList('td.title', '.supporting_documents', 'h2');
  });
})(jQuery);

