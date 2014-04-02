(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function WordsToAvoidGuide(options) {
    var wordsToAvoid = [
      "agenda",
      "advancing",
      "collaborate",
      "combating",
      "commit",
      "countering",
      "deliver",
      "deploy",
      "dialogue",
      "disincentivise",
      "drive",
      "drive out",
      "empower",
      "facilitate",
      "focusing",
      "foster",
      "going forward",
      "impact",
      "initiate",
      "in order to",
      "key",
      "land",
      "leverage",
      "liaise",
      "one-stop shop",
      "overarching",
      "pledge",
      "progress",
      "promote",
      "ring fencing",
      "robust",
      "slimming down",
      "streamline",
      "strengthening",
      "tackling",
      "transforming",
      "utilise"
    ];
    var wordsToAvoidRegexps = $.map(wordsToAvoid, function(word) {
      // match whole-words only
      return "\\b" + word + "\\b";
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
