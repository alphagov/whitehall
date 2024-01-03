module UserOrderable
  extend ActiveSupport::Concern

  included do
    def self.reorder_without_callbacks!(new_order, column)
      transaction do
        new_order.each do |id, ordering|
          find(id).update_column(column, ordering)
        end
      end
    end

    def self.reorder!(new_order, column)
      transaction do
        new_order.each do |id, ordering|
          find(id).update!("#{column}": ordering)
        end
      end
    end
  end
end
