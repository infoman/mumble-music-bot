class MusicBot
  protected
  def parse_message(msg)
    dump_thread_info
    puts "[m] Received text message: #{msg.message}"

    stop if msg.message.downcase == '!quit'
  end

  def connected(server)
    return true if @ready
    dump_thread_info
    puts "[s] Got hello from server:"
    puts "    #{server.welcome_text}"
    puts "[s] End hello from server"

    sleep 2
    @ready = true
  end

  def user_state(message)
    puts '[d] Received UserState message:'
    puts message.inspect
    user = user_by_session(message.session) || message
    puts "[u] Got UserState message for user #{user.name} (#{user.user_id})"
    puts "[u] #{user.name} is now in channel id #{user.channel_id}"
  end

  def user_by_session(session_id)
    puts "[d] Finding user by session id #{session_id}"
    user = @client.users.values.find {|u| u.session == session_id}
    puts "[d] Found:\n#{user.inspect}"
  end

  def dump_thread_info
    puts "[t] #{Thread.current.inspect}"
  end

  public
  attr_reader :client

  def initialize
    Thread.abort_on_exception = true
    @running = false
    login   = Settings.connection
    @client = Mumble::Client.new(login.host, login.port, login.nickname, login.password)

    @client.on_text_message {|m| parse_message(m)}
    @client.on_server_sync  {|m| connected(m)}
    @client.on_user_state   {|m| user_state(m)}

    # Mumble::Messages.all_types.each do |msg_type|
    #   @client.send(:"on_#{msg_type}") do |msg|
    #     puts "[?] Got message #{msg.class.to_s}"
    #     puts msg.inspect
    #   end
    # end
  end

  def start
    dump_thread_info
    puts "[c] Connecting to server"
    @client.connect

    # Wait until the connection is established
    until @ready do
      sleep 1
    end

    # Start an audio stream
    puts "[c] Starting audio stream"
    @stream  = @client.stream_raw_audio(Settings.mpd.fifo)
    @stream.volume = Settings.mpd.volume
    @running = true

    # Empty loop
    while @running do
      sleep 1
    end

    # Exiting
    puts "[q] Stopping audio stream"
    @stream.stop
    puts "[q] Disconnecting from server"
    @client.disconnect
    puts "[q] Exiting"
    Process.exit 0
  end

  def stop
    dump_thread_info

    raise "Don't know how to stop yet"
    @running = 0
  end
end
