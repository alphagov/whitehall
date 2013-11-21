# encoding: UTF-8
Given(/^there is a publicly visible CSV attachment on the site$/) do
  @attachment  = create(:csv_attachment)
  @publication = create(:published_publication, :with_file_attachment, attachments: [@attachment])
end

When(/^I preview the contents of the attachment$/) do
  visit publication_path(@publication.document)

  within record_css_selector(@attachment.becomes(Attachment)) do
    click_link "View online"
  end
end

Then(/^I should see the CSV data previewed on the page$/) do
  assert page.has_content?(@attachment.title)

  within '.csv-preview table' do
    header_row = page.all('thead tr th').map(&:text)
    assert_equal ['Department', 'Budget', 'Amount spent'], header_row

    data_rows = page.all('tbody tr').map { |data_row| data_row.all('td').map(&:text) }
    assert_equal ['Office for Facial Hair Studies', '£12000000', '£10000000'], data_rows[0]
    assert_equal ['Department of Grooming', '£15000000', '£15600000'], data_rows[1]
  end
end
