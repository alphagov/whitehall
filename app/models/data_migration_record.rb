# == Schema Information
#
# Table name: data_migration_records
#
#  id      :integer          not null, primary key
#  version :string(255)
#

class DataMigrationRecord < ActiveRecord::Base
end
