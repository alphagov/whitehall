(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  function WordsToAvoidGuide (options) {
    var $wordsToAvoidEls = $(options.wordsToAvoidList + ' span.js-word-to-avoid')
    var wordsToAvoidRegexps = $.map($wordsToAvoidEls, function (wordEl) {
      // match whole-words only
      return '\\b' + $(wordEl).text() + '\\b'
    })

    GOVUK.WordsToAvoidHighlighter(wordsToAvoidRegexps, options)
    GOVUK.WordsToAvoidAlerter(wordsToAvoidRegexps, $.extend(options, { highlightingEnabled: true }))
  }

  GOVUK.WordsToAvoidGuide = WordsToAvoidGuide
}())
