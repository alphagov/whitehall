module("Enhancing the organisation contact form", {
  setup: function() {
    this.form = $('<form class="organisation_edit"></form>');
    this.fieldset = $('<fieldset class="contacts"></fieldset>');
    this.form.append(this.fieldset);

    this.contactFieldset = $('<fieldset class="contact"></fieldset>');
    var fieldsetContents = function(id) {
      return '<label for="organisation_contacts_attributes_'+id+'_description">Description</label><input id="organisation_contacts_attributes_'+id+'_description" name="organisation[contacts_attributes]['+id+'][description]" size="30" type="text" value="Enquiries" /><label for="organisation_contacts_attributes_'+id+'_address">Address </label><textarea class="address" cols="40" id="organisation_contacts_attributes_'+id+'_address" name="organisation[contacts_attributes]['+id+'][address]" rows="3">some address content</textarea><label for="organisation_contacts_attributes_'+id+'_postcode">Postcode</label><input id="organisation_contacts_attributes_'+id+'_postcode" name="organisation[contacts_attributes]['+id+'][postcode]" size="30" type="text" value="" />';
    }

    this.contactFieldset.append(fieldsetContents(0));
    this.fieldset.append(this.contactFieldset);

    var emptyContactForm = $('<fieldset class="contact"></fieldset>');
    emptyContactForm.append(fieldsetContents(1));
    this.emptyFieldSet = $('<div class="empty_fields"></div>');
    this.emptyFieldSet.append(emptyContactForm);
    this.fieldset.append(this.emptyFieldSet);

    $('#qunit-fixture').append(this.form);

    this.fieldset.setupContactsForm();
  }
});

function addContact(element) { element.children("a.add_new").click(); }

test("should add an 'add' button", function() {
  equal(this.form.children("a.add_new").length, 1);
});

test("should display a new contact form when add link is clicked", function() {
  addContact(this.form);
  equal(this.fieldset.children(".contact:visible").length, 2);
});

test("should continue adding new inputs as new files are selected", function() {
  addContact(this.form);
  addContact(this.form);
  equal(this.fieldset.children(".contact:visible").length, 3);

  addContact(this.form);
  equal(this.fieldset.children(".contact:visible").length, 4);
});

test("should increment the referenced ID of the description label for each new set of inputs added", function() {
  addContact(this.form);
  var latest_input = this.fieldset.find("label:contains('Description'):last");
  equal(latest_input.attr('for'), "organisation_contacts_attributes_1_description");

  addContact(this.form);
  latest_input = this.fieldset.find("label:contains('Description'):last");
  equal(latest_input.attr('for'), "organisation_contacts_attributes_2_description");
});

test("should increment the ID and name of the text input for each set of new inputs added", function() {
  addContact(this.form);
  var latest_input = this.fieldset.find("input[type=text]:last")[0];
  equal(latest_input.id, "organisation_contacts_attributes_1_postcode");
  equal(latest_input.name, "organisation[contacts_attributes][1][postcode]");

  addContact(this.form);
  latest_input = this.fieldset.find("input[type=text]:last")[0];
  equal(latest_input.id, "organisation_contacts_attributes_2_postcode");
  equal(latest_input.name, "organisation[contacts_attributes][2][postcode]");
});

module("Add and removing contact phone numbers", {
  setup: function() {
    this.form = $('<form class="organisation_edit"></form>');
    this.fieldset = $('<fieldset class="contacts"></fieldset>');
    this.form.append(this.fieldset);

    this.contactFieldset = $('<fieldset class="contact"></fieldset>');
    this.contactNumbersFieldset = $('<fieldset class="contact_numbers"></fieldset>')
    var fieldsetContents = function(id) {
      id_prefix = 'organisation_contacts_attributes_0_contact_numbers_attributes_' + id
      name_prefix = 'organisation[contacts_attributes][0][contact_numbers_attributes][' + id + ']'

      return '<fieldset class="contact_number">' +
             '<label for="' + id_prefix + '_label">Label</label>' +
             '<input id="' + id_prefix + '_label" name="' + name_prefix + '[label]" size="30" type="text" value="Enquiries" />' +
             '<label for="' + id_prefix + '_number">Address </label>' +
             '<input id="' + id_prefix + '_number" name="' + name_prefix + '[number]" size="30" type="text" value="12345678" />' +
             '</fieldset>';
    }

    this.contactNumbersFieldset.append(fieldsetContents(0));
    this.contactNumbersFieldset.append(fieldsetContents(1));
    this.contactFieldset.append(this.contactNumbersFieldset);
    this.fieldset.append(this.contactFieldset);

    $('#qunit-fixture').append(this.form);
    this.fieldset.setupContactsForm();
  }
});

test("adds remove links to contact", function() {
  equal(this.contactNumbersFieldset.find('a.remove').length, 2)
})

test("remove hides and blanks number when other numbers are visible", function() {
  target = $('.contact_number').first()
  target.find('a.remove').click();
  equal(target.is(':visible'), false)
  equal(target.find('input').filter(function() { return this.value != ''; }).length, 0)
})

test("remove only blanks number when it's the last visible", function() {
  $('.contact_number').first().find('a.remove').click();
  target = $('.contact_number').last()
  target.find('a.remove').click();
  equal(target.is(':visible'), true)
  equal(target.find('input').filter(function() { return this.value != ''; }).length, 0)
})
