module Replaceable
  extend ActiveSupport::Concern

  def cant_be_replaced_by_self
    return if replaced_by.nil?

    errors.add(:base, "can't be replaced by itself") if replaced_by == self
  end

  def replaced?
    replaced_by.present?
  end

  def replacement_asset_for(asset)
    replaced_by.assets.where(variant: asset.variant).first || replaced_by.assets.where(variant: Asset.variants[:original]).first
  end

  def replace_with!(replacement)
    self.replaced_by = replacement
    cant_be_replaced_by_self
    raise ActiveRecord::RecordInvalid, self if errors.any?

    update_column(:replaced_by_id, replacement.id)
  end

  def handle_to_replace_id
    return if to_replace_id.blank?

    self.class.find(to_replace_id).replace_with!(self)
  end

  def same_filename_as_replacement?
    return if to_replace_id.blank?

    to_replace = self.class.find(to_replace_id)

    to_replace && to_replace.filename == filename
  end

  def filename_is_unique
    if !same_filename_as_replacement? && attachment_with_same_filename && attachment_with_same_filename.attachment_data != self
      errors.add(:file, "with name \"#{filename}\" already attached to document")
    end
  end
end
