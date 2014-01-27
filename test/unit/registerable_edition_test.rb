require 'test_helper'

class RegisterableEditionTest < ActiveSupport::TestCase

  test "prepares an edition for registration with Panopticon" do
    edition = create(:published_edition)
    registerable_edition = RegisterableEdition.new(edition)

    assert_equal edition.slug, registerable_edition.slug
    assert_equal edition.title, registerable_edition.title
    assert_equal edition.type.underscore, registerable_edition.kind
    assert_equal edition.summary, registerable_edition.description
    assert_equal "live", registerable_edition.state
  end

end
