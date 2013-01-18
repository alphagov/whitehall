module AtomTestHelpers
  def assert_select_atom_feed(&block)
    assert_select ':root > feed[xmlns="http://www.w3.org/2005/Atom"][xml:lang="en-GB"]', &block
  end

  def assert_select_autodiscovery_link(url)
    assert_select 'head > link[rel=?][type=?][href=?]', 'alternate', 'application/atom+xml', ERB::Util.html_escape(url)
  end

  def assert_select_atom_entry(entry, document)
    assert_select entry, 'entry > id', 1
    assert_select entry, 'entry > published', count: 1, text: document.first_public_at.iso8601
    assert_select entry, 'entry > updated', count: 1, text: document.public_timestamp.iso8601
    assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
    assert_select entry, 'entry > title', count: 1, text: "#{document.display_type}: #{document.title}"
    assert_select entry, 'entry > summary', count: 1, text: document.summary
    assert_select entry, 'entry > category', count: 1, text: document.display_type
  end

end
