require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should be invalid without a title' do
    attachment = build(:file_attachment, title: nil)
    refute attachment.valid?
  end

  test 'should be valid without ISBN' do
    attachment = build(:file_attachment, isbn: nil)
    assert attachment.valid?
  end

  test 'should be valid with blank ISBN' do
    attachment = build(:file_attachment, isbn: "")
    assert attachment.valid?
  end

  test "should be invalid with an ISBN that's not in ISBN-10 or ISBN-13 format" do
    attachment = build(:file_attachment, isbn: "invalid-isbn")
    refute attachment.valid?
  end

  test 'should be valid with ISBN in ISBN-10 format' do
    attachment = build(:file_attachment, isbn: "0261102737")
    assert attachment.valid?
  end

  test 'should be valid with ISBN in ISBN-13 format' do
    attachment = build(:file_attachment, isbn: "978-0261103207")
    assert attachment.valid?
  end

  test "should be valid without Command paper number" do
    attachment = build(:file_attachment, command_paper_number: nil)
    assert attachment.valid?
  end

  test "should be valid with blank Command paper number" do
    attachment = build(:file_attachment, command_paper_number: '')
    assert attachment.valid?
  end

  ['C.', 'Cd.', 'Cmd.', 'Cmnd.', 'Cm.'].each do |prefix|
    test "should be valid when the Command paper number starts with '#{prefix}'" do
      attachment = build(:file_attachment, command_paper_number: "#{prefix} 1234")
      assert attachment.valid?
    end
  end

  test "should be invalid when the command paper number starts with an unrecognised prefix" do
    attachment = build(:file_attachment, command_paper_number: "NA 1234")
    refute attachment.valid?
    expected_message = "is invalid. The number must start with one of #{Attachment::VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}"
    assert attachment.errors[:command_paper_number].include?(expected_message)
  end

  test 'should be invalid with malformed order url' do
    attachment = build(:file_attachment, order_url: "invalid-url")
    refute attachment.valid?
  end

  test 'should be valid with order url with HTTP protocol' do
    attachment = build(:file_attachment, order_url: "http://example.com")
    assert attachment.valid?
  end

  test 'should be valid with order url with HTTPS protocol' do
    attachment = build(:file_attachment, order_url: "https://example.com")
    assert attachment.valid?
  end

  test 'should be valid without order url' do
    attachment = build(:file_attachment, order_url: nil)
    assert attachment.valid?
  end

  test 'should be valid with blank order url' do
    attachment = build(:file_attachment, order_url: nil)
    assert attachment.valid?
  end

  test 'should be valid if the price is nil' do
    attachment = build(:file_attachment, price: nil)
    assert attachment.valid?
  end

  test 'should be valid if the price is blank' do
    attachment = build(:file_attachment, price: '')
    assert attachment.valid?
  end

  test 'should be valid if the price appears to be in whole pounds' do
    attachment = build(:file_attachment, price: "9", order_url: 'http://example.com')
    assert attachment.valid?
  end

  test 'should be valid if the price is in pounds and pence' do
    attachment = build(:file_attachment, price: "1.23", order_url: 'http://example.com')
    assert attachment.valid?
  end

  test 'should be invalid if the price is non numeric' do
    attachment = build(:file_attachment, price: 'free', order_url: 'http://example.com')
    refute attachment.valid?
  end

  test 'should be invalid if the price is zero' do
    attachment = build(:file_attachment, price: "0", order_url: 'http://example.com')
    refute attachment.valid?
  end

  test 'should be invalid if the price is less than zero' do
    attachment = build(:file_attachment, price: "-1.23", order_url: 'http://example.com')
    refute attachment.valid?
  end

  test 'should be invalid if a price is entered without an order url' do
    attachment = build(:file_attachment, price: "1.23")
    refute attachment.valid?
  end

  test "should save the price as price_in_pence" do
    attachment = create(:file_attachment, price: "1.23", order_url: 'http://example.com')
    attachment.reload
    assert_equal 123, attachment.price_in_pence
  end

  test "should save the price as nil if an existing price_in_pence is being reset to blank" do
    attachment = create(:file_attachment, price_in_pence: 999, order_url: 'http://example.com')
    attachment.price = ''
    attachment.save!
    attachment.reload
    assert_equal nil, attachment.price_in_pence
  end

  test "should not save a nil price as a zero price_in_pence" do
    attachment = create(:file_attachment, price: nil)
    attachment.reload
    assert_equal nil, attachment.price_in_pence
  end

  test "should not save a blank price as a zero price_in_pence" do
    attachment = create(:file_attachment, price: '')
    attachment.reload
    assert_equal nil, attachment.price_in_pence
  end

  test "should prefer the memoized price over price_in_pence" do
    attachment = build(:file_attachment, price: "1.23", price_in_pence: 345)
    assert_equal "1.23", attachment.price
  end

  test "should convert price_in_pence to price in pounds when a new price hasn't been set" do
    attachment = build(:file_attachment, price_in_pence: 345)
    assert_equal 3.45, attachment.price
  end

  test "should return nil if neither price nor price_in_pence are set" do
    attachment = build(:file_attachment, price: nil, price_in_pence: nil)
    assert_nil attachment.price
  end

  test "does not destroy attachment_data when more attachments are associated" do
    attachment = create(:file_attachment)
    attachment_data = attachment.attachment_data
    other_attachment = create(:file_attachment, attachment_data: attachment_data)

    attachment_data.expects(:destroy).never
    attachment.destroy
  end

  test "destroys attachment_data when no attachments are associated" do
    attachment = create(:file_attachment)
    attachment_data = attachment.attachment_data

    attachment_data.expects(:destroy)
    attachment.destroy
  end

  def assert_delegated attachment, method
     attachment.attachment_data.expects(method).returns(method.to_s)
     assert_equal method.to_s, attachment.send(method)
  end

  test "asks data for file specific information" do
    attachment = build(:file_attachment)

    assert_delegated attachment, :url
    assert_delegated attachment, :content_type
    assert_delegated attachment, :pdf?
    assert_delegated attachment, :extracted_text
    assert_delegated attachment, :file_extension
    assert_delegated attachment, :file_size
    assert_delegated attachment, :number_of_pages
    assert_delegated attachment, :file
    assert_delegated attachment, :filename
  end

  test 'should generate list of parliamentary sessions' do
    earliest_session = '1951-52'
    now = Time.zone.now
    latest_session = [now.strftime('%Y'), (now + 1.year).strftime('%y')].join('-')
    assert_equal latest_session, Attachment.parliamentary_sessions.first
    assert_equal earliest_session, Attachment.parliamentary_sessions.last
  end

  test 'html? is false' do
    attachment = build(:file_attachment)
    refute attachment.html?
  end

  test '#is_command_paper? should be true if attachment has a command paper number or is flagged as an unnumbered command paper' do
    refute build(:html_attachment, command_paper_number: nil,     unnumbered_command_paper: false).is_command_paper?
    assert build(:html_attachment, command_paper_number: '12345', unnumbered_command_paper: false).is_command_paper?
    assert build(:html_attachment, command_paper_number: nil,     unnumbered_command_paper: true ).is_command_paper?
  end

  test '#is_act_paper? should be true if attachment has an act paper number or is flagged as an unnumbered act paper' do
    refute build(:html_attachment, hoc_paper_number: nil,     unnumbered_hoc_paper: false).is_act_paper?
    assert build(:html_attachment, hoc_paper_number: '12345', unnumbered_hoc_paper: false).is_act_paper?
    assert build(:html_attachment, hoc_paper_number: nil,     unnumbered_hoc_paper: true ).is_act_paper?
  end
end
