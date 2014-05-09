#!/usr/bin/env ruby
require 'socket'
require 'set'
require './settings.rb'
require './logger.rb'
require './messager.rb'

class Chocobot

	# Initialize
	def initialize()

		# Connect
		concon = Settings.connection
		
		
		@username = concon[:username].downcase
		@channel = concon[:channel].downcase
		@messager = Messager.new(concon[:host], concon[:port], concon[:oauth], @username, @channel)
		@run = true

		@ops = Set.new([@username])
		@subs = Set.new()

		@logger = Logger.new()

		@logger.puts("Initialization complete!", true)
		trap("INT") {
			@run = false
			@messager.stop()
			@logger.close()
		}
	end

	# Sends a Message to current channel
	def message(msg)
		@messager.message(msg)
		@logger.puts(Settings.connection[:username] + ": " + msg)
	end

	def ping(text)
		@messager.raw("PONG " + text)
	end

	def commands(nick, channel, msg)
		priv = @ops.include?(nick)
		sub = priv || @subs.include?(nick)
		case msg.split(' ')[0]
		when "!exit"
			if priv
				@logger.puts("Exiting...", true)
				@run = false
			end
		when "!ping"
			message("Pong!")
		end
	end

	# Main-Loop
	def main()
		#message("Selftest complete.")
		
		while @run
			# ctrl-c catching
			begin
				data = @messager.gets()
			rescue IOError => e
				if !@messager.closed?()
					raise e
				end
				return
			end

			if data != nil
				data.strip!()
				#puts data
				baseTriple = data.split(' ',3)
				if baseTriple[0] == "PING"
					ping(data.split(' ',2)[1])
				end
				case(baseTriple[1])
				when "MODE"
					meta = baseTriple[2].split(' ', 3)
					channel = meta[0]
					nick = meta[2]
					if channel.downcase == @channel
						if meta[1] == "+o"
							@ops.add(nick)
							@logger.puts("OP: " + nick, @logger.op())
						elsif meta[1] == "-o"
							@ops.delete(nick)
							@logger.puts("DEOP: " + nick, @logger.op())
						end
					end
				when "PRIVMSG"
					nick = baseTriple[0].split('!', 2)[0][1..-1]
					meta = baseTriple[2].split(' :', 2)
					channel = meta[0]
					msg = meta[1]
					if channel.downcase == @channel
						if @subs.include?(nick)
							@logger.puts("SUB " + nick + ": " + msg, @logger.messages())
						else
							@logger.puts(nick + ": " + msg, @logger.messages())
						end
						if msg[0] == "!"
							commands(nick, channel, msg)
						end
						@subs.delete(nick)
					elsif channel.downcase == @username
						if nick == "jtv"
							info = msg.split(" ")
							case(info[0])
							when "SPECIALUSER"
								if info[2] == "subscriber"
									@subs.add(info[1])
								end
							end
						else
							@logger.puts("PRIV: " + nick + ": " + msg, @logger.messages())
						end
					end
				when "353"
					channel = baseTriple[2].split(' :', 2)[0].split(' = ', 2)[1]
					if channel.downcase == @channel
						@logger.puts("USERS: " + data.split(@channel + ' :', 2)[1], @logger.joins())
					end
				when "PART"
					nick = data.split('!', 2)[0][1..-1]
					channel = baseTriple[2].split(' :', 2)[0]
					if channel.downcase == @channel
						@subs.delete(nick)
						@logger.puts("PART: " + nick, @logger.joins())
					end
				when "JOIN"
					nick = data.split('!', 2)[0][1..-1]
					channel = baseTriple[2].split(' :', 2)[0]
					if channel.downcase == @channel
						@logger.puts("JOIN: " + nick, @logger.joins())
					end
				else
					#puts data
				end
			end
		end
		@messager.stop
		@logger.close()
	end
end


# Start everything
Settings.load!("config.yaml")
bot = Chocobot.new()
bot.main()