module Admin::CancelRoutesHelper
  include Admin::EditionRoutesHelper
  def admin_cancel_path(object)
    if object.is_a? Edition
      object.new_record? ? admin_editions_path : admin_edition_path(object)
    else
      object.new_record? ? polymorphic_path([:admin, object.class]) : polymorphic_path([:admin, object])
    end
  end
end
