# encoding: UTF-8

Given(/^there is a publicly visible CSV attachment on the site$/) do
  @publication = create(:published_publication, :with_file_attachment, attachments: [
    @attachment = build(:csv_attachment)
  ])
end

When(/^I preview the contents of the attachment$/) do
  fn = Rails.root.join('test', 'fixtures', 'sample.csv')

  asset_host = URI.parse(Plek.new.public_asset_host).host
  stub_request(:get, "https://#{asset_host}/government/uploads/system/uploads/attachment_data/file/#{@attachment.attachment_data.id}/sample.csv")
    .with(headers: { 'Range'=>'bytes=0-300000' })
    .to_return(status: 206, body: File.read(fn))

  visit csv_preview_path(
    id: @attachment.attachment_data.id,
    file: @attachment.filename_without_extension,
    extension: @attachment.file_extension,
  )
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
