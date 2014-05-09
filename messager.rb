require 'thread'

class Messager

	attr_accessor :queue

	def initialize(irc, channel)
		@queue = Queue.new
		@irc = irc
		@channel = channel
		@stop = false
		@run = true
		Thread.new do
			while @run
				element = @queue.pop() rescue nil
				p "GOT HERE"
				p element
				if element != nil
					p "PRE"
					@irc.puts(element)
					p "POST"
					sleep(2)
				elsif @stop
					@run = false
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
		@queue << ("PRIVMSG " + @channel + " :" + msg)
	end

	def raw(msg)
		@queue << msg
	end

end