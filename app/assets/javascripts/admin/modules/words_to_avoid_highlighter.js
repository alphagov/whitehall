(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function WordsToAvoidHighlighter(wordsToAvoidRegexps, options) {
    var $el = $(options.el),
        textareaHighlightSelector = "span.highlight"

    $.map($el, function(textarea) {
      $(textarea).highlightTextarea({
        color: '#FFB040',
        caseSensitive: false,
        words: wordsToAvoidRegexps
      });
    });

    var disable = function() {
      $.map($el, function(textarea) {
        $(textarea).highlightTextarea('disable');
      });
      $(textareaHighlightSelector).hide();
    }
    $(document).bind("govuk.WordsToAvoidGuide.disable", disable);

    var enable = function() {
      $.map($el, function(textarea) {
        $(textarea).highlightTextarea('highlight');
      });
      $(textareaHighlightSelector).show();
    }
    $(document).bind("govuk.WordsToAvoidGuide.enable", enable);
  }

  GOVUK.WordsToAvoidHighlighter = WordsToAvoidHighlighter;
}());
