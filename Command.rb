class Command
	attr_reader :cmd

	def initialize(cmd, func)
		@cmd = cmd
		@run = func
	end

	def run(param, priv)
		@run.call(param, priv)
	end
end