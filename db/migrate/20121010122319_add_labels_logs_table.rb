class AddLabelsLogsTable < ActiveRecord::Migration
  def up
  	create_table :labels_logs, :id => false do |t|
      t.integer :label_id
      t.integer :log_id
    end
  end

  def down
  	drop_table :labels_logs
  end
end
