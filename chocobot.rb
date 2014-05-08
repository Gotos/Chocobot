#!/usr/bin/env ruby
require 'socket'
require 'set'
require './settings.rb'
require './logger.rb'

class Chocobot

	# Initialize
	def initialize()

		# Connect
		concon = Settings.connection
		@irc = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
		@irc.connect(Socket.pack_sockaddr_in(concon[:port], concon[:host]))
		@irc.puts("PASS " + concon[:oauth])
		@username = concon[:username].downcase
		@irc.puts("NICK " + @username)
		@channel = concon[:channel].downcase
		@irc.write("JOIN " + @channel + "\n")
		@run = true

		@ops = Set.new([@username])

		@logger = Logger.new()

		@logger.puts("Initialization complete!", true)
		trap("INT") {
			@run = false
			@irc.puts("PART " + @channel)
			@logger.close()
			@irc.close()
		}
	end

	# Sends a Message to current channel
	def message(msg)
		@irc.puts("PRIVMSG " + @channel + " :" + msg)
		@logger.puts(Settings.connection[:username] + ": " + msg)
	end

	def ping()
		@irc.puts("PONG :Pong")
	end

	def commands(nick, channel, msg)
		case msg.split()[0]
		when "!exit"
			@logger.puts("Exiting...", true)
			@run = false
		end
	end

	# Main-Loop
	def main()
		#message("Selftest complete.")
		
		while @run
			# ctrl-c catching
			begin
				data = @irc.gets()
			rescue IOError => e
				if !@irc.closed?()
					raise e
				end
				return
			end

			if data != nil
				data.strip!()
				puts data
				baseTriple = data.split(' ',3)
				case(baseTriple[1])
				when "PING"
					ping()
				when "MODE"
					meta = baseTriple[2].split(' ', 3)
					channel = meta[0]
					nick = meta[2]
					if channel.downcase == @channel
						if meta[1] == "+o"
							@ops.add(nick)
						elsif meta[1] == "-o"
							@ops.delete(nick)
						end
					end
				when "PRIVMSG"
					nick = data.split('!', 2)[0][1..-1]
					meta = baseTriple[2].split(' :', 2)
					channel = meta[0]
					msg = meta[1]
					if channel.downcase == @channel
						@logger.puts(nick + ": " + msg, @logger.messages())
						if msg[0] == "!"
							commands(nick, channel, msg)
						end
					elsif channel.downcase == @username
						@logger.puts("PRIV: " + nick + ": " + msg, @logger.messages())
					end
				when "353"
					@logger.puts("USERS: " + data.split(@channel + ' :', 2)[1], @logger.joins())
				when "PART"
					nick = data.split('!', 2)[0][1..-1]
					channel = baseTriple[2].split(' :', 2)[0]
					if channel.downcase == @channel
						@logger.puts("PART: " + nick, @logger.joins())
					end
				when "JOIN"
					nick = data.split('!', 2)[0][1..-1]
					channel = data.split(' ', 3)[2].split(' :', 2)[0]
					if channel.downcase == @channel
						@logger.puts("JOIN: " + nick, @logger.joins())
					end
				else
					#puts data
				end
			end
		end

		@irc.puts("PART " + @channel)
		@logger.close()
		@irc.close()
	end
end


# Start everything
Settings.load!("config.yaml")
bot = Chocobot.new()
bot.main()