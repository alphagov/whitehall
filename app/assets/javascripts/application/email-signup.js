(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var emailSignup = {
    duplicate: function(e){
      e.preventDefault();

      var $fieldset = emailSignup.$form.find('fieldset:eq(0)').clone();
      $fieldset.find('select').val('');
      $fieldset.find('input[type="checkbox"]').attr('checked', false);
      $fieldset.insertAfter(emailSignup.$form.find('fieldset:last'));
    },
    init: function(){
      emailSignup.$form = $('.js-email-signup');
      if(emailSignup.$form.length > 0){
        emailSignup.$form.find('.js-duplicate').click(emailSignup.duplicate);
      }
    }
  }

  root.GOVUK.emailSignup = emailSignup;
}).call(this);
