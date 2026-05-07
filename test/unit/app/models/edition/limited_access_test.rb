require "test_helper"

class Edition::LimitedAccessTest < ActiveSupport::TestCase
  class LimitedAccessEdition < Edition
    include Edition::LimitedAccess
    include Edition::Organisations
  end

  class LimitedByDefaultEdition < LimitedAccessEdition
    def self.access_limited_by_default?
      true
    end
  end

  FactoryBot.define do
    factory :limited_access_edition, class: LimitedAccessEdition, parent: :edition_with_organisations do
    end
    factory :limited_by_default_edition, class: LimitedByDefaultEdition, parent: :limited_access_edition do
    end
  end

  test "sets access_limit on new instances according to class.access_limited_by_default?" do
    assert_not build(:limited_access_edition).access_limited?
    assert build(:limited_by_default_edition).access_limited?
  end

  test "can persist limited access flag (regardless of <class>.access_limited_by_default?)" do
    e = build(:limited_by_default_edition)
    e.access_limited = :organisations
    e.save!
    assert e.reload.access_limited?
    e.access_limited = :disabled
    e.save!
    assert_not e.reload.access_limited?
  end

  test "#access_limited_object returns self" do
    edition = LimitedAccessEdition.new

    assert_equal edition, edition.access_limited_object
  end

  test "is not accessible if no user specified" do
    edition = LimitedAccessEdition.new

    assert_not edition.accessible_to?(nil)
  end

  test "is not accessible if edition is not accessible to user" do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id, access_limited: :organisations)

    assert_not edition.accessible_to?(user)
  end

  test "is accessible if edition is accessible to user" do
    user = build(:user)
    edition_id = 123
    edition = LimitedAccessEdition.new(id: edition_id)

    assert edition.accessible_to?(user)
  end

  test "access_limited_named_users= stores named emails in named_accesses after save" do
    edition = create(:limited_access_edition)
    edition.access_limited = :named_users
    edition.access_limited_named_users = "named@example.com"
    edition.save!

    assert_includes edition.named_accesses.pluck(:email), "named@example.com"
  end

  test "access_limited_named_users= parses multiple emails separated by newlines" do
    edition = create(:limited_access_edition)
    edition.access_limited = :named_users
    edition.access_limited_named_users = "a@example.com\nb@example.com"
    edition.save!

    emails = edition.named_accesses.pluck(:email)
    assert_includes emails, "a@example.com"
    assert_includes emails, "b@example.com"
  end

  test "access_limited_named_users= always preserves creator email" do
    creator = create(:user)
    edition = create(:limited_access_edition, creator:)
    edition.access_limited = :named_users
    edition.access_limited_named_users = "other@example.com"
    edition.save!

    emails = edition.named_accesses.pluck(:email)
    assert_includes emails, creator.email.downcase
  end

  test "access_limited_named_users= removes emails no longer in the list" do
    edition = create(:limited_access_edition)
    edition.update_column(:access_limited, Edition.access_limiteds[:named_users])
    edition.reload
    edition.named_accesses.create!(email: "old@example.com")
    edition.named_accesses.create!(email: "keep@example.com")

    edition.access_limited_named_users = "keep@example.com"
    edition.save!

    assert_includes edition.named_accesses.pluck(:email), "keep@example.com"
    assert_not_includes edition.named_accesses.pluck(:email), "old@example.com"
  end

  test "switching from named_users to disabled clears named_accesses" do
    edition = create(:limited_access_edition)
    edition.update_column(:access_limited, Edition.access_limiteds[:named_users])
    edition.reload
    edition.named_accesses.create!(email: "user@example.com")

    edition.access_limited = :disabled
    edition.access_limited_named_users = ""
    edition.save!

    assert edition.named_accesses.reload.empty?
  end

  test "validates at least one email when named_users setter is called with empty value" do
    edition = build(:limited_access_edition, access_limited: :named_users)
    edition.access_limited_named_users = ""

    assert_not edition.valid?
    assert_includes edition.errors[:access_limited_named_users], "must include at least one email address"
  end

  test "access_limited_named_users reader returns existing emails joined by comma" do
    edition = create(:limited_access_edition)
    edition.update_column(:access_limited, Edition.access_limiteds[:named_users])
    edition.reload
    edition.named_accesses.create!(email: "a@example.com")
    edition.named_accesses.create!(email: "b@example.com")

    assert_equal "a@example.com, b@example.com", edition.access_limited_named_users
  end

  test "create_draft copies named_accesses to new draft" do
    edition = create(:limited_access_edition)
    edition.update_columns(access_limited: Edition.access_limiteds[:named_users], state: "published")
    edition.reload
    edition.named_accesses.create!(email: "user@example.com")

    draft = edition.create_draft(create(:user))

    assert_includes draft.named_accesses.pluck(:email), "user@example.com"
  end
end
