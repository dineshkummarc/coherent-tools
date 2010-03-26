module Coherent
  module Commands  
  
    class List
      def initialize(base_command)
        @base_command = base_command
        @sources = []
        @local = false
        @remote = true
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} list [OPTIONS] [PATTERN]"
          o.define_head "List available plugins."
          o.separator   ""        
          o.separator   "Options:"
          o.separator   ""
          o.on(         "-s", "--source=URL1,URL2", Array,
                        "Use the specified plugin repositories.") {|sources| @sources = sources}
          o.on(         "--local", 
                        "List locally installed plugins.") {|local| @local, @remote = local, false}
          o.on(         "--remote",
                        "List remotely available plugins. This is the default behavior",
                        "unless --local is provided.") {|remote| @remote = remote}
        end
      end
    
      def parse!(args)
        options.order!(args)
        unless @sources.empty?
          @sources.map!{ |uri| Repository.new(uri) }
        else
          @sources = Repositories.instance.all
        end
        if @remote
          @sources.map{|r| r.plugins}.flatten.each do |plugin| 
            if @local or !plugin.installed?
              puts plugin.to_s
            end
          end
        else
          cd "#{@base_command.environment.root}/vendor/plugins"
          Dir["*"].select{|p| File.directory?(p)}.each do |name| 
            puts name
          end
        end
      end
    end



  end
end
