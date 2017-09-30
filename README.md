# openvpn-otp

## なにこれ?

openvpnでOne Time Passwordを使った認証をするためのスクリプト。

## 使い方
### ユーザの作成

```
$ ./createuser.rb
```

### openvpn.confの編集

```
script-security 2
auth-user-pass-verify /usr/local/etc/openvpn/auth.rb via-file
```
