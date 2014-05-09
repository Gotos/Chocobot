require 'thread'

class Messager

	attr_accessor :queue

	def initialize(host, port, oauth, username, channel, logger)
		@queue = Queue.new
		@stop = false
		@run = true
		@write_mutex = Mutex.new


		@channel = channel
		@username = username
		@logger = logger

		@write_mutex.synchronize do
			@irc = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
			@irc.connect(Socket.pack_sockaddr_in(port, host))
			@irc.puts("PASS " + oauth)
			@irc.puts("NICK " + @username)
			@irc.puts("TWITCHCLIENT 1")
			@irc.write("JOIN " + @channel + "\n")
		end


		Thread.new do
			while @run
				element = @queue.pop(true) rescue nil
				if element != nil
					@write_mutex.synchronize do
						@irc.puts(element)
					end
					sleep(2)
				elsif @stop
					@run = false
					@irc.puts("PART " + @channel)
					@irc.close()
				end	
			end
		end
	end

	def stop()
		@stop = true
		while @run
			sleep(2)
		end
	end

	def message(msg)
		@logger.puts(@username + ": " + msg, @logger.messages)
		@queue << ("PRIVMSG " + @channel + " :" + msg)
	end

	def raw(msg)
		@write_mutex.synchronize do
			@irc.puts(msg)
		end
	end

	def gets()
		return @irc.gets()
	end

	def closed?()
		return @irc.closed?()
	end

end