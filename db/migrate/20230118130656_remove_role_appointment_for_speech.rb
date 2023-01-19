# Zendesk ticket https://govuk.zendesk.com/agent/tickets/5182511
# Need to unlink the speech from the role appointment.
# This speech in published state is already linked to person's new role.
# Because the speech is superseded and would raise the validation
# "cannot be modified when edition is in the superseded state"
# it must be saved without running the validations.

class RemoveRoleAppointmentForSpeech < ActiveRecord::Migration[7.0]
  def change
    speech = Speech.find_by(id: 1_216_085)
    if speech
      speech.role_appointment_id = nil
      speech.save!(validate: false)
    end
  end
end
