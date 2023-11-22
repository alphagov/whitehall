class Admin::SpeechesController < Admin::EditionsController
private

  def edition_class
    Speech
  end

  def clean_edition_parameters
    super
    edition_params[:person_override] = nil if speaker_has_govuk_profile?
    edition_params[:role_appointment_id] = nil if speaker_has_no_govuk_profile?
    edition_params.delete(:speaker_radios)
  end

  def speaker_has_govuk_profile?
    edition_params[:speaker_radios] == "yes"
  end

  def speaker_has_no_govuk_profile?
    edition_params[:speaker_radios] == "no"
  end
end
