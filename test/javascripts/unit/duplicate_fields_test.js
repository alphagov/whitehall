module("duplicate_fields", {
  setup: function() {
    this.$fieldset = $('<fieldset class="js-duplicate-fields"><div class="js-duplicate-fields-set"></div></fieldset>');
    this.$label = $('<label for="model_1_object">label</label>');
    this.$input = $('<input type="text" name="model[1][object]" id="model_1_object">');

    $('#qunit-fixture').append(this.$fieldset);
    this.$fieldset.find('div').append(this.$label).append(this.$input);
  }
});

test('should add button to add more fields on init', function(){
  GOVUK.duplicateFields.init();

  equal(1, this.$fieldset.find('a.js-add-button').length);
});


test('should add button to remove fields on init', function(){
  GOVUK.duplicateFields.init();

  equal(1, this.$fieldset.find('div.js-duplicate-fields-set a.js-remove-button').length);
});

test('should create new set of fields', function(){
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a.js-add-button').trigger('click');

  equal(2, this.$fieldset.find('.js-duplicate-fields-set').length);
});

test('should increment array index of new fields', function(){
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a.js-add-button').trigger('click');

  equal('model[2][object]', this.$fieldset.find('.js-duplicate-fields-set').last().find('input').attr('name'));
});

test('should increment second array index of new fields that have more than one array index', function(){
  this.$input.attr('name', 'model[1][attribute][0][object]');

  GOVUK.duplicateFields.init();

  this.$fieldset.find('a.js-add-button').trigger('click');

  equal('model[1][attribute][1][object]', this.$fieldset.find('.js-duplicate-fields-set').last().find('input').attr('name'));
});

test('should update id and for attributes of new fields', function(){
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a.js-add-button').trigger('click');

  var newSet = this.$fieldset.find('.js-duplicate-fields-set').last();
  equal('model_2_object', newSet.find('input').attr('id'));
  equal('model_2_object', newSet.find('label').attr('for'));
});

test('should increment second index of id and for attributes of new fields', function(){
  this.$label.attr('for', 'model_1_attribute_0_object');
  this.$input.attr('id', 'model_1_attribute_0_object');
  this.$input.attr('name', 'model[1][attribute][0][object]');
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a.js-add-button').trigger('click');

  var newSet = this.$fieldset.find('.js-duplicate-fields-set').last();
  equal('model_1_attribute_1_object', newSet.find('input').attr('id'));
  equal('model_1_attribute_1_object', newSet.find('label').attr('for'));
});


test('should hide field set when removing', function(){
  GOVUK.duplicateFields.init();
  var set = this.$fieldset.find('.js-duplicate-fields-set').last();

  set.find('a.js-remove-button').trigger('click');

  equal(set.is(':visible'), false);
});

test('should resets input values when removing', function(){
  GOVUK.duplicateFields.init();
  var set = this.$fieldset.find('.js-duplicate-fields-set').last();

  set.find('input').val('some value');
  set.find('a.js-remove-button').trigger('click');

  equal(set.find('input').val(),'');
});

test('should add a hidden _destroy input when removing', function(){
  GOVUK.duplicateFields.init();
  var set = this.$fieldset.find('.js-duplicate-fields-set').last();

  set.find('a.js-remove-button').trigger('click');

  equal(set.find('input#model_1__destroy').length, 1);
  equal(set.find('input#model_1__destroy').attr('name'), 'model[1][_destroy]');
  equal(set.find('input#model_1__destroy').val(), 'true');
});


module('duplicate_fields when last remaining field set has been "removed"', {
  setup: function() {
    this.$fieldset = $('<fieldset class="js-duplicate-fields"><div class="js-duplicate-fields-set"></div></fieldset>');
    this.$label = $('<label for="model_1_object">label</label>');
    this.$input = $('<input type="text" name="model[1][object]" id="model_1_object">');

    $('#qunit-fixture').append(this.$fieldset);
    this.$fieldset.find('div').append(this.$label).append(this.$input);

    GOVUK.duplicateFields.init();
    var set = this.$fieldset.find('.js-duplicate-fields-set').last();
    set.find('a.js-remove-button').trigger('click');
  }
});

test("should reset the _destroy input when adding", function(){
  this.$fieldset.find('a.js-add-button').trigger('click');
  var newSet = this.$fieldset.find('.js-duplicate-fields-set').last();

  equal(newSet.find('input#model_2__destroy').val(), '');
});

test('should make the new field set visible when adding', function(){
  this.$fieldset.find('a.js-add-button').trigger('click');
  var newSet = this.$fieldset.find('.js-duplicate-fields-set').last();

  equal(newSet.is(':visible'), true);
});


module("duplicate_fields with a field set marked for removal", {
  setup: function() {
    this.$fieldset = $('<fieldset class="js-duplicate-fields"></fieldset>');
    this.$presentFieldSet = $('<div class="js-duplicate-fields-set"><label for="model_1_object">label</label><input type="text" name="model[1][object]" id="model_1_object"></div>');
    this.$destroyedFieldSet = $('<div class="js-duplicate-fields-set"><label for="model_1_object">label</label><input type="text" name="model[1][object]" id="model_1_object"><input class="js-hidden-destroy" type="hidden" name="model[1][_destroy]" id="model_1__destroy" value="true"></div>');
    this.$fieldset.append(this.$presentFieldSet);
    this.$fieldset.append(this.$destroyedFieldSet);
    $('#qunit-fixture').append(this.$fieldset);
  }
});

test('should hide field sets marked for removal', function() {
  GOVUK.duplicateFields.init();

  equal(this.$presentFieldSet.is(':visible'), true);
  equal(this.$destroyedFieldSet.is(':visible'), false);
});
