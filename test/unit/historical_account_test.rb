require_relative '../test_helper'

class HistoricalAccountTest < ActiveSupport::TestCase

  test "is invalid without a summary, body, political party or person" do
    %w(summary body person political_parties).each do |attribute|
      refute build(:historical_account, attribute => nil).valid?
    end
  end

  test "is not valid without at least one role" do
    historical_account = build(:historical_account)
    historical_account.roles = []
    refute historical_account.valid?
    historical_account.roles << create(:historic_role)
    assert historical_account.valid?
  end

  test "is not valid unless its role supports historic accounts" do
    historical_account = build(:historical_account, roles: [create(:historic_role)])
    assert historical_account.valid?

    historical_account = build(:historical_account, roles: [create(:role)])
    refute historical_account.valid?
    assert_equal ['The selected role(s) do not all support historical accounts'], historical_account.errors[:base]
  end

  test "has accessor for political parties" do
    historical_account = HistoricalAccount.new
    assert_equal [], historical_account.political_parties
    historical_account.political_parties = [PoliticalParty::Whigs]
    assert_equal [PoliticalParty::Whigs], historical_account.political_parties
    historical_account.political_party_ids = [PoliticalParty::Tories.id]
    assert_equal [PoliticalParty::Tories], historical_account.political_parties
  end

  test "#political_parties reader does not mind when ids are strings" do
    historical_account = HistoricalAccount.new(political_party_ids: %w(1 2))
    assert_equal [PoliticalParty::Conservative, PoliticalParty::Labour], historical_account.political_parties
  end

  test "strips blank political party ids" do
    historical_account = HistoricalAccount.new
    historical_account.political_party_ids = ['', PoliticalParty::Whigs.id]
    assert_equal [PoliticalParty::Whigs], historical_account.political_parties
  end

  test "fails validation on invalid (non-blank) political party" do
    historical_account = build(:historical_account, roles: [create(:historic_role)])

    historical_account.political_party_ids = [PoliticalParty::Conservative.id]
    assert historical_account.valid?

    historical_account.political_party_ids = [9999]
    refute historical_account.valid?, "HistoricalAccount should not be valid with a non-existant political party"
  end

  test "returns political membership" do
    assert_equal '', HistoricalAccount.new.political_membership
    historical_account = build(:historical_account, political_parties: [PoliticalParty::Whigs])
    assert_equal 'Whig', historical_account.political_membership
  end

  test "returns multiple political memberships" do
    historical_account = build(:historical_account, political_parties: [PoliticalParty::Whigs, PoliticalParty::Tories])
    assert_equal 'Whig and Tory', historical_account.political_membership
  end

  test "#role defaults to the first role when there are multiple" do
    role1 = create(:historic_role)
    role2 = create(:historic_role)
    historical_account = create(:historical_account, roles: [role1, role2])

    assert_equal role1, historical_account.role
  end

  should_not_accept_footnotes_in(:body)
end
