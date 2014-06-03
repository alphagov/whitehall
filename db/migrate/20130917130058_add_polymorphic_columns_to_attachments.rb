class AddPolymorphicColumnsToAttachments < ActiveRecord::Migration
  REDUNDANT_TABLES = [
    %w(consultation_response_attachments Response),
    %w(corporate_information_page_attachments CorporateInformationPage),
    %w(edition_attachments Edition),
    %w(policy_group_attachments PolicyGroup),
    %w(supporting_page_attachments SupportingPage)
  ]

  def change
    add_column :attachments, :attachable_id, :integer
    add_column :attachments, :attachable_type, :string

    REDUNDANT_TABLES.each do |table, attachable_cls|
      puts "--  Migrating #{table} attachments"
      execute <<-EOF
        UPDATE attachments JOIN #{table} join_model
            ON attachments.id = join_model.attachment_id
           SET attachments.attachable_id = join_model.#{attachable_cls.underscore}_id,
               attachments.attachable_type = '#{attachable_cls}';
      EOF
    end

    add_index :attachments, [:attachable_id, :attachable_type]
  end
end
