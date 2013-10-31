class RetypeEditionOpeningOnAndClosingOnPart2 < ActiveRecord::Migration
  BATCH_SIZE = 1000

  def up
    remove_column :editions, :opening_on
    remove_column :editions, :closing_on
  end

  def down
    add_column :editions, :opening_on, :date
    add_column :editions, :closing_on, :date

    opening_on_count = 0;
    closing_on_count = 0;

    puts "Setting opening_on for each applicable edition in batches of #{BATCH_SIZE}."
    Edition.unscoped.where("opening_at is not null").find_each(batch_size: BATCH_SIZE) do |edition|
      suppress_messages do
        execute("UPDATE editions SET opening_on = '#{edition.opening_at.to_date.to_s}' WHERE id = #{edition.id}")
        opening_on_count += 1
      end
      putc '.'
    end
    putc "\n"

    puts "Setting closing_on for each applicable edition in batches of #{BATCH_SIZE}."
    Edition.unscoped.where("closing_at is not null").find_each(batch_size: BATCH_SIZE) do |edition|
      suppress_messages do
        execute("UPDATE editions SET closing_on = '#{edition.closing_at.to_date.to_s}' WHERE id = #{edition.id}")
        closing_on_count += 1
      end
      putc '.'
    end
    putc "\n"

    puts "Updated #{opening_on_count} opening_on attributes and #{closing_on_count} closing_on attributes"
  end
end
