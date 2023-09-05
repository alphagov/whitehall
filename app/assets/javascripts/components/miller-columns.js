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
    const element = this.module.querySelector('#js-app-c-miller-columns__search')
    const input = this.module.querySelector('#js-app-c-miller-columns__search-input')
    const millerColumns = this.module.querySelector('miller-columns')

    if (!window.accessibleAutocomplete) {
      element.parentNode.removeChild(element)
      return
    }

    const topics = millerColumns.taxonomy.flattenedTopics
    const topicSuggestions = []

    topics.forEach(function (topic) {
      topicSuggestions.push({
        topic,
        highlightedTopicName: topic.topicName.replace(/<\/?mark>/gm, ''), // strip existing <mark> tags
        breadcrumbs: topic.topicNames
      })
    })

    if (!topicSuggestions.length) {
      element.parentNode.removeChild(element)
      return
    }

    // prettier-ignore
    new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
      id: input.id,
      name: input.name,
      element,
      minLength: 3,
      autoselect: false,
      source: function (query, syncResults) {
        const results = topicSuggestions
        const resultMatcher = function (result) {
          const topicName = result.topic.topicName
          const indexOf = topicName.toLowerCase().indexOf(query.toLowerCase())
          const resultContainsQuery = indexOf !== -1
          if (resultContainsQuery) {
            // Wrap query in <mark> tags
            const queryRegex = new RegExp('(' + query + ')', 'ig')
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
          let suggestionsBreadcrumbs
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
