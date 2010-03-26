module Coherent
  module Commands
    
    
    class Remove
      def initialize(base_command)
        @base_command = base_command
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} remove name [name]..."
          o.define_head "Remove plugins."
        end
      end
    
      def parse!(args)
        options.parse!(args)
        root = @base_command.environment.root
        args.each do |name|
          Coherent::Plugin.new(name).uninstall
        end
      end
    end


  end
end
