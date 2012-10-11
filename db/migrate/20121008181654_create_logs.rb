class CreateLogs < ActiveRecord::Migration
	def up
		create_table :logs do |t|
			t.string :logfile
			t.timestamps
		end
	end

	def down
		drop_table :logs
	end
end