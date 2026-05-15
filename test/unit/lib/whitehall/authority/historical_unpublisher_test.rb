require_relative "authority_test_helper"

class HistoricalUnpublisherTest < ActiveSupport::TestCase
  include AuthorityTestHelper

  setup do
    @user = create(:historical_unpublisher)
  end

  test "can see an historical document" do
    assert enforcer_for(@user, historic_edition).can?(:see)
  end

  test "can unpublish an historical document" do
    assert enforcer_for(@user, historic_edition).can?(:unpublish)
  end

  test "can't perform any other action on an historical document" do
    denied_actions = Whitehall::Authority::Rules::EditionRules.actions - %i[see unpublish]
    denied_actions.each do |action|
      assert_not enforcer_for(@user, historic_edition).can?(action)
    end
  end
end
