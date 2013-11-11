(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  var adjustOffset = function(el, offset) {
    var val = el.value, newOffset = offset;

    var matches = val.replace(/^\n|([^\r])\n/g, "$1\r\n").slice(0, offset).match(/\r\n/g);
    newOffset -= matches ? matches.length : 0;

    return newOffset;
  };

  var highlightText = function(input, start, end) {
    if ('selectionStart' in input) {
      input.selectionStart = adjustOffset(input, start) - 2;
      input.selectionEnd = adjustOffset(input, end);
      input.focus();
    } else {  // Internet Explorer before version 9
      var inputRange = input.createTextRange();
      inputRange.moveStart("character", start);
      inputRange.collapse();
      inputRange.moveEnd("character", end - start);
      inputRange.select();
    }
  };

  window.GOVUK.govspeakLinkErrors = {
    init: function init(options) {
      $(document).ready(function() {
        $(options['selector']).find('dd').each(function() {
          var $error = $(this);

          var start = parseInt($error.data('start'), 10);
          var end   = parseInt($error.data('end')  , 10);

          $('<a>Show me</a>')
            .appendTo($error)
            .click(function() {
              highlightText($('#edition_body')[0], start, end);
            });
        });
      });
    }
  };
}());
