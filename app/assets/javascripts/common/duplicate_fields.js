(function () {
  'use strict'
  var root = this
  var $ = root.jQuery
  if (typeof root.GOVUK === 'undefined') { root.GOVUK = {} }

  var duplicateFields = {
    init: function () {
      duplicateFields.$sets = $('.js-duplicate-fields')

      duplicateFields.addButton()
      duplicateFields.removeButton()
      duplicateFields.hideDestroyedFields()
    },
    addButton: function () {
      duplicateFields.$sets.each(function () {
        var $set = $(this)
        var $button = $('<a href="#" class="btn btn-default add-bottom-margin add_new js-add-button">Add another</a>')

        $set.append($button)
        $button.on('click', duplicateFields.addFields)
      })
    },
    addFields: function (e) {
      e.preventDefault()
      var $button = $(e.target)
      var $set = $button.closest('.js-duplicate-fields')
      var $fields = $set.find('.js-duplicate-fields-set').last()
      var $newFields = $fields.clone(true)

      $newFields.find('input[type=text], input[type=hidden], textarea').val('')
      $newFields.show()
      duplicateFields.incrementIndexes($newFields)
      $button.before($newFields)
    },
    removeButton: function () {
      duplicateFields.$sets.each(function () {
        var $set = $(this)
        var $button = $('<a href="#" class="btn btn-danger js-remove-button">Remove</a>')
        var $fields = $set.find('.js-duplicate-fields-set')

        $fields.append($button)
        $fields.find('a.js-remove-button').on('click', duplicateFields.removeFields)
      })
    },
    removeFields: function (e) {
      e.preventDefault()
      var $button = $(e.target)
      var $set = $button.closest('.js-duplicate-fields-set')

      var $destroyInput = duplicateFields.destroyInputFor($set)

      $set.hide()
      $set.find('input').val('')
      $set.append($destroyInput)
    },
    destroyInputFor: function (set) {
      var $textInput = set.find('input[type=text], textarea').first()
      var baseName = $textInput.attr('name')
      var baseId = $textInput.attr('id')
      var destroyId = baseId.replace(/_[a-zA-Z]+$/, '__destroy')
      var destroyName = baseName.replace(/\[[_a-zA-Z]+\]$/, '[_destroy]')

      return $('<input class="js-hidden-destroy" id="' + destroyId + '" name="' + destroyName + '" type="hidden" value="true" />')
    },
    hideDestroyedFields: function () {
      duplicateFields.$sets.each(function () {
        var $set = $(this)
        var $destroyInput = $set.find('.js-hidden-destroy[value="true"], .js-hidden-destroy[value="1"]')
        var $destroyedFields = $destroyInput.closest('.js-duplicate-fields-set')

        $destroyedFields.hide()
      })
    },
    incrementIndexes: function (fields) {
      fields.find('label,input,textarea,select').each(function (i, el) {
        var $el = $(el)
        var currentName = $el.attr('name')
        var currentId = $el.attr('id')
        var currentFor = $el.attr('for')
        var index = false
        var arrayMatcher = /(.*)\[([0-9]+)\](.*?)$/
        var underscoreMatcher = /(.*)_([0-9]+)_(.*?)$/
        var matched

        if (currentName && arrayMatcher.exec(currentName)) {
          matched = arrayMatcher.exec(currentName)
          index = parseInt(matched[2], 10)
          $el.attr('name', matched[1] + '[' + (index + 1) + ']' + matched[3])
        }
        if (underscoreMatcher.exec(currentId)) {
          matched = underscoreMatcher.exec(currentId)
          if (index === false) {
            index = parseInt(matched[2], 10)
          }
          $el.attr('id', matched[1] + '_' + (index + 1) + '_' + matched[3])
        }
        if (underscoreMatcher.exec(currentFor)) {
          matched = underscoreMatcher.exec(currentFor)
          if (index === false) {
            index = parseInt(matched[2], 10)
          }
          $el.attr('for', matched[1] + '_' + (index + 1) + '_' + matched[3])
        }
      })
    }
  }
  root.GOVUK.duplicateFields = duplicateFields
}).call(this)
