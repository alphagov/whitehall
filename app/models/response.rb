class Response < ActiveRecord::Base
  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments

  accepts_nested_attributes_for :consultation_response_attachments, reject_if: :all_blank_or_empty_hashes

  private

  def all_blank_or_empty_hashes(attributes)
    hash_with_blank_values?(attributes)
  end

  def hash_with_blank_values?(hash)
    hash.values.inject(true) do |result, value|
      result && (value.is_a?(Hash) ? hash_with_blank_values?(value) : value.blank?)
    end
  end
end