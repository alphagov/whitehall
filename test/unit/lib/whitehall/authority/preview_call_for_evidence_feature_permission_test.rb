require_relative "authority_test_helper"
require "test_helper"
class PreviewCallForEvidenceTest < ActiveSupport::TestCase
  include AuthorityTestHelper
  extend Minitest::Spec::DSL

  let(:non_preview_user) { create(:gds_admin) }
  let(:preview_call_for_evidence_user) { create(:gds_admin, :with_preview_call_for_evidence) }
  let(:call_for_evidence_instance) { create(:call_for_evidence) }

  context "users with no preview permission" do
    it { assert_not enforcer_for(non_preview_user, CallForEvidence).can?(:see) }
    it { assert_not enforcer_for(non_preview_user, call_for_evidence_instance).can?(:see) }
    it { assert_not enforcer_for(non_preview_user, CallForEvidence).can?(:create) }
    it { assert_not enforcer_for(non_preview_user, call_for_evidence_instance).can?(:create) }
    it { assert_not enforcer_for(non_preview_user, call_for_evidence_instance).can?(:update) }
    it { assert_not enforcer_for(non_preview_user, call_for_evidence_instance).can?(:delete) }
    it { assert_not enforcer_for(non_preview_user, CallForEvidence).can?(:export) }
  end

  context "users with preview permission" do
    it { assert enforcer_for(preview_call_for_evidence_user, CallForEvidence).can?(:see) }
    it { assert enforcer_for(preview_call_for_evidence_user, call_for_evidence_instance).can?(:see) }
    it { assert enforcer_for(preview_call_for_evidence_user, CallForEvidence).can?(:create) }
    it { assert enforcer_for(preview_call_for_evidence_user, call_for_evidence_instance).can?(:create) }
    it { assert enforcer_for(preview_call_for_evidence_user, call_for_evidence_instance).can?(:update) }
    it { assert enforcer_for(preview_call_for_evidence_user, call_for_evidence_instance).can?(:delete) }
    it { assert enforcer_for(preview_call_for_evidence_user, CallForEvidence).can?(:export) }
  end
end
