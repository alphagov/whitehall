(function ($) {
  var _setupContactsForm = function() {
    var self = $(this);
    var emptyFieldSet = self.children(".empty_fields");

    var updateId = function(el, name, attr, id, newId) {
      switch(attr) {
        case "name":
          $(el).attr(attr, $(el).attr(attr).replace(name + "]["+id+"]", name + "]["+newId+"]"));
        default:
          $(el).attr(attr, $(el).attr(attr).replace(name + "_"+id+"_", name + "_"+newId+"_"));
      }
    };

    var updateIdsOnEmptyFields = function() {
      var fieldset = emptyFieldSet.children("fieldset");
      var referenceInput = fieldset.children("input:first")[0];
      var id = parseInt($(referenceInput).attr("id").match(/_(\d)_/)[1]);
      var newId = id + 1;
      fieldset.children("label").each(function(i, el) {
        updateId(el, "contacts_attributes", "for", id, newId);
      });
      fieldset.children("input,textarea").each(function(i, el) {
        updateId(el, "contacts_attributes", "id", id, newId);
        updateId(el, "contacts_attributes", "name", id, newId);
      });
    };

    var addNewContact = function() {
      var clone = emptyFieldSet.children("fieldset").clone();
      self.append(clone);
      updateIdsOnEmptyFields();
    };

    var addLinkToCloneEmptyFields = function() {
      var link = $.a('Add new contact', {'class': 'button add_new'});
      link.click(function () {
        addNewContact(); return false;
      })
      self.after(link);
    };

    var handleRemoveNumber = function() {
      if ($(this).parent().parent().find('.contact_number').filter(':visible').size() > 1) {
        $(this).parent().hide();
      }
      $(this).parent().find('input').val('');
    }

    var addLinkToAddNewNumber = function() {
      legend = $(this)
      var link = $.a('Add number', {'class': 'button add_new'});
      link.click(function() {
        fieldset = $(this).parent().parent();
        newId = fieldset.find('.contact_number').size();
        var clone = fieldset.find('fieldset.contact_number').filter(':visible').first().clone();
        $(clone).find('input').val('')
        $(clone).children("label").each(function(i, el) {
          updateId(el, "contact_numbers_attributes", "for", 0, newId);
        });
        $(clone).children("input").each(function(i, el) {
          updateId(el, "contact_numbers_attributes", "id", 0, newId);
          updateId(el, "contact_numbers_attributes", "name", 0, newId);
        });
        fieldset.append(clone);
        $(clone).find('a').click(handleRemoveNumber);
        return false;
      })
      legend.append(link);
    };

    var addRemoveNumberLink = function() {
      number = $(this);
      var link = $.a('remove', {'class': 'button remove'});
      number.append(link);
      link.click(handleRemoveNumber);
    }

    addLinkToCloneEmptyFields();
    $('.contact_numbers legend').each(addLinkToAddNewNumber);
    $('.contact_numbers .contact_number').each(addRemoveNumberLink);
    emptyFieldSet.hide();
  }

  $.fn.extend({
    setupContactsForm: _setupContactsForm
  });
})(jQuery);

jQuery(function($) {
  $("form.organisation_edit .contacts").setupContactsForm();
})