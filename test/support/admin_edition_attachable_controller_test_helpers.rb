module AdminEditionAttachableControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_require_alternative_format_provider_for(edition_type)
      edition_class = edition_class_for(edition_type)
      edition_base_class_name = edition_class.base_class.name.underscore
      attachment_join_table = edition_class.reflect_on_association(:attachments).through_reflection.table_name
      attachment_join_attributes = "#{attachment_join_table}_attributes".to_sym

      test "creating an edition with an attachment but no alternative_format_provider will get a validation error" do
        post :create, edition_base_class_name => controller_attributes_for(edition_type,
          alternative_format_provider_id: "",
          attachment_join_attributes => {
            "0" => { attachment_attributes: attributes_for(:attachment) }
          }
        )

        assert_select ".errors li", "Alternative format provider can&#x27;t be blank"
      end

      test "updating an edition with an attachment but no alternative_format_provider will get a validation error" do
        edition = create(edition_type)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition,
          alternative_format_provider_id: "",
          attachment_join_attributes => {
            "0" => { attachment_attributes: attributes_for(:attachment) }
          }
        )

        assert_select ".errors li", "Alternative format provider can&#x27;t be blank"
      end
    end

    def show_should_display_attachments_for(edition_type)
      edition_class = edition_class_for(edition_type)
      edition_base_class_name = edition_class.base_class.name.underscore
      attachment_join_table = edition_class.reflect_on_association(:attachments).through_reflection.table_name
      attachment_join_attributes = "#{attachment_join_table}_attributes".to_sym

      test 'show displays edition attachments' do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, title: "attachment-title", file: two_page_pdf)
        edition = create(edition_type, :with_alternative_format_provider, attachments: [attachment])

        get :show, id: edition

        assert_select "#attachments" do
          assert_select_object attachment do
            assert_select "a[href=?]", attachment.url do
              assert_select "img[src=?]", attachment.url(:thumbnail)
            end
          end
        end
      end
    end

    def should_allow_attachments_for(edition_type)
      edition_class = edition_class_for(edition_type)
      edition_base_class_name = edition_class.base_class.name.underscore
      attachment_join_table = edition_class.reflect_on_association(:attachments).through_reflection.table_name
      attachment_join_attributes = "#{attachment_join_table}_attributes".to_sym

      test "new displays edition attachment fields" do
        get :new

        assert_select "form##{edition_base_class_name}_new" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][attachment_data_attributes][file]'][type='file']"
        end
      end

      test 'creating an edition should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attributes = controller_attributes_for(edition_type)
        attributes[attachment_join_attributes] = {
          "0" => {
            attachment_attributes: attributes_for(:attachment, title: "attachment-title").merge(attachment_data_attributes: {
              file: greenpaper_pdf
            })
          }
        }

        post :create, edition_base_class_name => attributes

        assert_equal [], css_select('.errors')
        assert edition = edition_class.last
        assert_equal 1, edition.attachments.length
        attachment = edition.attachments.first
        assert_equal "attachment-title", attachment.title
        assert_equal "greenpaper.pdf", attachment.attachment_data.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test "creating an edition should result in a single instance of the uploaded file being cached" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attributes = controller_attributes_for(edition_type)
        attributes[attachment_join_attributes] = {
          "0" => {
            attachment_attributes: attributes_for(:attachment, title: "attachment-title").merge(attachment_data_attributes: {
              file: greenpaper_pdf
            })
          }
        }

        AttachmentData.any_instance.expects(:file=).once

        post :create, edition_base_class_name => attributes
      end

      test "creating an edition with invalid data should still show attachment fields" do
        post :create, edition_base_class_name => make_invalid(controller_attributes_for(edition_type))

        assert_select "form##{edition_base_class_name}_new" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][attachment_data_attributes][file]'][type='file']"
        end
      end

      test "creating an edition with invalid data should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, edition_base_class_name => make_invalid(controller_attributes_for(edition_type,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment).merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            }
          }
        ))

        assert_select "form##{edition_base_class_name}_new" do
          assert_select "input[name*='#{edition_base_class_name}[#{attachment_join_attributes}]'][type='file']", count: 1
        end
      end

      test "creating an edition with invalid data but valid attachment data should still display the attachment data" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, edition_base_class_name => make_invalid(controller_attributes_for(edition_type,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment, title: "attachment-title").merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            }
          }
        ))

        assert_select "form##{edition_base_class_name}_new" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][title]'][value='attachment-title']"
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][attachment_data_attributes][file_cache]'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test 'creating an edition with invalid data should not show any existing attachment info' do
        attributes = controller_attributes_for(edition_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        attributes[attachment_join_attributes] = {
          "0" => {
            attachment_attributes: attributes_for(:attachment).merge(attachment_data_attributes: {
              file: greenpaper_pdf
            })
          }
        }

        post :create, edition_base_class_name => make_invalid(attributes)

        refute_select "p.attachment"
      end

      test "creating an edition with multiple attachments should attach all files" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attributes = controller_attributes_for(edition_type)
        attributes[attachment_join_attributes] = {
          "0" => {
            attachment_attributes: attributes_for(:attachment, title: "attachment-1-title").merge(attachment_data_attributes: {
              file: greenpaper_pdf
            })
          },
          "1" => {
            attachment_attributes: attributes_for(:attachment, title: "attachment-2-title").merge(attachment_data_attributes: {
              file: csv_file
            })
          }
        }

        post :create, edition_base_class_name => attributes

        assert edition = edition_class.last
        assert_equal 2, edition.attachments.length
        attachment_1 = edition.attachments.first
        assert_equal "attachment-1-title", attachment_1.title
        assert_equal "greenpaper.pdf", attachment_1.attachment_data.carrierwave_file
        assert_equal "application/pdf", attachment_1.content_type
        assert_equal greenpaper_pdf.size, attachment_1.file_size
        attachment_2 = edition.attachments.last
        assert_equal "attachment-2-title", attachment_2.title
        assert_equal "sample-from-excel.csv", attachment_2.attachment_data.carrierwave_file
        assert_equal "text/csv", attachment_2.content_type
        assert_equal csv_file.size, attachment_2.file_size
      end

      test 'edit displays edition attachment fields' do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, title: "attachment-title", file: two_page_pdf)
        edition = create(edition_type, :with_alternative_format_provider, attachments: [attachment])

        get :edit, id: edition

        assert_select "form##{edition_base_class_name}_edit" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][title]'][type='text'][value='attachment-title']"
          assert_select ".attachment" do
            assert_select "a", text: %r{two-pages.pdf$}
          end
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][1][attachment_attributes][title]'][type='text']"
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][1][attachment_attributes][attachment_data_attributes][file]'][type='file']"
        end
      end

      test 'updating an edition should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        edition = create(edition_type, :with_alternative_format_provider)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment, title: "attachment-title").merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            }
          }
        )

        edition.reload
        assert_equal 1, edition.attachments.length
        attachment = edition.attachments.first
        assert_equal "attachment-title", attachment.title
        assert_equal "greenpaper.pdf", attachment.attachment_data.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test 'updating an edition should attach multiple files' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        edition = create(edition_type, :with_alternative_format_provider)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment, title: "attachment-1-title").merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            },
            "1" => {
              attachment_attributes: attributes_for(:attachment, title: "attachment-2-title").merge(attachment_data_attributes: {
                file: csv_file
              })
            }
          }
        )

        edition.reload
        assert_equal 2, edition.attachments.length
        attachment_1 = edition.attachments.first
        assert_equal "attachment-1-title", attachment_1.title
        assert_equal "greenpaper.pdf", attachment_1.attachment_data.carrierwave_file
        assert_equal "application/pdf", attachment_1.content_type
        assert_equal greenpaper_pdf.size, attachment_1.file_size
        attachment_2 = edition.attachments.last
        assert_equal "attachment-2-title", attachment_2.title
        assert_equal "sample-from-excel.csv", attachment_2.attachment_data.carrierwave_file
        assert_equal "text/csv", attachment_2.content_type
        assert_equal csv_file.size, attachment_2.file_size
      end

      test "updating an edition with invalid data should still allow attachment to be selected for upload" do
        edition = create(edition_type)
        put :update, id: edition, edition_base_class_name => make_invalid(controller_attributes_for_instance(edition))

        assert_select "form##{edition_base_class_name}_edit" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][attachment_data_attributes][file]'][type='file']"
        end
      end

      test "updating an edition with invalid data should only allow a single attachment to be selected for upload" do
        edition = create(edition_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: edition, edition_base_class_name => make_invalid(controller_attributes_for(edition_type,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment).merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            }
          }
        ))

        assert_select "form##{edition_base_class_name}_edit" do
          assert_select "input[name*='#{edition_base_class_name}[#{attachment_join_attributes}]'][type='file']", count: 1
        end
      end

      test "updating an edition with invalid data and valid attachment data should display the attachment data" do
        edition = create(edition_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: edition, edition_base_class_name => make_invalid(controller_attributes_for(edition_type,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment, title: "attachment-title").merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            }
          }
        ))

        assert_select "form##{edition_base_class_name}_edit" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][title]'][value='attachment-title']"
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][attachment_data_attributes][file_cache]'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test "updating a stale edition should still display attachment fields" do
        edition = create_draft(edition_type)
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition, lock_version: lock_version)

        assert_select "form##{edition_base_class_name}_edit" do
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='#{edition_base_class_name}[#{attachment_join_attributes}][0][attachment_attributes][attachment_data_attributes][file]'][type='file']"
        end
      end

      test "updating a stale edition should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        edition = create_draft(edition_type)
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition,
          lock_version: lock_version,
          attachment_join_attributes => {
            "0" => {
              attachment_attributes: attributes_for(:attachment).merge(attachment_data_attributes: {
                file: greenpaper_pdf
              })
            }
          }
        )

        assert_select "form##{edition_base_class_name}_edit" do
          assert_select "input[name*='#{edition_base_class_name}[#{attachment_join_attributes}]'][type='file']", count: 1
        end
      end

      test 'updating should allow removal of attachments' do
        attachment_1 = create(:attachment)
        attachment_2 = create(:attachment)
        edition = create(edition_type, :with_alternative_format_provider)
        edition_attachment_1 = create("#{edition_base_class_name}_attachment", edition_base_class_name => edition, attachment: attachment_1)
        edition_attachment_2 = create("#{edition_base_class_name}_attachment", edition_base_class_name => edition, attachment: attachment_2)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition,
          attachment_join_attributes => {
            "0" => { id: edition_attachment_1.id.to_s, _destroy: "1" },
            "1" => { id: edition_attachment_2.id.to_s, _destroy: "0" },
            "2" => {
              attachment_attributes: {
                attachment_data_attributes: { file_cache: "" }
              }
            }
          }
        )

        refute_select ".errors"
        edition.reload
        assert_equal [attachment_2], edition.attachments
      end

      test 'updating should respect the attachment_action attribute to keep, remove, or replace attachments' do
        two_pages_pdf = fixture_file_upload('two-pages.pdf')
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        attachment_1 = create(:attachment, file: File.open(File.join(Rails.root, 'test', 'fixtures', 'whitepaper.pdf')))
        attachment_1_data = attachment_1.attachment_data
        attachment_2 = create(:attachment, file: File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')))
        attachment_3 = create(:attachment, file: File.open(File.join(Rails.root, 'test', 'fixtures', 'three-pages.pdf')))
        attachment_3_data = attachment_3.attachment_data

        edition = create(edition_type, :with_alternative_format_provider)
        edition_attachment_1 = create("#{edition_base_class_name}_attachment", edition_base_class_name => edition, attachment: attachment_1)
        edition_attachment_2 = create("#{edition_base_class_name}_attachment", edition_base_class_name => edition, attachment: attachment_2)
        edition_attachment_3 = create("#{edition_base_class_name}_attachment", edition_base_class_name => edition, attachment: attachment_3)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition,
          attachment_join_attributes => {
            "0" => { id: edition_attachment_1.id.to_s, attachment_attributes: {
              id: attachment_1.id,
              attachment_action: 'keep'
            }},
            "1" => { id: edition_attachment_2.id.to_s, attachment_attributes: {
              id: attachment_2.id,
              attachment_action: 'remove'
            }},
            "2" => { id: edition_attachment_3.id.to_s, attachment_attributes: {
              id: attachment_3.id,
              attachment_action: 'replace',
              attachment_data_attributes: {
                file: two_pages_pdf,
                to_replace_id: attachment_3.attachment_data.id
              }
            }},
            "3" => { attachment_attributes: attributes_for(:attachment).merge(
              attachment_data_attributes: { file: greenpaper_pdf }
            )}
          }
        )

        refute_select ".errors"
        edition.reload
        assert_equal 3, edition.attachments.size
        assert edition.attachments.include?(attachment_1)
        assert !edition.attachments.include?(attachment_2)
        assert edition.attachments.include?(attachment_3)

        assert_raises(ActiveRecord::RecordNotFound) do
          attachment_2.reload
        end

        assert_equal attachment_1_data, attachment_1.reload.attachment_data

        new_attachment_3_data = attachment_3.reload.attachment_data
        assert_not_equal attachment_3_data, new_attachment_3_data
        assert_equal "two-pages.pdf", new_attachment_3_data.carrierwave_file
        assert_equal new_attachment_3_data, attachment_3_data.reload.replaced_by

        attachment_4 = edition.attachments.last
        assert_equal "greenpaper.pdf", attachment_4.attachment_data.carrierwave_file
      end
    end

    def should_allow_bulk_upload_attachments_for(edition_type)
      edition_class = edition_class_for(edition_type)
      edition_base_class_name = edition_class.base_class.name.underscore
      attachment_join_table = edition_class.reflect_on_association(:attachments).through_reflection.table_name
      attachment_join_attributes = "#{attachment_join_table}_attributes".to_sym

      test 'new provides an empty BulkUpload::ZipFile instance' do
        get :new

        assert assigns('bulk_upload_zip_file')
        refute assigns('bulk_upload_zip_file').zip_file
      end

      test 'create will create a BulkUpload::ZipFile from the bulk_upload_zip_file params if attachment_mode is set to "bulk"' do
        attrs = controller_attributes_for(edition_type)
        post :create, edition_base_class_name => attrs,
                      attachment_mode: 'bulk',
                      bulk_upload_zip_file: {
                        zip_file: fixture_file_upload('two-pages-and-greenpaper.zip')
                      }

        assert assigns('bulk_upload_zip_file')
        assert_equal 'two-pages-and-greenpaper.zip', assigns('bulk_upload_zip_file').zip_file.original_filename
      end

      test 'create won\'t create a BulkUpload::ZipFile from the bulk_upload_zip_file params if attachment_mode is not set to "bulk"' do
        attrs = controller_attributes_for(edition_type)
        post :create, edition_base_class_name => attrs,
                      attachment_mode: 'individual',
                      bulk_upload_zip_file: {
                        zip_file: fixture_file_upload('two-pages-and-greenpaper.zip')
                      }

        refute assigns('bulk_upload_zip_file')
      end

      test 'create will render the new form again and not create an instance if the bulk_upload_zip_file params are invalid' do
        attrs = controller_attributes_for(edition_type)
        post :create, edition_base_class_name => attrs,
                      attachment_mode: 'bulk',
                      bulk_upload_zip_file: {
                        zip_file: fixture_file_upload('greenpaper.pdf')
                      }

        assert_template :new
        refute edition_class.find_by_title(attrs['title'])
      end

      test 'create will manipulate the params based and commit the action on the contents of the zip if the bulk_upload_zip_file params are valid' do
        attrs = controller_attributes_for(edition_type)

        BulkUpload::ZipFileToAttachments.any_instance.expects(:manipulate_params!)

        post :create, edition_base_class_name => attrs,
                      attachment_mode: 'bulk',
                      bulk_upload_zip_file: {
                        zip_file: fixture_file_upload('two-pages-and-greenpaper.zip')
                      }

        assert edition_class.find_by_title(attrs[:title])
      end

      test 'editing provides an empty BulkUpload::ZipFile instance' do
        edition = create(edition_type)

        get :edit, id: edition

        assert assigns('bulk_upload_zip_file')
        refute assigns('bulk_upload_zip_file').zip_file
      end

      test 'update will create a BulkUpload::ZipFile from the bulk_upload_zip_file params if attachment_mode is set to "bulk"' do
        edition = create(edition_type)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition),
                     attachment_mode: 'bulk',
                     bulk_upload_zip_file: {
                       zip_file: fixture_file_upload('two-pages-and-greenpaper.zip')
                     }

        assert assigns('bulk_upload_zip_file')
        assert_equal 'two-pages-and-greenpaper.zip', assigns('bulk_upload_zip_file').zip_file.original_filename
      end

      test 'update won\'t create a BulkUpload::ZipFile from the bulk_upload_zip_file params if attachment_mode is not set to "bulk"' do
        edition = create(edition_type)

        put :update, id: edition, edition_base_class_name => controller_attributes_for_instance(edition),
                     attachment_mode: 'individual',
                     bulk_upload_zip_file: {
                       zip_file: fixture_file_upload('two-pages-and-greenpaper.zip')
                     }

        refute assigns('bulk_upload_zip_file')
      end

      test 'update will render the edit form and not update the edition if the bulk_upload_zip_file params are invalid' do
        edition = create(edition_type)
        new_title = edition.title.reverse + 'woo!'

        put :update, id: edition,
                     edition_base_class_name => controller_attributes_for_instance(edition,
                       title: new_title
                     ),
                     attachment_mode: 'bulk',
                     bulk_upload_zip_file: {
                       zip_file: fixture_file_upload('greenpaper.pdf')
                     }

        assert_template :edit
        refute edition_class.find_by_title(new_title)
      end

      test 'update will manipulate the params and commit the action based on the contents of the zip if the bulk_upload_zip_file params are valid' do
        edition = create(edition_type)
        new_title = edition.title.reverse + 'woo!'

        BulkUpload::ZipFileToAttachments.any_instance.expects(:manipulate_params!)


        put :update, id: edition,
                     edition_base_class_name => controller_attributes_for_instance(edition,
                       title: new_title
                     ),
                     attachment_mode: 'bulk',
                     bulk_upload_zip_file: {
                       zip_file: fixture_file_upload('two-pages-and-greenpaper.zip')
                     }

        assert_equal new_title, edition.reload.title
      end
    end
  end

  def create_draft(edition_type)
    create("draft_#{edition_type}")
  end

  def make_invalid(controller_attributes)
    controller_attributes.merge(title: "")
  end
end
