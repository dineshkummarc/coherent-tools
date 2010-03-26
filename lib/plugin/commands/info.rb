module Coherent
  module Commands
    

    class Info
      def initialize(base_command)
        @base_command = base_command
      end

      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} info name [name]..."
          o.define_head "Shows plugin info at {url}/about.yml."
        end
      end

      def parse!(args)
        options.parse!(args)
        args.each do |name|
          puts ::Plugin.find(name).info
          puts
        end
      end
    end


  end
end
