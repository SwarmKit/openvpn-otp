#!/usr/bin/env ruby
# coding: UTF-8

require "sqlite3"
require "rotp"

AUTH_FAIL = 1
AUTH_SUCCESS = 0

username = gets.chomp
password = gets.chomp

db = SQLite3::Database.new "/usr/local/etc/openvpn/users.db"

row = db.execute("select * from users where name = ?", [username])

if row.size == 0 then
    exit(AUTH_FAIL)
end

otp_secret = row.first[1]
totp = ROTP::TOTP.new(otp_secret)

result = totp.verify(password) ? AUTH_SUCCESS : AUTH_FAIL
exit(result)
