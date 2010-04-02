module Coherent
  
  class Repositories
    include Enumerable
  
    def initialize(cache_file = File.join(find_home, ".coherent-plugin-sources"))
      @cache_file = File.expand_path(cache_file)
      load!
    end
  
    def each(&block)
      @repositories.each(&block)
    end
  
    def add(uri)
      unless find{|repo| repo.uri == uri }
        @repositories.push(Repository.new(uri)).last
      end
    end
  
    def remove(uri)
      @repositories.reject!{|repo| repo.uri == uri}
    end
  
    def exist?(uri)
      @repositories.detect{|repo| repo.uri == uri }
    end
  
    def all
      @repositories
    end
  
    def find_plugin(name)
      @repositories.each do |repo|
        repo.each do |plugin|
          return plugin if plugin.name == name
        end
      end
      return nil
    end
  
    def load!
      contents = File.exist?(@cache_file) ? File.read(@cache_file) : defaults
      contents = defaults if contents.empty?
      @repositories = contents.split(/\n/).reject do |line|
        line =~ /^\s*#/ or line =~ /^\s*$/
      end.map { |source| Repository.new(source.strip) }
    end
  
    def save
      File.open(@cache_file, 'w') do |f|
        each do |repo|
          f.write(repo.uri)
          f.write("\n")
        end
      end
    end
  
    def defaults
      <<-DEFAULTS
      http://coherent.googlecode.com/svn/plugins
      DEFAULTS
    end
 
    def find_home
      ['HOME', 'USERPROFILE'].each do |homekey|
        return ENV[homekey] if ENV[homekey]
      end
      if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
        return "#{ENV['HOMEDRIVE']}:#{ENV['HOMEPATH']}"
      end
      begin
        File.expand_path("~")
      rescue StandardError => ex
        if File::ALT_SEPARATOR
          "C:/"
        else
          "/"
        end
      end
    end

    def self.instance
      @instance ||= Repositories.new
    end
  
    def self.each(&block)
      self.instance.each(&block)
    end
  end

end
