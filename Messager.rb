# encoding: utf-8
require 'thread'

class Messager

	attr_accessor :queue

	def initialize(host, port, oauth, username, channel, logger, chocobot)
		@queue = Queue.new
		@stop = false
		@run = true
		@write_mutex = Mutex.new
		@ping_time = Time.new
		@cantConnect = false

		@host = host
		@port = port
		@oauth = oauth
		@channel = channel
		@username = username
		@logger = logger
		@chocobot = chocobot

		connect()


		Thread.new do
			while @run
				element = @queue.pop(true) rescue nil # nötig, sonst geht STRG+C nicht
				if @ping_time + 300 < Time.new()
					@logger.puts("Reconnecting...", true)
					connect()
					@ping_time = Time.new()
				elsif element != nil
					@write_mutex.synchronize do
						@irc.puts(element)
					end
					sleep(2)
				elsif @stop
					@run = false
					@irc.puts("PART " + @channel)
					@irc.close()
				else
					sleep(1)
				end
			end
		end
	end

	def connect()
		@write_mutex.synchronize do
			if !closed?
				@irc.close()
			end
			tries = 0
			while closed?
				begin
					@irc = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
					@irc.connect(Socket.pack_sockaddr_in(@port, @host))
				rescue IOError, SystemCallError => e
					if tries == 6
						@cantConnect = true
						raise e
					end
					tries += 1
					sleep(10)
				end
			end
			@irc.puts("PASS " + @oauth)
			@irc.puts("NICK " + @username)
			@irc.puts("CAP REQ :twitch.tv/membership ")
			@irc.write("JOIN " + @channel + "\n")
		end
		@chocobot.initOps()
	end

	def stop()
		@stop = true
		while @run
			sleep(2)
		end
		@irc.close() if !closed?
	end

	def ping(text)
		raw("PONG " + text)
		@ping_time = Time.new
	end

	def message(msg)
		broken?
		@logger.puts(@username + ": " + msg, @logger.messages)
		@queue << ("PRIVMSG " + @channel + " :" + msg)
	end

	def raw(msg)
		broken?
		@write_mutex.synchronize do
			@irc.puts(msg)
		end
	end

	def gets()
		if !closed?
			begin
				return @irc.gets()
			rescue IOError, SystemCallError => e
				sleep(1)
				return nil
			end
		else
			return nil
		end
	end

	def closed?()
		broken?
		if @irc != nil
			return @irc.closed?()
		else
			return true
		end
	end

	def broken?()
		raise "Couldn't connect" if @cantConnect
	end

end