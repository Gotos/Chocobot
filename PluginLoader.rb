require './Command.rb'

class PluginLoader

	@@plugins = {}
	@@preCommands = {}
	@@postCommands = {}
	@@commandIDs = {}
	@@newMsg = []
	@@random = Random.new

	def self.load()
		Dir.entries("Plugins").select do |f|
			if File.directory? File.join('Plugins',f) and !(f =='.' || f == '..')
				require "./Plugins/" + f + "/" + f + ".rb"
			end
		end
		for plugin in @@plugins.values
			plugin.addPlugin
		end
	end

	def self.boot(messager, logger)
		for plugin in @@plugins.values
			plugin.getInstance(messager, logger)
		end
		#Timer.getInstance(messager, logger)
	end

	def self.addCommand(cmd)
		if @@commandIDs.key?(cmd.cmd)
			return -1
		else
			@@postCommands[cmd.cmd] = cmd
			id = @@random.rand(2**16)
			@@commandIDs[cmd.cmd] = id
			return id
		end
	end

	def self.removeCommand(cmd, id)
		if @@commandIDs[cmd] == id and id >= 0
			@@postCommands.delete(cmd)
			@@preCommands.delete(cmd)
			@@commandIDs.delete(cmd)
			return true
		end
		return false
	end

	def self.addPreCommand(cmd)
		@@preCommands[cmd.cmd] = cmd
	end

	def self.addNewMsg(plugin)
		@@newMsg << plugin
	end

	def self.newMsg()
		for plugin in @@newMsg
			plugin.getInstance.newMsg()
		end
	end

	def self.registerPlugin(name, plugin)
		@@plugins[name] = plugin
	end

	def self.preCommands
		@@preCommands
	end

	def self.postCommands
		@@postCommands
	end
end