(function ($) {
  var _documentInList = function(titleSel, supportingPageSel, toWrap) {
    $(this).each(function() {
      var document = $(this);
      var title_col = $(document).find(titleSel);
      $(this).find('td.title').each(function () {
        var supporting_pages;
        if ((supporting_pages = $(this).find(supportingPageSel)).length > 0) {
          var toggle_link_str = supporting_pages.find('li').length + ' supporting pages';
          var grp = $.div('', {'class': 'toggle_group group'});
          var toggle_link = $.a(toggle_link_str, { 'class':'toggle', 'href': "#"+document.attr('id') });
          toggle_link.click(function () {
            supporting_pages.toggle();
            toggle_link.text(supporting_pages.is(':visible') ? 'hide' : toggle_link_str);
            return false;
          });
          $(this).find(toWrap).wrap(grp).after(toggle_link);
          supporting_pages.hide();
        };
      });
    });
  };
  $.fn.extend({
    documentInList: _documentInList
  });
  $(function() {
    $(".documents table tr").documentInList('td.title', '.supporting_pages', 'span.title');
  });
})(jQuery);
