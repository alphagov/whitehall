module Admin::MillerColumnsHelper
  def check_item?(item)
    item[:checked].present? &&
      item[:checked] ||
      item[:items].any? do |child|
        child[:checked] ||
          child[:items].any? do |grandchild|
            grandchild[:checked]
          end
      end
  end
end
