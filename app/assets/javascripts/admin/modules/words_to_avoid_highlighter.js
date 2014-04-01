(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function WordsToAvoidGuide(options) {
    var $el = $(options.el),
        $wordsToAvoidAlert = $(options.wordsToAvoidAlert),
        $wordsToAvoidCounter = $(options.wordsToAvoidCounter),
        $textareaHighlightSelector = "span.highlight",
        $wordsToAvoid = [
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

    var $wordsToAvoidRegexps = $.map($wordsToAvoid, function(word) {
      // match whole-words only
      return "\\b" + word + "\\b";
    });

    // without instantiating an instance of the widget
    // per textarea, the `disable` and `enable` calls
    // to the widget don't work as expected.
    $.map($el, function(textarea) {
      $(textarea).highlightTextarea({
        color: '#FFB040',
        caseSensitive: false,
        words: $wordsToAvoidRegexps
      });
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

    var disable = function() {
      $.map($el, function(textarea) {
        $(textarea).highlightTextarea('disable');
      });
      $($textareaHighlightSelector).hide();
      $wordsToAvoidAlert.hide();
    }
    $(document).bind("govuk.WordsToAvoidGuide.disable", disable);

    var enable = function() {
      $.map($el, function(textarea) {
        $(textarea).highlightTextarea('highlight');
      });
      $($textareaHighlightSelector).show();
      updateHighlightedWordsCount();
    }
    $(document).bind("govuk.WordsToAvoidGuide.enable", enable);
  }

  GOVUK.WordsToAvoidGuide = WordsToAvoidGuide;
}());
