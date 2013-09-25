class AddHtmlColumnsToAttachments < ActiveRecord::Migration
  class HtmlVersion < ActiveRecord::Base
    belongs_to :edition
  end

  def up
    add_column :attachments, :slug, :string
    add_column :attachments, :body, :text, limit: 4.gigabytes - 1
    add_column :attachments, :manually_numbered, :boolean

    HtmlAttachment.reset_column_information
    HtmlVersion.scoped.find_each do |version|
      next if version.edition.blank? || version.title.blank? || version.body.blank?
      version.edition.attachments << HtmlAttachment.new(
        title: version.title,
        body: version.body,
        slug: version.slug,
        manually_numbered: version.manually_numbered
      )
    end
  end

  def down
    remove_column :attachments, :slug
    remove_column :attachments, :body
    remove_column :attachments, :manually_numbered
  end
end
