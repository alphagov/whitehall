module("autoComplete", {
  setup: function(){
    this.$textarea = $('<textarea id="my-textarea"></textarea>');
    $('#qunit-fixture').append(this.$textarea);

    this.allSuggestions = {
      contacts: [
        { id: 1, title: 'me', summary: 'about me' },
        { id: 2, title: 'you', summary: 'all you, all the time' },
        { id: 3, title: 'them', summary: 'them includes me and you' }
      ]
    };
  }
});

test("getMatch should find new match", function(){
  var originalSelectionEnd = GOVUK.autoCompleter.selectionEnd;
  GOVUK.autoCompleter.textarea = this.$textarea[0];
  GOVUK.autoCompleter.selectionEnd = function(){ return 66; };
  this.$textarea.val('[Contact:me');

  deepEqual(GOVUK.autoCompleter.getMatch(), { changed: true, type: 'contacts', match: '[Contact:me', query: 'me', position: 66 });

  GOVUK.autoCompleter.selectionEnd = originalSelectionEnd;
});

test("getMatch should return not changed if value hasn't changed", function(){
  var originalSelectionEnd = GOVUK.autoCompleter.selectionEnd;
  GOVUK.autoCompleter.textarea = this.$textarea[0];
  GOVUK.autoCompleter.selectionEnd = function(){ return 66; };
  this.$textarea.val('[Contact:me');

  GOVUK.autoCompleter.getMatch();
  deepEqual(GOVUK.autoCompleter.getMatch(), { changed: false });

  GOVUK.autoCompleter.selectionEnd = originalSelectionEnd;
});

test("getMatch should return false if no match found", function(){
  var originalSelectionEnd = GOVUK.autoCompleter.selectionEnd;
  GOVUK.autoCompleter.textarea = this.$textarea[0];
  GOVUK.autoCompleter.selectionEnd = function(){ return 66; };

  ok(!GOVUK.autoCompleter.getMatch());

  GOVUK.autoCompleter.selectionEnd = originalSelectionEnd;
});

test("search finds correct suggestions", function(){
  var originalSuggestions = GOVUK.autoCompleter.allSuggestions;
  GOVUK.autoCompleter.allSuggestions = this.allSuggestions;

  deepEqual(GOVUK.autoCompleter.search('contacts', 'about me'), [this.allSuggestions.contacts[0]]);
  deepEqual(GOVUK.autoCompleter.search('contacts', '1'), [this.allSuggestions.contacts[0]]);
  deepEqual(GOVUK.autoCompleter.search('contacts', 'you'), [this.allSuggestions.contacts[1], this.allSuggestions.contacts[2]]);
  deepEqual(GOVUK.autoCompleter.search('contacts', 'nothing'), []);

  GOVUK.autoCompleter.allSuggestions = originalSuggestions;
});

test("displays matched options", function(){
  var originalSuggestions = GOVUK.autoCompleter.suggestions;
  GOVUK.autoCompleter.suggestions = this.allSuggestions.contacts;
  var originalSelector = GOVUK.autoCompleter.$selector;
  var selector = $('<div>');
  GOVUK.autoCompleter.$selector = selector;

  GOVUK.autoCompleter.displayOptions();

  equal(selector.find('li').length, 3);
  ok(selector.text().match(/about me/));
  ok(selector.text().match(/all you, all the time/));
  ok(selector.text().match(/them includes me and you/));

  GOVUK.autoCompleter.suggestions = originalSuggestions;
  GOVUK.autoCompleter.$selector = originalSelector;
});

test("sets active selection", function(){
  var originalSuggestions = GOVUK.autoCompleter.suggestions;
  GOVUK.autoCompleter.suggestions = this.allSuggestions.contacts;
  var originalSelector = GOVUK.autoCompleter.$selector;
  var selector = $('<div>');
  GOVUK.autoCompleter.$selector = selector;

  // make 3 options in the selector
  GOVUK.autoCompleter.displayOptions();

  GOVUK.autoCompleter.setActiveSelection(1);
  ok(selector.find('li:eq(1)').hasClass('active'))
  equal(selector.find('.active').length, 1);

  GOVUK.autoCompleter.suggestions = originalSuggestions;
  GOVUK.autoCompleter.$selector = originalSelector;
});

test("sets active selection on mouse move", function(){
  var originalSelector = GOVUK.autoCompleter.$selector;
  var selector = $('<div>'),
      li1 = $('<li>'),
      li2 = $('<li>');
  selector.append(li1);
  selector.append(li2);
  GOVUK.autoCompleter.$selector = selector;

  ok(!li1.hasClass('active'), 'not active');
  GOVUK.autoCompleter.mouseMove({ target: li1 });
  ok(li1.hasClass('active'), 'active');
  GOVUK.autoCompleter.$selector = originalSelector;
});

test("navigateUp decrements the current active if it can", function(){
  var originalSelector = GOVUK.autoCompleter.$selector;
  GOVUK.autoCompleter.$selector = $('<div> <li></li> <li></li> <li></li> </div>');
  GOVUK.autoCompleter.active = true;

  GOVUK.autoCompleter.activeSelector = 2;
  GOVUK.autoCompleter.navigateUp();
  equal(GOVUK.autoCompleter.activeSelector, 1);
  GOVUK.autoCompleter.navigateUp();
  equal(GOVUK.autoCompleter.activeSelector, 0);
  GOVUK.autoCompleter.navigateUp();
  equal(GOVUK.autoCompleter.activeSelector, 0);

  GOVUK.autoCompleter.active = false;
  GOVUK.autoCompleter.$selector = originalSelector;
});

test("navigateDown decrements the current active if it can", function(){
  var originalSelector = GOVUK.autoCompleter.$selector;
  GOVUK.autoCompleter.$selector = $('<div> <li></li> <li></li> <li></li> </div>');
  GOVUK.autoCompleter.active = true;
  GOVUK.autoCompleter.selectorCount = 3;

  GOVUK.autoCompleter.activeSelector = 0;
  GOVUK.autoCompleter.navigateDown();
  equal(GOVUK.autoCompleter.activeSelector, 1);
  GOVUK.autoCompleter.navigateDown();
  equal(GOVUK.autoCompleter.activeSelector, 2);
  GOVUK.autoCompleter.navigateDown();
  equal(GOVUK.autoCompleter.activeSelector, 2);

  GOVUK.autoCompleter.active = false;
  GOVUK.autoCompleter.$selector = originalSelector;
});

test("navigateEnter uses the current selected option", function(){
  var originalSuggestions = GOVUK.autoCompleter.suggestions;
  GOVUK.autoCompleter.suggestions = this.allSuggestions.contacts;
  GOVUK.autoCompleter.activeSelector = 2;
  GOVUK.autoCompleter.active = true;
  GOVUK.autoCompleter.textarea = this.$textarea[0];
  GOVUK.autoCompleter.match = {
    position: 10,
    type: 'contacts'
  }
  this.$textarea.val('[Contact:');

  GOVUK.autoCompleter.navigateEnter();
  equal(this.$textarea.val(), '[Contact:3] ')

  GOVUK.autoCompleter.suggestions = originalSuggestions;
});

