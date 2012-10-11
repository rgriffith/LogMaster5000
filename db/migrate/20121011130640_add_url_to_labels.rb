class AddUrlToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :url, :string
  end
end
