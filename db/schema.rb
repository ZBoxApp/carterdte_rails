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

ActiveRecord::Schema.define(version: 20150513150034) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dtes", force: :cascade do |t|
    t.integer  "folio"
    t.string   "rut_receptor"
    t.string   "rut_emisor"
    t.string   "msg_type"
    t.string   "setdte_id"
    t.integer  "dte_type"
    t.date     "fecha_emision"
    t.date     "fecha_recepcion"
    t.integer  "message_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "dtes", ["dte_type"], name: "index_dtes_on_dte_type"
  add_index "dtes", ["rut_emisor"], name: "index_dtes_on_rut_emisor"
  add_index "dtes", ["rut_receptor"], name: "index_dtes_on_rut_receptor"

  create_table "messages", force: :cascade do |t|
    t.string   "to"
    t.string   "from"
    t.text     "message_id"
    t.string   "cc"
    t.time     "sent_date"
    t.string   "qid"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["account_id"], name: "index_messages_on_account_id"
  add_index "messages", ["from"], name: "index_messages_on_from"
  add_index "messages", ["to"], name: "index_messages_on_to"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "account_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "role"
    t.string   "description"
    t.string   "image"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
