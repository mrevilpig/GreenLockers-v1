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

ActiveRecord::Schema.define(version: 20131115181646) do

  create_table "boxes", force: true do |t|
    t.integer  "locker_id"
    t.string   "name"
    t.integer  "size"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boxes", ["locker_id"], name: "index_boxes_on_locker_id", using: :btree

  create_table "branches", force: true do |t|
    t.string   "name"
    t.string   "st_address"
    t.string   "apt_address"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "mobile_phone"
    t.string   "email"
    t.string   "user_name"
    t.integer  "role"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lockers", force: true do |t|
    t.integer  "branch_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lockers", ["branch_id"], name: "index_lockers_on_branch_id", using: :btree

  create_table "packages", force: true do |t|
    t.integer  "user_id"
    t.integer  "locker_id"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packages", ["locker_id"], name: "index_packages_on_locker_id", using: :btree
  add_index "packages", ["user_id"], name: "index_packages_on_user_id", using: :btree

  create_table "trackings", force: true do |t|
    t.integer  "package_id"
    t.integer  "employee_id"
    t.datetime "time"
    t.binary   "type"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trackings", ["branch_id"], name: "index_trackings_on_branch_id", using: :btree
  add_index "trackings", ["employee_id"], name: "index_trackings_on_employee_id", using: :btree
  add_index "trackings", ["package_id"], name: "index_trackings_on_package_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.string   "email"
    t.string   "st_address"
    t.string   "apt_address"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip"
    t.integer  "preferred_branch_id"
    t.string   "user_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password"
  end

  add_index "users", ["preferred_branch_id"], name: "index_users_on_preferred_branch_id", using: :btree

end
