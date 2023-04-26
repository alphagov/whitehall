class Admin::SpeechesController < Admin::EditionsController
private

  def edition_class
    Speech
  end

  def clean_edition_parameters
    super
    design_system = preview_design_system?(next_release: false)

    if design_system && edition_params[:speaker_radios] == "yes"
      edition_params[:person_override] = nil
    elsif design_system && edition_params[:speaker_radios] == "no"
      edition_params[:role_appointment_id] = nil
    elsif params[:person_override_active] == "1" || edition_params[:person_override].present?
      edition_params[:role_appointment_id] = nil
    end

    edition_params.delete(:speaker_radios)
  end
end
