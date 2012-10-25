require "test_helper"

class Edition::LimitedAccessTest < ActiveSupport::TestCase

  class LimitedAccessEdition < Edition
    include Edition::LimitedAccess
  end

  FactoryGirl.define do
    factory :limited_access_edition, class: LimitedAccessEdition, parent: :edition do
    end
  end

  test "can limit access" do
    assert build(:limited_access_edition).can_limit_access?
  end

  test "can persist limited access flag" do
    e = build(:limited_access_edition)
    e.access_limited = true
    e.save!
    assert e.reload.access_limited?
    e.access_limited = false
    e.save!
    refute e.reload.access_limited?
  end

  test "when access is not limited, edition is accessible by anyone" do
    org1, org2 = build(:organisation), build(:organisation)
    e = build(:limited_access_edition, organisations: [org1], access_limited: false)

    user1 = build(:user, organisation: org1)
    user2 = build(:user, organisation: org2)

    assert e.accessible_by?(user1)
    assert e.accessible_by?(user2)
    assert e.accessible_by?(nil)
  end

  test "when access is limited, edition is accessible only by a person in the one of the edition's departments" do
    org1, org2 = build(:organisation), build(:organisation)
    e = build(:limited_access_edition, organisations: [org1], access_limited: true)

    user1 = build(:user, organisation: org1)
    user2 = build(:user, organisation: org2)

    assert e.accessible_by?(user1)
    refute e.accessible_by?(user2)
  end
end