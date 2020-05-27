# Zendesk ticket https://govuk.zendesk.com/agent/tickets/3816861
# Need to unlink the speech from the role appointment and link
# to the minister's new role
# Because the speech is superseded and would raise the validation
# "cannot be modified when edition is in the superseded state"
# it must be saved without running the validations but should
# not result in the record being invalid afterwards

speech = Speech.find(995_407)
speech.role_appointment_id = 5815
speech.save!(validate: false)
