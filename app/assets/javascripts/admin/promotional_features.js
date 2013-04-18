(function ($) {

  var _setupPromotionalFeatureLinksForm = function() {

    var changeIndex = function(el, name, attr, id, newId) {
      switch(attr) {
        case "name":
          $(el).attr(attr, $(el).attr(attr).replace(name + "]["+id+"]", name + "]["+newId+"]"));
        default:
          $(el).attr(attr, $(el).attr(attr).replace(name + "_"+id+"_", name + "_"+newId+"_"));
      }
    };

    var makeNewFeatureLinkFields = function(featureLinksFieldset) {
      var nextId = featureLinksFieldset.find('.feature_link').size();
      var newLinkFields = featureLinksFieldset.find('.feature_link').first().clone();
      newLinkFields.find('input').val('');
      newLinkFields.find("label").each(function(i, el) {
        changeIndex(el, "links_attributes", "for", 0, nextId);
      });
      newLinkFields.find("input").each(function(i, el) {
        changeIndex(el, "links_attributes", "id", 0, nextId);
        changeIndex(el, "links_attributes", "name", 0, nextId);
      });
      newLinkFields.find('a').click(handleRemoveLink);
      newLinkFields.show();
      return newLinkFields;
    }

    var hideOrShowAddLink = function() {
      var addLink = $('.add_new');

      if( $('.feature_link:visible').length === 6) {
        addLink.hide();
      } else {
        addLink.show();
      }
    }

    var insertAddLink = function() {
      var featureLinksFieldset = $(this);
      var link = $.a('Add link', {'class': 'btn add_new'});
      link.click(function() {
        var newLinkFields = makeNewFeatureLinkFields(featureLinksFieldset);
        featureLinksFieldset.find('.feature_link').last().after(newLinkFields);
        hideOrShowAddLink();
        return false;
      })
      $(this).append(link);
    };

    var handleRemoveLink = function() {
      var linkField = $(this).parent();
      var linkFieldset = linkField.parent();
      // hide the fields
      linkField.hide();
      // blank input values
      linkField.find('input').val('');
      // set _destroy attribute
      var ids = linkFieldset.find('.feature_link').map(function(i,field) {
        return $(field).find('input')[0].id;
      });
      var id = $.inArray($(linkField).find('input')[0].id, ids);
      var destroy_input = $('<input id="promotional_feature_item_links_attributes_'+id+'__destroy" name="promotional_feature_item[links_attributes]['+id+'][_destroy]" type="hidden" value="1" />');
      linkField.append(destroy_input);
      hideOrShowAddLink();
    }

    var insertRemoveLink = function() {
      link = $(this);
      var removeLink = $.a('remove', {'class': 'btn btn-danger remove'});
      link.append(removeLink);
      removeLink.click(handleRemoveLink);
    }

    $('.feature_links').each(insertAddLink);
    $('.feature_links').each(hideOrShowAddLink);
    $('.feature_links .feature_link').each(insertRemoveLink);
  }

  $.fn.extend({
    setupPromotionalFeatureLinksForm: _setupPromotionalFeatureLinksForm
  });
})(jQuery);

jQuery(function($) {
  $("form .promotional_feature_item .feature_links").setupPromotionalFeatureLinksForm();
})
