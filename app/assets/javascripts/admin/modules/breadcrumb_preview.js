(function (Modules) {
  'use strict'

  Modules.BreadcrumbPreview = function () {
    var preview = this

    preview.fetchCheckedCheckboxes = function () {
      return $('.topic-tree :checked')
    }

    preview.buildBreadcrumbsStructure = function (checkboxes) {
      var structure = $.map(checkboxes, function (checkbox) {
        var $checkbox = $(checkbox)
        var ancestors = $checkbox.data('ancestors').split('|')

        return {
          checkbox: checkbox,
          ancestors: ancestors
        }
      })

      return structure
    }

    preview.renderUpdatedBreadcrumbs = function ($element) {
      var checkboxes = preview.fetchCheckedCheckboxes()
      var breadcrumbsArray = preview.buildBreadcrumbsStructure(checkboxes)
      var breadcrumbsToDisplay = preview.filterBreadcrumbs(breadcrumbsArray)

      if (breadcrumbsToDisplay.length === 0) {
        $element.removeClass('content').removeClass('content-bordered')
        $element.addClass('no-content').addClass('no-content-bordered')
        $element.text('No topic taxonomy tags - please add a tag before publishing')
      } else {
        $element.addClass('content').addClass('content-bordered')
        $element.removeClass('no-content').removeClass('no-content-bordered')

        preview.appendBreadcrumbsHtml($element, breadcrumbsToDisplay)
      }
    }

    preview.appendBreadcrumbsHtml = function ($container, breadcrumbs) {
      $container.empty()

      var breadcrumbElements = $.map(breadcrumbs, function (breadcrumb, index) {
        var $element = $('<div class="taxon-breadcrumb">' +
          '<ol></ol>' +
          '<button type="button" class="close" aria-label="Deselect topic">' +
            '<span aria-hidden="true">&times;</span>' +
          '</button>' +
          '</div>')

        var $ancestors = $.map(breadcrumb.ancestors, function (ancestor) {
          var $ancestorElement = $('<li />')
          $ancestorElement.text(ancestor)
          return $ancestorElement
        })

        $element.find('ol').append($ancestors)

        $element.find('button').on('click', function () {
          $(breadcrumbs[index].checkbox).trigger('click')
        })

        return $element
      })

      $container.append(breadcrumbElements)
    }

    preview.filterBreadcrumbs = function (breadcrumbs) {
      var longestFirst = breadcrumbs.sort(function (a, b) {
        return b.ancestors.length - a.ancestors.length
      })

      var breadcrumbsToDisplay = []

      $.each(longestFirst, function (index, breadcrumb) {
        var visited = false

        $.each(breadcrumbsToDisplay, function (index, visitedBreadcrumb) {
          var breadcrumbString = JSON.stringify(breadcrumb.ancestors)
          var visitedBreadcrumbString = JSON.stringify(
            visitedBreadcrumb.ancestors.slice(0, breadcrumb.ancestors.length)
          )

          if (breadcrumbString === visitedBreadcrumbString) {
            visited = true
          }
        })

        if (!visited) {
          breadcrumbsToDisplay.push(breadcrumb)
        }
      })

      return breadcrumbsToDisplay
    }

    preview.start = function (element) {
      var $element = $(element)
      $element.removeClass('hidden')

      var $topicTree = $('.topic-tree input:checkbox')

      var renderUpdatedBreadcrumbsForElement = function () {
        preview.renderUpdatedBreadcrumbs($element)
      }

      renderUpdatedBreadcrumbsForElement()
      $topicTree.on('change', renderUpdatedBreadcrumbsForElement)
    }
  }
})(window.GOVUKAdmin.Modules)
