require "test_helper"

class StandardEditionMigratorJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "sidekiq_options" do
    it "runs in the standard_edition_migration queue and set to never retry" do
      assert_equal({ "retry" => 0, "queue" => "standard_edition_migration" }, StandardEditionMigratorJob.sidekiq_options)
    end
  end
end
