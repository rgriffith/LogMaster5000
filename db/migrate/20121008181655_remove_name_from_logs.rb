class RemoveNameFromLogs < ActiveRecord::Migration
  def up
    remove_column :logs, :name
  end

  def down
    add_column :logs, :name, :string
  end
end
