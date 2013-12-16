require 'test_helper'

class ConsultationOutcomeTest < ActiveSupport::TestCase
  should_not_accept_footnotes_in :summary
end
