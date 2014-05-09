class Timer

	attr_accessor :run

	def initialize(messager)
		@messager = messager
		@msgCount = 0
		@time = 0
		@run = true
		@timers = {}
		@timers_mutex = Mutex.new

		Thread.new do
			while @run
				@timers_mutex.synchronize do
					@timers.each_value do |timerEvent|
						if timerEvent.time + timerEvent.t <= @time
							timerEvent.t = @time
							if timerEvent.messagesPassed + timerEvent.mc <= @msgCount
								timerEvent.mc = @msgCount
								messager.message(timerEvent.msg)
							end
						end
					end
				end
				sleep(60)
				@time += 1
			end
		end
	end

	def add(name, msg, time, messagesPassed)
		@timers_mutex.synchronize do
			@timers[name] = TimedEvent.new(msg, time, messagesPassed)
		end
	end

	def remove(name)
		@timers_mutex.synchronize do
			@timers.delete(name)
		end
	end

	def newMsg()
		@msgCount += 1
	end
end

class TimedEvent

	attr_reader :msg, :time, :messagesPassed
	attr_accessor :t, :mc

	def initialize(msg, time, messagesPassed)
		@msg = msg
		@time = time
		@messagesPassed = messagesPassed
		@t = -1
		@mc = -1
	end
end
