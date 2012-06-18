class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :facebookID
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.string :description
      t.string :location
      t.string :privacy_type #open, closed, secret
      t.boolean :status #true = open, false = closed
      t.integer :participants_maybe #insert at closing
      t.integer :participants_declared  #insert at closing
      t.integer :participants_present #insert at closing
	  
      t.timestamps
    end
  end
end
