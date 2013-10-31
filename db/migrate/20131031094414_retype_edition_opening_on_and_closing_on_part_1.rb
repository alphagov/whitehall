class RetypeEditionOpeningOnAndClosingOnPart1 < ActiveRecord::Migration
  BATCH_SIZE = 1000

  def up
    add_column :editions, :opening_at, :datetime
    add_column :editions, :closing_at, :datetime

    add_index :editions, :opening_at
    add_index :editions, :closing_at

    # Edition does not have :opening_at= or :closing_at= method until the class is reloaded. Have to set these directly with SQL.
    opening_at_count = 0;
    closing_at_count = 0;

    puts "Setting opening_at for each applicable edition in batches of #{BATCH_SIZE} setting time to zoned midnight."
    Edition.unscoped.where("opening_on is not null").find_each(batch_size: BATCH_SIZE) do |edition|
      suppress_messages do
        execute("UPDATE editions SET opening_at = '#{Time.zone.parse(edition.opening_on.to_s).utc}' WHERE id = #{edition.id}")
        opening_at_count += 1
      end
      putc '.'
    end
    putc "\n"

    puts "Setting closing_at for each applicable edition in batches of #{BATCH_SIZE} setting time to zoned 23:45."
    Edition.unscoped.where("closing_on is not null").find_each(batch_size: BATCH_SIZE) do |edition|
      suppress_messages do
        execute("UPDATE editions SET closing_at = '#{(Time.zone.parse(edition.closing_on.to_s) + 23.hours + 45.minutes).utc}' WHERE id = #{edition.id}")
        closing_at_count += 1
      end
      putc '.'
    end
    putc "\n"

    puts "Updated #{opening_at_count} opening_at attributes and #{closing_at_count} closing_at attributes"
  end

  def down
    remove_column :editions, :opening_at
    remove_column :editions, :closing_at
  end
end
