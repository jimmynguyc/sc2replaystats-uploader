require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "#{File.dirname(__FILE__)}/replays.db"
)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.data_source_exists?(:replays)
    create_table :replays do |table|
      table.column :file_name, :string
      table.column :account, :string
      table.column :game_type, :string
      table.column :recorded_at, :datetime
    end
  end
end

class Replay < ActiveRecord::Base; end
