require 'test_helper'

class ConsultationPublicFeedbackTest < ActiveSupport::TestCase
  should_not_accept_footnotes_in :summary
end
