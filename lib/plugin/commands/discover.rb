module Coherent
  module Commands
    
    class Discover
      def initialize(base_command)
        @base_command = base_command
        @list = false
        @prompt = true
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} discover URI [URI [URI]...]"
          o.define_head "Discover repositories referenced on a page."
          o.separator   ""        
          o.separator   "Options:"
          o.separator   ""
          o.on(         "-l", "--list", 
                        "List but don't prompt or add discovered repositories.") { |list| @list, @prompt = list, !@list }
          o.on(         "-n", "--no-prompt", 
                        "Add all new repositories without prompting.") { |v| @prompt = !v }
        end
      end

      def parse!(args)
        options.parse!(args)
        args = ['http://wiki.rubyonrails.org/rails/pages/Plugins'] if args.empty?
        args.each do |uri|
          scrape(uri) do |repo_uri|
            catch(:next_uri) do
              if @prompt
                begin
                  $stdout.print "Add #{repo_uri}? [Y/n] "
                  throw :next_uri if $stdin.gets !~ /^y?$/i
                rescue Interrupt
                  $stdout.puts
                  exit 1
                end
              elsif @list
                puts repo_uri
                throw :next_uri
              end
              Repositories.instance.add(repo_uri)
              puts "discovered: #{repo_uri}" if $verbose or !@prompt
            end
          end
        end
        Repositories.instance.save
      end
    
      def scrape(uri)
        require 'open-uri'
        puts "Scraping #{uri}" if $verbose
        dupes = []
        content = open(uri).each do |line|
          begin
            if line =~ /<a[^>]*href=['"]([^'"]*)['"]/ || line =~ /(svn:\/\/[^<|\n]*)/
              uri = $1
              if uri =~ /^\w+:\/\// && uri =~ /\/plugins\// && uri !~ /\/browser\// && uri !~ /^http:\/\/wiki\.rubyonrails/ && uri !~ /http:\/\/instiki/
                uri = extract_repository_uri(uri)
                yield uri unless dupes.include?(uri) || Repositories.instance.exist?(uri)
                dupes << uri
              end
            end
          rescue
            puts "Problems scraping '#{uri}': #{$!.to_s}"
          end
        end
      end
    
      def extract_repository_uri(uri)
        uri.match(/(svn|https?):.*\/plugins\//i)[0]
      end 
    end

  end
end
