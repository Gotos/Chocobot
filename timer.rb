require './Models/TimedEvent.rb'

class Timer

	attr_accessor :run

	def initialize(messager)
		@messager = messager
		@msgCount = 0
		@time = 0
		@run = true

		TimedEvent.all.each do |timerEvent|
			timerEvent.t = 0
			timerEvent.mc = 0
			timerEvent.save
		end

		Thread.new do
			while @run
				TimedEvent.all.each do |timerEvent|
					if timerEvent.time + timerEvent.t <= @time
						timerEvent.t = @time
						if timerEvent.messagesPassed + timerEvent.mc <= @msgCount
							timerEvent.mc = @msgCount
							messager.message(timerEvent.msg)
						end
					end
					timerEvent.save
				end
				sleep(60)
				@time += 1
			end
		end
	end

	def add(name, msg, time, messagesPassed)
		TimedEvent.create(:name => name, :msg => msg, :time => time, :messagesPassed => messagesPassed, :t => time, :mc => messagesPassed)
	end

	def remove(name)
		TimedEvent.get(name).destroy()
	end

	def newMsg()
		@msgCount += 1
	end
end

#class TimedEvent
#
#	attr_reader :msg, :time, :messagesPassed
#	attr_accessor :t, :mc
#
#	def initialize(msg, time, messagesPassed)
#		@msg = msg
#		@time = time
#		@messagesPassed = messagesPassed
#		@t = -1
#		@mc = -1
#	end
#end
