module("documentFinder", {
  setup: function(){

    this.$finderForm = $('<form id="document-finder action="/search/path">' +
      '<input type="search" name="title" value="">' +
      '<input type="submit" value="Search">' +
      '</form>');

    this.$finderResults = $('<div class="js-doc-finder-results"></div>');

    this.requestData = {
      'results_any?': true,
      'results': [
        {
          'id': 1,
          'title': 'First title',
          'type': 'publication',
          'url': '/admin/publications/1'
        },
        {
          'id': 2,
          'title': 'Second title',
          'type': 'speech',
          'url': '/admin/speeches/2'
        }
      ]
    }

    $('#qunit-fixture')
      .append(this.$finderForm)
      .append(this.$finderResults);

    GOVUK.documentFinder.init('#document-finder');
  }
});

test('showResults renders no-results message when there are no results', function() {
  GOVUK.documentFinder.$results = this.$finderResults;
  GOVUK.documentFinder.showResults(null, { 'results_any?': false });

  equals(this.$finderResults.find('ul').length, 0);
  equals(this.$finderResults.find('.no-results').length, 1);
});

test("showResults renders results when there are some", function(){
  GOVUK.documentFinder.$results = this.$finderResults;
  GOVUK.documentFinder.showResults(null, this.requestData);

  equals(this.$finderResults.find('ul.document-list li.document-row').length, 2);
  equals(this.$finderResults.find('.no-results').length, 0);

  equals(this.$finderResults.find('ul li#search_publication_1 a[href="/admin/publications/1"]').text(), 'First title');
  equals(this.$finderResults.find('ul li#search_speech_2 a[href="/admin/speeches/2"]').text(), 'Second title');
});
