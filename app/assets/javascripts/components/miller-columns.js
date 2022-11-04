//= require miller-columns-element
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function MillerColumns (module) {
    this.module = module
    this.searchable = module.getAttribute('data-searchable') === 'true'
  }

  MillerColumns.prototype.init = function () {
    if (this.searchable) this.initSearch()
  }

  MillerColumns.prototype.initSearch = function () {
    var element = this.module.querySelector('#js-app-c-miller-columns__search')
    var input = this.module.querySelector('#js-app-c-miller-columns__search-input')
    var millerColumns = this.module.querySelector('miller-columns')

    if (!window.accessibleAutocomplete) {
      element.parentNode.removeChild(element)
      return
    }

    var topics = millerColumns.taxonomy.flattenedTopics
    var topicSuggestions = []

    topics.forEach(function (topic) {
      topicSuggestions.push({
        topic: topic,
        highlightedTopicName: topic.topicName.replace(/<\/?mark>/gm, ''), // strip existing <mark> tags
        breadcrumbs: topic.topicNames
      })
    })

    if (!topicSuggestions.length) {
      element.parentNode.removeChild(element)
      return
    }

    new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
      id: input.id,
      name: input.name,
      element: element,
      minLength: 3,
      autoselect: false,
      source: function (query, syncResults) {
        var results = topicSuggestions
        var resultMatcher = function (result) {
          var topicName = result.topic.topicName
          var indexOf = topicName.toLowerCase().indexOf(query.toLowerCase())
          var resultContainsQuery = indexOf !== -1
          if (resultContainsQuery) {
            // Wrap query in <mark> tags
            var queryRegex = new RegExp('(' + query + ')', 'ig')
            result.highlightedTopicName = topicName.replace(queryRegex, '<mark>$1</mark>')
          }
          return resultContainsQuery
        }

        syncResults(query ? results.filter(resultMatcher) : [])
      },
      templates: {
        inputValue: function (result) {
          return ''
        },
        suggestion: function (result) {
          var suggestionsBreadcrumbs
          if (result && result.breadcrumbs) {
            result.breadcrumbs[result.breadcrumbs.length - 1] = result.highlightedTopicName
            suggestionsBreadcrumbs = result.breadcrumbs.join(' › ')
          }
          return suggestionsBreadcrumbs
        }
      },
      onConfirm: function (result) {
        if (result && !result.topic.selected && !result.topic.selectedChildren.length) {
          millerColumns.taxonomy.topicClicked(result.topic)
        }
      }
    })

    element.classList.add('app-c-autocomplete--search')
    input.parentNode.removeChild(input)
  }

  Modules.MillerColumns = MillerColumns
})(window.GOVUK.Modules)
