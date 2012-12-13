$(function() {
  function copeWithSelectedLeadOrganisations(selected_lead_organisations){
    var this_option = $(this);
    if ($.inArray(this_option.val(), selected_lead_organisations) < 0) {
      this_option.removeAttr('disabled');
    } else {
      this_option.attr('disabled','disabled');
      this_option.removeAttr('selected');
    }
  }
  function copeWithNoLeadOrganisations(){
    $(this).removeAttr('disabled');
  }
  function copeWithLeadOrganisationChange(lead_organisations, other_organisations) {
    var selected = lead_organisations.val();
    if (selected !== null) {
      console.log('selected:'+selected);
      other_organisations.find('option').each(function() {
        copeWithSelectedLeadOrganisations.call(this, selected)
      });
    } else {
      console.log('nothing selected');
      other_organisations.find('option').each(copeWithNoLeadOrganisations);
    }
    other_organisations.trigger('liszt:updated');
  }

  function initOrganisationSelectors() {
    var lead_organisations = $(this).find('[data-organisation-selector=lead]'),
        other_organisations = $(this).find('[data-organisation-selector=other]');

    lead_organisations.change(function() {
      copeWithLeadOrganisationChange(lead_organisations, other_organisations);
    });

    copeWithLeadOrganisationChange(lead_organisations, other_organisations);
  }
  $("[data-widget='organisation-selectors']").each(initOrganisationSelectors);
});
