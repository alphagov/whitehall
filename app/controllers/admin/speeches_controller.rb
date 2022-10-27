class Admin::SpeechesController < Admin::EditionsController
  before_action :clear_role_appointment_param_on_override, only: %i[update create]

private

  def edition_class
    Speech
  end

  def clear_role_appointment_param_on_override
    design_system = preview_design_system?(next_release: false)

    if design_system && params[:speaker_radios] == "yes"
      edition_params[:person_override] = nil
    elsif design_system && params[:speaker_radios] == "no"
      edition_params[:role_appointment_id] = nil
    elsif params[:person_override_active] == "1" || edition_params[:person_override].present?
      edition_params[:role_appointment_id] = nil
    end
  end
end
