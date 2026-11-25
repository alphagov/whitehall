require "test_helper"

class StripsWhitespaceTest < ActiveSupport::TestCase
  test "strips leading and trailing whitespace from string attributes on validation" do
    policy_group = build(:policy_group, name: "  Policy group  ", summary: "\tA summary\n")

    policy_group.valid?

    assert_equal "Policy group", policy_group.name
    assert_equal "A summary", policy_group.summary
  end

  test "strips leading and trailing whitespace from text attributes" do
    policy_group = build(:policy_group, description: "\n  Some description  \n")

    policy_group.valid?

    assert_equal "Some description", policy_group.description
  end

  test "strips non-breaking and other unicode whitespace" do
    policy_group = build(:policy_group, name: " Policy group  ")

    policy_group.valid?

    assert_equal "Policy group", policy_group.name
  end

  test "preserves whitespace within a value" do
    policy_group = build(:policy_group, description: " Line one\n\nLine  two ")

    policy_group.valid?

    assert_equal "Line one\n\nLine  two", policy_group.description
  end

  test "leaves nil attributes as nil" do
    policy_group = build(:policy_group, email: nil)

    policy_group.valid?

    assert_nil policy_group.email
  end

  test "strips attributes translated with Globalize" do
    role = build(:role, name: "  Minister of State ", responsibilities: " Some responsibilities\n")

    role.valid?

    assert_equal "Minister of State", role.name
    assert_equal "Some responsibilities", role.responsibilities
  end

  test "persists the stripped value of translated attributes" do
    role = create(:role, name: "  Minister of State ")

    assert_equal "Minister of State", Role.find(role.id).name
  end

  test "strips translated attributes of non-primary locales" do
    role = create(:role, name: "Minister")

    I18n.with_locale(:cy) { role.update!(name: " Gweinidog ") }

    assert_equal "Gweinidog", I18n.with_locale(:cy) { Role.find(role.id).name }
  end

  test "strips edition titles, summaries and bodies" do
    edition = build(:publication, title: " A title ", summary: " A summary ", body: "\n A body \n")

    edition.valid?

    assert_equal "A title", edition.title
    assert_equal "A summary", edition.summary
    assert_equal "A body", edition.body
  end

  test "does not rewrite unchanged legacy values when saving other attributes" do
    policy_group = create(:policy_group)
    policy_group.update_column(:name, "Legacy name ")
    policy_group.reload

    policy_group.update!(email: "new@example.com")

    assert_equal "Legacy name ", policy_group.reload.name
  end

  test "strips a legacy value once it is edited" do
    policy_group = create(:policy_group)
    policy_group.update_column(:name, "Legacy name ")
    policy_group.reload

    policy_group.update!(name: " Edited name ")

    assert_equal "Edited name", policy_group.reload.name
  end
end
