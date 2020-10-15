(function ($) {
  'use strict'
  function getOffset (el) {
    return parseInt(el.position().top, 10)
  }

  $.fn.hideExtraRows = function (options) {
    options = $.extend({
      rows: 1
    }, options)

    this.each(function (i, el) {
      var $children = $(el).contents()
      var $hiddenElements = $('<span class="js-hidden" />')

      if ($children.length > 1) {
        // measure the height of the first element
        var $firstElement = $children.filter(function () { return this.nodeType === 1 }).first()
        var firstTop = getOffset($firstElement)
        var lineCount = 0

        $children.slice(1).each(function (i, el) {
          if (el.nodeType === 1 && (lineCount < options.rows) && getOffset($(el)) > firstTop) {
            firstTop = getOffset($(el))
            lineCount = lineCount + 1
          }
          if (lineCount >= options.rows) {
            $hiddenElements[0].appendChild(el)
          }
        })

        if ($hiddenElements.contents().length > 0) {
          var openButton = $('<a class="show-other-content govuk-link" href="#" title="Show additional content"><span class="plus">+&nbsp;</span>others</a>')

          openButton.on('click', function (e) {
            e.preventDefault()
            $hiddenElements.removeClass('js-hidden').focus()
            if (options.showWrapper) {
              options.showWrapper.remove()
            } else {
              $(e.target).remove()
            }
          })

          $(el).append($hiddenElements)

          if (options.showWrapper) {
            openButton = options.showWrapper.append(openButton)
          }

          if (options.appendToParent) {
            $children.first().parent().append(openButton)
          } else {
            $children.first().parent().after(openButton)
          }
        }
      }
    })
    return this
  }
}(jQuery))
