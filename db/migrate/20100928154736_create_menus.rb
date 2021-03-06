class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.string :name
      t.string :change_frequency
      t.references :remote_attachment
      t.references :restaurant

      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end
