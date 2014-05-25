require './Models/TimedEvent.rb'
require './Command.rb'

class Timer

	attr_accessor :run, :messager

	def self.getInstance(messager = nil, logger = nil)
		if @instance == nil
			@instance = Timer.new(messager, logger)
		end
		return @instance
	end

	def initialize(messager, logger)
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
		entry = TimedEvent.get(name)
		entry.destroy() if entry != nil
	end

	def newMsg()
		@msgCount += 1
	end

	def timerList()
		names = []
		TimedEvent.all.each do |timerEvent|
			names << timerEvent.name
		end
		return names
	end

	def self.addPlugin(pluginLoader)
		pluginLoader.addNewMsg(self)
		pluginLoader.addCommand(Command.new("!timeradd", lambda do |data, priv|
			if priv <= 10
				getInstance.add(data[0], data[3..-1].join(" "), data[1].to_i, data[2].to_i)
				getInstance.messager.message("Timer " + data[0] + " wurde gesetzt mit dem Zeitintervall " + data[1].to_i.to_s + " Minute(n) und dem Nachrichtenintervall " + data[2].to_i.to_s + ".")
				return true
			end
			return false
		end))
		pluginLoader.addCommand(Command.new("!timerrem", lambda do |data, priv|
			if priv <= 10
				getInstance.remove(data[0])
				getInstance.messager.message("Timer " + data[0] + " wurde entfernt.")
				return true
			end
			return false
		end))
		pluginLoader.addCommand(Command.new("!timerlist", lambda do |data, priv|
			if priv <= 10
				getInstance.messager.message("Folgende Timer sind installiert: " + getInstance.timerList().join(" "))
				return true
			end
			return false
		end))
	end
end