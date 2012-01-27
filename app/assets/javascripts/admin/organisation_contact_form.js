(function ($) {
  var _setupContactsForm = function() {
    var self = $(this);
    var emptyFieldSet = self.children(".empty_fields");

    var updateId = function(el, attr, id, newId) {
      switch(attr) {
        case "name":
          $(el).attr(attr, $(el).attr(attr).replace("["+id+"]", "["+newId+"]"));
        default:
          $(el).attr(attr, $(el).attr(attr).replace("_"+id+"_", "_"+newId+"_"));
      }
    };

    var updateIdsOnEmptyFields = function() {
      var fieldset = emptyFieldSet.children("fieldset");
      var referenceInput = fieldset.children("input:first")[0];
      var id = parseInt($(referenceInput).attr("id").match(/_(\d)_/)[1]);
      var newId = id + 1;
      fieldset.children("label").each(function(i, el) {
        updateId(el, "for", id, newId);
      });
      fieldset.children("input").each(function(i, el) {
        updateId(el, "id", id, newId);
        updateId(el, "name", id, newId);
      });
      fieldset.children("textarea").each(function(i, el) {
        updateId(el, "id", id, newId);
        updateId(el, "name", id, newId);
      });
    };

    var addNewContact = function() {
      var clone = emptyFieldSet.children("fieldset").clone();
      hideEmptyInputs(clone);
      self.append(clone);
      updateIdsOnEmptyFields();
    };

    var addLinkToCloneEmptyFields = function() {
      var link = $.a('Add new contact', {class: 'button add_new'}).click(function () {
        addNewContact(); return false;
      })
      self.after(link);
    };

    var addRevealLink = function(label) {
      var revealLinks = $(label).parent().find(".reveal_links");
      if (revealLinks.length == 0) {
        revealLinks = $.ul($.li('Add:', '.add'), '.reveal_links');
        $(label).parent().append(revealLinks);
      }
      var link = $.a($.trim($(label).text()));
      link.click(function() {
        $(label).show();
        $("#" + $(label).attr("for")).show();
        link.hide();
        if (revealLinks.find('a:visible').length == 0) {
          revealLinks.hide();
        }
        return false;
      })
      revealLinks.append($.li(link));
    };

    var hideEmptyInputs = function(fieldset) {
      $.each(fieldset.find("label"), function(i, label) {
        if ($(label).text() == "Description") return;
        var input = fieldset.find("#" + $(label).attr("for"));
        if (input.val() == "") {
          input.hide();
          $(label).hide();
          addRevealLink(label);
        }
      });
    };

    addLinkToCloneEmptyFields();
    emptyFieldSet.hide();
    $.each(self.children(".contact:visible"), function(i, fieldset) {
      hideEmptyInputs($(fieldset));
    });
  }

  $.fn.extend({
    setupContactsForm: _setupContactsForm
  });
})(jQuery);

jQuery(function($) {
  $("form.organisation_edit .contacts").setupContactsForm();
})