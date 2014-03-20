(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function WordsToAvoidHighlighter(options) {
    var $el = $(options.el),
        $wordsToAvoidAlert = $(options.wordsToAvoidAlert),
        $wordsToAvoidCounter = $(options.wordsToAvoidCounter);

    $el.highlightTextarea({
      color: '#FFB040',
      caseSensitive: false,
      words: [
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
      ]
    });

    var updateHighlightedWordsCount = function() {
      var numberOfHighlightedWords = $(".highlighter span.highlight").length;

      if(numberOfHighlightedWords) {
        $wordsToAvoidAlert.show();
        $wordsToAvoidCounter.html(numberOfHighlightedWords);
      } else {
        $wordsToAvoidAlert.hide();
      }
    }
    $el.debounce("keyup", updateHighlightedWordsCount, 500);
    updateHighlightedWordsCount();
  }

  GOVUK.WordsToAvoidHighlighter = WordsToAvoidHighlighter;
}());
