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

ActiveRecord::Schema.define(version: 20141113001233) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "accounts", ["remember_token"], name: "index_accounts_on_remember_token", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "agency_payment_infos", force: true do |t|
    t.string   "method"
    t.boolean  "pickup_required"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_payment_infos", ["restaurant_id"], name: "index_agency_payment_infos_on_restaurant_id", using: :btree

  create_table "assignments", force: true do |t|
    t.integer  "shift_id"
    t.integer  "rider_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
  end

  create_table "conflicts", force: true do |t|
    t.string   "period"
    t.integer  "rider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.datetime "end"
  end

  add_index "conflicts", ["end"], name: "index_conflicts_on_end", using: :btree
  add_index "conflicts", ["rider_id"], name: "index_conflicts_on_rider_id", using: :btree
  add_index "conflicts", ["start"], name: "index_conflicts_on_start", using: :btree

  create_table "contacts", force: true do |t|
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "email"
    t.string   "title"
    t.integer  "contactable_id"
    t.string   "contactable_type"
  end

  add_index "contacts", ["contactable_id", "contactable_type"], name: "index_contacts_on_contactable_id_and_contactable_type", using: :btree

  create_table "equipment_needs", force: true do |t|
    t.boolean  "bike_provided"
    t.boolean  "rack_required"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "equipment_needs", ["restaurant_id"], name: "index_equipment_needs_on_restaurant_id", using: :btree

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
    t.boolean  "car"
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
    t.decimal  "lat"
    t.decimal  "lng"
  end

  add_index "locations", ["locatable_id"], name: "index_locations_on_locatable_id", using: :btree

  create_table "managers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "managers_restaurants", id: false, force: true do |t|
    t.integer "restaurant_id", null: false
    t.integer "manager_id",    null: false
  end

  add_index "managers_restaurants", ["manager_id", "restaurant_id"], name: "index_managers_restaurants_on_manager_id_and_restaurant_id", using: :btree
  add_index "managers_restaurants", ["restaurant_id", "manager_id"], name: "index_managers_restaurants_on_restaurant_id_and_manager_id", using: :btree

  create_table "mini_contacts", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mini_contacts", ["restaurant_id"], name: "index_mini_contacts_on_restaurant_id", using: :btree

  create_table "qualification_sets", force: true do |t|
    t.text     "hiring_assessment"
    t.text     "experience"
    t.text     "geography"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rider_id"
  end

  add_index "qualification_sets", ["rider_id"], name: "index_qualification_sets_on_rider_id", using: :btree

  create_table "restaurants", force: true do |t|
    t.boolean  "active"
    t.string   "status"
    t.text     "brief"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unedited"
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

  create_table "rider_ratings", force: true do |t|
    t.integer  "rider_id"
    t.integer  "initial_points"
    t.integer  "likeability"
    t.integer  "reliability"
    t.integer  "speed"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rider_ratings", ["rider_id"], name: "index_rider_ratings_on_rider_id", using: :btree

  create_table "riders", force: true do |t|
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

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

  create_table "skill_sets", force: true do |t|
    t.integer  "rider_id"
    t.boolean  "bike_repair"
    t.boolean  "fix_flats"
    t.boolean  "early_morning"
    t.boolean  "pizza"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skill_sets", ["rider_id"], name: "index_skill_sets_on_rider_id", using: :btree

  create_table "staffers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "work_specifications", force: true do |t|
    t.integer  "restaurant_id"
    t.string   "zone"
    t.string   "daytime_volume"
    t.string   "evening_volume"
    t.text     "extra_work_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "extra_work"
  end

  add_index "work_specifications", ["restaurant_id"], name: "index_work_specifications_on_restaurant_id", using: :btree

end
