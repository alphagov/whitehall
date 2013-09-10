/*jslint
 white: true,
 vars: true,
 indent: 2
*/
(function () {
  "use strict";
  var root = this,
      $ = root.jQuery,
      GOVUK = root.GOVUK || {};

  GOVUK.hideClosedAtDates = function() {
    var $closedAtGroup = $('#js-organisation-closed-at-group'),
        $closedAtLabel = $closedAtGroup.prev('label[for=organisation_closed_at]'),
        $govUkStatus = $('#organisation_govuk_status');

    function toggleShown(status) {
      if (status === 'closed') {
        $closedAtLabel.show();
        $closedAtGroup.show();
        $closedAtGroup.find('select').each(function(el) {
          // some older browsers are weird, so explicitly use the expando
          el.disabled = false;
          $(el).removeAttr('disabled');
        });
      }
      else {
        $closedAtLabel.hide();
        $closedAtGroup.hide();
        $closedAtGroup.find('select').each(function(el) {
          // some older browsers are weird, so explicitly use the expando
          el.disabled = true;
          $(el).attr('disabled', true);
        });
      }
    }

    if ($closedAtGroup && $closedAtLabel) {
      toggleShown($govUkStatus.val());
      $govUkStatus.on('change', function(e) {
        toggleShown($(this).val());
      });
    }
  };

  GOVUK.toggleCustomLogoField = function() {
    var $logo_selector = $('#organisation_organisation_logo_type_id');
    var value_for_custom_logo = 14;
    $logo_selector.chosen().change(function(event) {
      if ($(this).val() == value_for_custom_logo) {
        $('.organisation-custom-logo').slideDown();
      }
      else {
        $('.organisation-custom-logo').slideUp();
      }
    });
  };

}).call(this);
