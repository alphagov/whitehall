(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function WordsToAvoidGuide(options) {
    var $wordsToAvoidEls = $(options.wordsToAvoidList + " span.js-word-to-avoid"),
        wordsToAvoidRegexps = $.map($wordsToAvoidEls, function(wordEl) {
          // match whole-words only
          return "\\b" + $(wordEl).text() + "\\b";
        });

    if( window.ieVersion === undefined || window.ieVersion > 8 ){
      // in non-IE browsers or IE9+
      var enableHighlighting = true;
      GOVUK.WordsToAvoidHighlighter(wordsToAvoidRegexps, options);
    }
    GOVUK.WordsToAvoidAlerter(wordsToAvoidRegexps, $.extend(options, { highlightingEnabled: enableHighlighting }));
  }

  GOVUK.WordsToAvoidGuide = WordsToAvoidGuide;
}());
