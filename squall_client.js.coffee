window.WEB_SOCKET_SWF_LOCATION = "/plugin_assets/squall_notification/javascripts/WebSocketMain.swf"
window.WEB_SOCKET_FORCE_FLASH = true
window.WEB_SOCKET_DEBUG = true

if !window.console?
  window.console =
    log: (str) -> return str
    error: (str) -> return str

# グローバルクラス
class @SquallClient
  constructor: (@url, @auth_key) ->
    try
      this.socket = new WebSocket(this.url+"?auth_key="+this.auth_key)
      this.heartbeats = []
      this.register_event(false)
    catch error
      console.log "[ERROR] #{error.message}"

  reconnect: ->
    console.log("reconnect called")
    clearInterval(this.ping_request)
    try
      # ここでエラーが起きてしまうがweb-socket-jsのFlash初期化作業が二回行われるだけなので問題なし
      this.socket = new WebSocket(this.url+"?auth_key="+this.auth_key+"&reconnect=true")
      this.heartbeats = []
      console.log("New websocket has taken")
      this.register_event(true)
    catch error
      console.log "[ERROR] #{error.message}"

  register_event: (reconnect)->
    self = this
    this.socket.onopen = (event)->
      return false if not self.onopen?
      self.ping_request = setInterval () ->
        currentTime = new Date().toString()
        self.heartbeats.push(currentTime)
        self.socket.send(currentTime)
        self.reconnect() if self.heartbeats.length >= 2
      , 30000
      self.onopen(event) if !reconnect

    this.socket.onmessage = (event) ->
      return false if not self.onmessage?
      parse_data = event.data;
      squall_ping_data = parse_data in self.heartbeats
      if squall_ping_data
        self.heartbeats = self.heartbeats.filter (e) -> e isnt parse_data
      else
        self.onmessage(event)

    this.socket.onerror = (event)->
      return false if not self.onerror?
      clearInterval(self.ping_request)
      self.onerror(event)

    this.socket.onclose = (event)->
      return false if not self.onclose?
      clearInterval(self.ping_request)
      self.onclose(event)

  close: ->
    return false if not this.socket?
    this.socket.close()

  ## ポップアップ機能 ##

  # ポップアップ認証リクエストメソッド
  # クリックイベントで呼び出すようにする
  popup_request_auth: ->
    return false if not supported_popup()
    if window.Notification.permission != "granted"
      window.Notification.requestPermission()

  # ポップアップ表示メソッド
  popup: (title, content, options={})->
    return false if not supported_popup()
    if not authenticated(window.Notification)
      console.log("---Not authenticated popup---")
      return false

    image_url = if options.image? then options.image else ""
    tag = if options.tag? then options.tag else ""
    notify = create_notification(title, {body: content, icon: image_url, tag: tag})
    set_event_cb(notify, options)
    auto_cancel(notify, options.time) if options.time?
    notify

  # ポップアップクローズメソッド
  popup_cancel: (notify)->
    return false if not supported_popup()
    notify?.cancel()

  # 認証状態チェック
  popup_check_permission: ->
    return false if not supported_popup()
    window.Notification.permission

  # サポートチェック
  check_supported_popup : ->
    if window.Notification? then true else false

  # サポートチェック
  supported_popup = ->
    return true if window.Notification?
    console.log("---Not supported popup---")
    false

  # 認証チェック
  authenticated = ->
    return true if window.Notification.permission == "granted"
    false

  # イベントメソッドセット
  set_event_cb = (notify, options)->
    return false if not notify? or not options?
    notify.onshow = options.onshow if options.onshow?
    notify.onclick = options.onclick if options.onclick?
    notify.onerror = options.onerror if options.onerror?
    notify.onclose = options.onclose if options.onclose?
    # notify.onclick = options.onclick if options.onclick?  # アドオンver.0.7.2では未サポート

  # 自動クローズセット
  auto_cancel = (notify, time)->
     return false if not notify? or not time?
     setTimeout (->
       notify.cancel()
     ), time

  # ポップアップ作成
  # バージョンによるcloseメソッドの違いを吸収
  create_notification = (title, options)->
    notify = new window.Notification(title, options)
    unless notify.cancel
      notify.cancel = ->
        notify.close()
    notify
