module ColumnHelper
  def columnize(array, &block)
    i = 0
    array.partition { i += 1; i.odd? }.each { |partition| yield partition }
  end
end
