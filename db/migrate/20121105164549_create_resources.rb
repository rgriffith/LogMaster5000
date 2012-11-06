class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.string :regex
      t.string :url

      t.timestamps
    end
  end
end
