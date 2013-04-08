module("Add and removing feature links", {
  setup: function() {
    this.form = $('<form class="promotional_feature_item"></form>');
    this.linksFieldset = $('<fieldset class="feature_links"></fieldset>');
    this.form.append(this.linksFieldset);

    var featureLinkFields = function(id) {
      return '<div class="feature_link">' +
             '<label for="promotional_feature_item_links_attributes_'+id+'_url">Url</label>' +
             '<input id="promotional_feature_item_links_attributes_'+id+'_url" name="promotional_feature_item[links_attributes]['+id+'][url]" size="30" type="text" value="http://link.com" />' +
             '<label for="promotional_feature_item_links_attributes_'+id+'_text">Text </label>' +
             '<input id="promotional_feature_item_links_attributes_'+id+'_text" name="promotional_feature_item[links_attributes]['+id+'][text]" size="30" type="text" value="Link text" />' +
             '</div>';
    }

    this.linksFieldset.append(featureLinkFields(0));
    this.linksFieldset.append(featureLinkFields(1));
    $('#qunit-fixture').append(this.form);

    this.linksFieldset.setupPromotionalFeatureLinksForm();
  }
});

test("adds an 'Add link' to the fieldset", function() {
  equal(this.linksFieldset.children("a.add_new:visible").length, 1);
});


test("removes the 'Add link' once there are six links", function() {
  equal(this.linksFieldset.children("a.add_new:visible").length, 1);
  equal(this.linksFieldset.children(".feature_link").length, 2);
  this.linksFieldset.find('a.add_new').click();
  equal(this.linksFieldset.children("a.add_new").length, 1);
  this.linksFieldset.find('a.add_new').click();
  equal(this.linksFieldset.children("a.add_new").length, 1);
  this.linksFieldset.find('a.add_new').click();
  equal(this.linksFieldset.children("a.add_new").length, 1);
  this.linksFieldset.find('a.add_new').click();
  equal(this.linksFieldset.children(".feature_link").length, 6);

  equal(this.linksFieldset.children("a.add_new:visible").length, 0);
});


test("clicking 'Add link' adds fields for a new link", function() {
  fieldset = $('.feature_links');
  fieldset.find('a.add_new').click();
  equal(fieldset.find('div.feature_link:visible').length, 3);

  var new_url_label = fieldset.find("label:contains('Url'):last");
  equal(new_url_label.attr('for'), "promotional_feature_item_links_attributes_2_url");
  var new_url_input = fieldset.find("input#promotional_feature_item_links_attributes_2_url")[0];
  equal(new_url_input.name, "promotional_feature_item[links_attributes][2][url]");

  var new_text_label = fieldset.find("label:contains('Text'):last");
  equal(new_text_label.attr('for'), "promotional_feature_item_links_attributes_2_text");
  var new_text_input = fieldset.find("input#promotional_feature_item_links_attributes_2_text")[0];
  equal(new_text_input.name, "promotional_feature_item[links_attributes][2][text]");
})

test("adds a 'Remove' links to each feature links", function() {
  var featureLinks = $('.feature_link');

  $.each(featureLinks, function(i, link){
    equal($(link).find('a.remove').length, 1);
  });
})

test("'Remove' hides the links fields and sets the _destroy field", function() {
  var target = $('.feature_link').first()
  target.find('a.remove').click();
  equal(target.is(':visible'), false);
  equal($(target.find('input#promotional_feature_item_links_attributes_0_url')).val(),'');
  equal($(target.find('input#promotional_feature_item_links_attributes_0_text')).val(),'');
  equal(target.find('input#promotional_feature_item_links_attributes_0__destroy').length, 1)
  equal($(target.find('input#promotional_feature_item_links_attributes_0__destroy')[0]).val(), '1')
})
