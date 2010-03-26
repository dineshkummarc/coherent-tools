module Coherent
  module Commands
    
    class Unsource
      def initialize(base_command)
        @base_command = base_command
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} unsource URI [URI [URI]...]"
          o.define_head "Remove repositories from the default search list."
          o.separator ""
          o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
        end
      end
    
      def parse!(args)
        options.parse!(args)
        count = 0
        args.each do |uri|
          if Repositories.instance.remove(uri)
            count += 1
            puts "removed: #{uri.ljust(50)}"
          else
            puts "failed: #{uri.ljust(50)}"
          end
        end
        Repositories.instance.save
        puts "Removed #{count} repositories."
      end
    end

  end
end