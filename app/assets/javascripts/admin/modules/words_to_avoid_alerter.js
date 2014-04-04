(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function WordsToAvoidAlerter(wordsToAvoidRegexps, options) {
    var $el = $(options.el),
        $wordsToAvoidAlert = $(options.wordsToAvoidAlert),
        $alertSpan = $("<span />").attr("id", "js-words-to-avoid-count").addClass("badge badge-warning"),
        wordsToAvoidMatcher = new RegExp("(" + wordsToAvoidRegexps.join("|") + ")", "gi"),
        wordsToAvoidUsedSpan = $("<span />").attr("id", "js-words-to-avoid-used");

    var initAlertMessageTemplate = function() {
      $wordsToAvoidAlert.append($alertSpan);
      if(options.highlightingEnabled) {
        $wordsToAvoidAlert.append(" highlighted word(s) appear on the words to avoid list:");
      } else {
        $wordsToAvoidAlert.append(" word(s) appear on the words to avoid list:")
      }
      $wordsToAvoidAlert.append(wordsToAvoidUsedSpan);
    }
    initAlertMessageTemplate();

    var wordsToAvoidUsed = function() {
      if(options.highlightingEnabled) {
        // use optimised way and look for highlighted words
        return $.distinct($.map($(".highlighter span.highlight"), function(highlightedEl) {
          return $(highlightedEl).text();
        }));
      } else {
        var textToSearchIn = [];
        $el.each(function() {
          textToSearchIn.push($(this).val());
        });
        return $.distinct(textToSearchIn.join(" ").match(wordsToAvoidMatcher) || []);
      }
    }

    var numberOfWordsToAvoidUsed = function() {
      if(options.highlightingEnabled) {
        return $(".highlighter span.highlight").length;
      } else {
        return wordsToAvoidUsed().length;
      }
    }

    var listOfWordsToAvoidUsed = function() {
      var _wordsToAvoidUsed = wordsToAvoidUsed();
      var list = $.map(_wordsToAvoidUsed, function(word) {
        return $("<li />").html(word);
      });
      return $("<ul />").append(list);
    }

    var $updateAlert = function() {
      var _numberOfWordsToAvoidUsed = numberOfWordsToAvoidUsed();

      if(_numberOfWordsToAvoidUsed) {
        $wordsToAvoidAlert.show();
        $(options.wordsToAvoidCounter).html(_numberOfWordsToAvoidUsed);
        $(wordsToAvoidUsedSpan).html(listOfWordsToAvoidUsed());
      } else {
        $wordsToAvoidAlert.hide();
      }
    }
    $el.debounce("keyup", $updateAlert, 500);
    $updateAlert();

    var disable = function() {
      $wordsToAvoidAlert.hide();
    }
    $(document).bind("govuk.WordsToAvoidGuide.disable", disable);

    var enable = function() {
      $updateAlert();
    }
    $(document).bind("govuk.WordsToAvoidGuide.enable", enable);
  }

  GOVUK.WordsToAvoidAlerter = WordsToAvoidAlerter;
}());
