class CreateLabels < ActiveRecord::Migration
	def up
		create_table :labels do |t|
			t.string :name
			t.timestamps
		end
	end

	def down
		drop_table :labels
	end
end
