(function () {
  "use strict";
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var documentSeriesCheckboxSelector = {
    init: function() {
      var checkboxes = $.find('section.group ul.controls input:checkbox');
      $(checkboxes).click(function() {
        var to_toggle = $(this)
          .parents('section.group')
          .find('ol.document-list input:checkbox');
        $(to_toggle).prop('checked', $(this).is(':checked'));
      });
    }
  };
  root.GOVUK.documentSeriesCheckboxSelector = documentSeriesCheckboxSelector;
}).call(this);
