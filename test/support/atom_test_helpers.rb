module AtomTestHelpers
  def assert_select_atom_feed(&block)
    assert_select ':root > feed[xmlns="http://www.w3.org/2005/Atom"][xml:lang="en-GB"]', &block
  end

  def assert_select_autodiscovery_link(url)
    assert_select 'head > link[rel=?][type=?][href=?]', 'alternate', 'application/atom+xml', ERB::Util.html_escape(url)
  end
end