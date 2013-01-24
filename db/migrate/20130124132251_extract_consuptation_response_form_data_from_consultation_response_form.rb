class ExtractConsuptationResponseFormDataFromConsultationResponseForm < ActiveRecord::Migration
  class ConsultationResponseForm < ActiveRecord::Base
    belongs_to :consultation_response_form_data,
      foreign_key: 'consultation_response_form_data_id',
      class_name: 'ExtractConsuptationResponseFormDataFromConsultationResponseForm::ConsultationResponseFormData'
  end
  class ConsultationResponseFormData < ActiveRecord::Base
  end

  def move_files(old_id, new_id, path)
    old_dir = "#{path}/consultation_response_form/file/#{old_id}"
    new_dir = "#{path}/consultation_response_form_data/file/#{new_id}"
    cmd = "[ -e #{old_dir} ] && mkdir -p #{new_dir} && cp -f #{old_dir}/* #{new_dir}/"
    system cmd
  end

  def move_response_form_files(old_id, new_id)
    case Whitehall.asset_storage_mechanism
    when :file
      move_files(old_id, new_id, Rails.root.join('public/system/uploads'))
    when :quarantined_file
      move_files(old_id, new_id, Rails.root.join('public/government/uploads'))
      move_files(old_id, new_id, Rails.root.join('incoming-uploads'))
    end
  end

  def extract_consultation_response_form_data_instances
    ConsultationResponseForm.find_each do |crf|
      crf.create_consultation_response_form_data!(
        carrierwave_file: crf.carrierwave_file
      )
      crf.save!
      move_response_form_files(crf.id, crf.consultation_response_form_data.id)
    end
  end

  def up
    create_table :consultation_response_form_data, force: true do |t|
      t.string :carrierwave_file

      t.timestamps
    end

    add_column :consultation_response_forms, :consultation_response_form_data_id, :integer

    extract_consultation_response_form_data_instances

    remove_column :consultation_response_forms, :carrierwave_file
  end

  def down
    # following
    add_column :consultation_response_forms, :carrierwave_file, :string

    remove_column :consultation_response_forms, :consultation_response_form_data_id

    drop_table :consultation_response_form_data
  end
end
