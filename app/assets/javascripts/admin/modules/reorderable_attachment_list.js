(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function ReorderableAttachmentsList(options) {
    var $el = $(options.el);

    $el.addClass('js-sortable');

    $el.sortable({
      stop: function (event, ui) {
        $(this).find('input.ordering').each( function (index, input) {
          $(input).val(index);
        });
      }
    });
  }

  GOVUK.ReorderableAttachmentsList = ReorderableAttachmentsList;
}());
