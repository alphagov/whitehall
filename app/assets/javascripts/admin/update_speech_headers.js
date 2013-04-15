(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var updateSpeechHeaders = function(allLabels) {
    var chosenType = $('select#edition_speech_type_id').val();
    var labels = allLabels[chosenType];

    $('label[for=edition_role_appointment_id]').text(labels.ownerGroup.speaker);
    $('label[for=edition_delivered_on]').text(labels.publishedExternallyLabel);

    if (labels.locationRelevant) {
      $('label[for=edition_location]').show();
      $('#edition_location').show();
    } else {
      $('label[for=edition_location]').hide();
      $('#edition_location').hide();
    }
  };

  root.GOVUK.updateSpeechHeaders = updateSpeechHeaders;
}).call(this);
