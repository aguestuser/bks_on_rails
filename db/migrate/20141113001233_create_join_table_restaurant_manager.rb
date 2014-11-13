class CreateJoinTableRestaurantManager < ActiveRecord::Migration
  def up
    
    create_join_table :restaurants, :managers do |t|
      t.index [:restaurant_id, :manager_id]
      t.index [:manager_id, :restaurant_id]
    end

    Manager.class_eval do
      belongs_to :old_restaurant, class_name: 'Restaurant', foreign_key: 'restaurant_id'
    end

    Manager.all.each do |manager|
      manager.restaurants << manager.old_restaurant
      manager.save
    end

    remove_column :managers, :restaurant_id

  end

  def down

    add_column :managers, :restaurant_id, :integer

    Manager.class_eval do
      belongs_to :new_restaurant, class_name: 'Restaurant', foreign_key: 'restaurant_id'
    end

    Manager.all.each do |manager|
      manager.new_restaurant << manager.restaurants.first 
      manager.save 
    end

    drop_table :restaurants_managers

  end


end
