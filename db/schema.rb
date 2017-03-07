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

ActiveRecord::Schema.define(version: 20170307064156) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.integer  "project_id"
    t.boolean  "is_billable"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_archived", default: false
    t.string   "name"
    t.index ["project_id"], name: "index_categories_on_project_id", using: :btree
  end

  create_table "category_members", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "member_id"
    t.integer  "category_id"
    t.boolean  "is_archived", default: false
    t.index ["category_id"], name: "index_category_members_on_category_id", using: :btree
    t.index ["member_id"], name: "index_category_members_on_member_id", using: :btree
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "company_id"
    t.index ["company_id"], name: "index_clients_on_company_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "domain"
    t.integer  "overtime_max", default: 40
    t.integer  "begin_week",   default: 1
  end

  create_table "holidays", force: :cascade do |t|
    t.string   "name",       null: false
    t.date     "begin_date", null: false
    t.date     "end_date",   null: false
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_holidays_on_company_id", using: :btree
  end

  create_table "invites", force: :cascade do |t|
    t.string   "email"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "token"
    t.boolean  "is_accepted"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "expiry"
  end

  create_table "members", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "furlough_total"
    t.integer  "role_id"
    t.index ["company_id"], name: "index_members_on_company_id", using: :btree
    t.index ["role_id"], name: "index_members_on_role_id", using: :btree
    t.index ["user_id"], name: "index_members_on_user_id", using: :btree
  end

  create_table "project_members", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_pm",       default: false
    t.integer  "member_id"
    t.boolean  "is_archived", default: false
    t.index ["member_id"], name: "index_project_members_on_member_id", using: :btree
    t.index ["project_id"], name: "index_project_members_on_project_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.integer  "client_id"
    t.string   "background"
    t.boolean  "is_member_report", default: false
    t.boolean  "is_archived",      default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "member_id"
    t.index ["client_id"], name: "index_projects_on_client_id", using: :btree
    t.index ["member_id"], name: "index_projects_on_member_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name",               default: ""
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "category_member_id"
    t.index ["category_member_id"], name: "index_tasks_on_category_member_id", using: :btree
  end

  create_table "time_offs", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_start_half_day"
    t.boolean  "is_end_half_day"
    t.text     "description"
    t.integer  "status",            default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "sender_id"
    t.integer  "approver_id"
    t.index ["approver_id"], name: "index_time_offs_on_approver_id", using: :btree
    t.index ["sender_id"], name: "index_time_offs_on_sender_id", using: :btree
  end

  create_table "timers", force: :cascade do |t|
    t.integer  "task_id"
    t.datetime "start_time"
    t.datetime "stop_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_timers_on_task_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.string   "email"
    t.jsonb    "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  end

  add_foreign_key "categories", "projects"
  add_foreign_key "category_members", "categories"
  add_foreign_key "category_members", "members"
  add_foreign_key "clients", "companies"
  add_foreign_key "holidays", "companies"
  add_foreign_key "members", "companies"
  add_foreign_key "members", "roles"
  add_foreign_key "members", "users"
  add_foreign_key "project_members", "members"
  add_foreign_key "project_members", "projects"
  add_foreign_key "projects", "clients"
  add_foreign_key "projects", "members"
  add_foreign_key "tasks", "category_members"
  add_foreign_key "timers", "tasks"
end
