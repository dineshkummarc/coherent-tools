module Coherent
  module Commands
    
    class Source
      def initialize(base_command)
        @base_command = base_command
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} source REPOSITORY [REPOSITORY [REPOSITORY]...]"
          o.define_head "Add new repositories to the default search list."
        end
      end
    
      def parse!(args)
        options.parse!(args)
        count = 0
        args.each do |uri|
          if Repositories.instance.add(uri)
            puts "added: #{uri.ljust(50)}" if $verbose
            count += 1
          else
            puts "failed: #{uri.ljust(50)}"
          end
        end
        Repositories.instance.save
        puts "Added #{count} repositories."
      end
    end

  end
end
