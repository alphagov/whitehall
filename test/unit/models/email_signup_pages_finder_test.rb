require "test_helper"

class EmailSignupPagesFinderTest < ActiveSupport::TestCase
  test 'EmailSignupPagesFinder.find returns a data structure representing the email signup pages for the MHRA' do
    signup_page = EmailSignupPagesFinder.find(mhra)

    assert_equal signup_page.map { |p| p[:text] },
      [
        'Drug alerts and medical device alerts',
        'Drug Safety Update',
        'News and publications from the MHRA',
      ]
  end

  test 'EmailSignupPagesFinder.find returns nil for a non-matching organisations' do
    another_org = create(:organisation, name: 'Org without custom signup page')
    refute EmailSignupPagesFinder.find(another_org)
  end

  test 'EmailSignupPagesFinder.exists_for_atom_feed? returns true for the MHRA atom feed' do
    mhra_atom_feed = Whitehall.atom_feed_maker.organisation_url(mhra)

    assert EmailSignupPagesFinder.exists_for_atom_feed?(mhra_atom_feed)
  end

  test 'EmailSignupPagesFinder.exists_for_atom_feed? returns false for other atom feeds' do
    non_matching_atom_feed = Whitehall.atom_feed_maker.organisation_url(create(:organisation))
    refute EmailSignupPagesFinder.exists_for_atom_feed?(non_matching_atom_feed)
  end

private

  def mhra
    @mhra ||= create(:organisation, name: 'Medicines and Healthcare Products Regulatory Agency')
  end
end
