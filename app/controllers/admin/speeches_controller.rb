class Admin::SpeechesController < Admin::EditionsController
  before_action :clear_role_appointment_param_on_override, only: [:update, :create]

  private

  def edition_class
    Speech
  end

  def clear_role_appointment_param_on_override
    if (params[:person_override_active] == "1" || params[:edition][:person_override].present?)
      params[:edition][:role_appointment_id] = nil
      true
    end
  end
end
