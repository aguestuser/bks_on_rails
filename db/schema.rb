# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140710004623) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agency_payment_infos", force: true do |t|
    t.string   "method"
    t.boolean  "pickup_required"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_payment_infos", ["restaurant_id"], name: "index_agency_payment_infos_on_restaurant_id", using: :btree

  create_table "contact_infos", force: true do |t|
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_id"
    t.string   "contact_type"
    t.string   "name"
  end

  add_index "contact_infos", ["contact_id"], name: "index_contact_infos_on_contact_id", using: :btree

  create_table "equipment_sets", force: true do |t|
    t.integer  "equipable_id"
    t.string   "equipable_type"
    t.boolean  "bike"
    t.boolean  "lock"
    t.boolean  "helmet"
    t.boolean  "rack"
    t.boolean  "bag"
    t.boolean  "heated_bag"
    t.boolean  "cell_phone"
    t.boolean  "smart_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "equipment_sets", ["equipable_id", "equipable_type"], name: "index_equipment_sets_on_equipable_id_and_equipable_type", using: :btree

  create_table "locations", force: true do |t|
    t.integer  "locatable_id"
    t.string   "locatable_type"
    t.string   "address"
    t.string   "borough"
    t.string   "neighborhood"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["locatable_id"], name: "index_locations_on_locatable_id", using: :btree

  create_table "managers", force: true do |t|
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "managers", ["restaurant_id"], name: "index_managers_on_restaurant_id", using: :btree

  create_table "restaurants", force: true do |t|
    t.boolean  "active"
    t.string   "status"
    t.text     "description"
    t.string   "agency_payment_method"
    t.boolean  "pickup_required"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rider_payment_infos", force: true do |t|
    t.integer  "restaurant_id"
    t.string   "method"
    t.string   "rate"
    t.boolean  "shift_meal"
    t.boolean  "cash_out_tips"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rider_payment_infos", ["restaurant_id"], name: "index_rider_payment_infos_on_restaurant_id", using: :btree

  create_table "shifts", force: true do |t|
    t.integer  "restaurant_id"
    t.datetime "start"
    t.datetime "end"
    t.string   "period"
    t.string   "urgency"
    t.string   "billing_rate"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shifts", ["restaurant_id"], name: "index_shifts_on_restaurant_id", using: :btree

  create_table "staffers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_infos", force: true do |t|
    t.string   "title"
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
  end

  add_index "user_infos", ["user_id"], name: "index_user_infos_on_user_id", using: :btree

  create_table "work_specifications", force: true do |t|
    t.integer  "restaurant_id"
    t.string   "zone"
    t.string   "daytime_volume"
    t.string   "evening_volume"
    t.string   "extra_work"
    t.text     "extra_work_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_specifications", ["restaurant_id"], name: "index_work_specifications_on_restaurant_id", using: :btree

end
