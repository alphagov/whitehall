require 'test_helper'

class HistoricalAccountTest < ActiveSupport::TestCase

  test "is invalid without a summary, body, political party or person" do
    %w(summary body person political_party).each do |attribute|
      refute build(:historical_account, attribute => nil).valid?
    end
  end

  test "is not valid without at least one role" do
    historical_account = build(:historical_account)
    historical_account.roles = []
    refute historical_account.valid?
    historical_account.roles << create(:role)
    assert historical_account.valid?
  end

  test "has accessor for political party" do
    historical_account = HistoricalAccount.new
    assert_nil historical_account.political_party
    historical_account.political_party = PoliticalParty::Whigs
    assert_equal PoliticalParty::Whigs, historical_account.political_party
  end

  test "returns political membership" do
    assert_nil HistoricalAccount.new.political_membership
    historical_account = build(:historical_account, political_party: PoliticalParty::Whigs)
    assert_equal 'Whig', historical_account.political_membership
  end

  test "#role defaults to the first role when there are multiple" do
    role1 = create(:role)
    role2 = create(:role)
    historical_account = create(:historical_account, roles: [role1, role2])

    assert_equal role1, historical_account.role
  end
end
