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

  equal(1, this.$fieldset.find('a').length);
});

test('should create new set of fields', function(){
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a').trigger('click');

  equal(2, this.$fieldset.find('.js-duplicate-fields-set').length);
});

test('should increment array index of new fields', function(){
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a').trigger('click');

  equal('model[2][object]', this.$fieldset.find('.js-duplicate-fields-set').last().find('input').attr('name'));
});

test('should update id and for attributes of new fields', function(){
  GOVUK.duplicateFields.init();

  this.$fieldset.find('a').trigger('click');

  var newSet = this.$fieldset.find('.js-duplicate-fields-set').last();
  equal('model_2_object', newSet.find('input').attr('id'));
  equal('model_2_object', newSet.find('label').attr('for'));
});


