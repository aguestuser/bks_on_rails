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

ActiveRecord::Schema.define(version: 20140703052908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contact_infos", force: true do |t|
    t.string   "phone"
    t.string   "email"
    t.string   "street_address"
    t.string   "borough"
    t.string   "neighborhood"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.string   "name"
  end

  add_index "contact_infos", ["contactable_id"], name: "index_contact_infos_on_contactable_id", using: :btree
  add_index "contact_infos", ["email"], name: "index_contact_infos_on_email", unique: true, using: :btree

  create_table "staffers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.integer  "contact_info_id"
  end

  add_index "staffers", ["contact_info_id"], name: "index_staffers_on_contact_info_id", using: :btree

end
