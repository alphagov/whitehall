module UserOrderableExtension
  def reorder_without_callbacks!(new_order, column = :ordering)
    transaction do
      new_order.each do |id, ordering|
        find(id).update_column(column, ordering)
      end
    end
  end

  def reorder!(new_order, column = :ordering)
    new_order.each do |id, ordering|
      find(id).update!("#{column}": ordering)
    end
  end
end
