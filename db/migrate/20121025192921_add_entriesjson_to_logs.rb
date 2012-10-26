class AddEntriesjsonToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :entriesjson, :string
  end
end
