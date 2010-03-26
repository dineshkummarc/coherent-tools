module Coherent
  
  class Plugin
    attr_reader :name, :uri
  
    def initialize(uri, name=nil)
      @uri = uri
      guess_name(uri)
    end
  
    def self.find(name)
      name =~ /\// ? new(name) : Repositories.instance.find_plugin(name)
    end
  
    def to_s
      "#{@name.ljust(30)}#{@uri}"
    end
  
    def svn_url?
      @uri =~ /svn(?:\+ssh)?:\/\/*/
    end
  
    def git_url?
      @uri =~ /^git:\/\// || @uri =~ /\.git$/
    end
  
    def installed?
      File.directory?("#{project_env.root}/vendor/plugins/#{name}") \
        or project_env.externals.detect{ |name, repo| self.uri == repo }
    end
  
    def install(method=nil, options = {})
      method ||= project_env.best_install_method?
      if :http == method
        method = :export if svn_url?
        method = :git    if git_url?
      end

      uninstall if installed? and options[:force]

      unless installed?
        send("install_using_#{method}", options)
        run_install_hook
      else
        puts "already installed: #{name} (#{uri}).  pass --force to reinstall"
      end
    end

    def uninstall
      path = "#{project_env.root}/vendor/plugins/#{name}"
      if File.directory?(path)
        puts "Removing 'vendor/plugins/#{name}'" if $verbose
        run_uninstall_hook
        rm_r path
      else
        puts "Plugin doesn't exist: #{path}"
      end
      # clean up svn:externals
      externals = project_env.externals
      externals.reject!{|n,u| name == n or name == u}
      project_env.externals = externals
    end

    def info
      tmp = "#{project_env.root}/_tmp_about.yml"
      if svn_url?
        cmd = "svn export #{@uri} \"#{project_env.root}/#{tmp}\""
        puts cmd if $verbose
        system(cmd)
      end
      open(svn_url? ? tmp : File.join(@uri, 'about.yml')) do |stream|
        stream.read
      end rescue "No about.yml found in #{uri}"
    ensure
      FileUtils.rm_rf tmp if svn_url?
    end

    private 

      def run_install_hook
        install_hook_file = "#{project_env.root}/vendor/plugins/#{name}/install.rb"
        load install_hook_file if File.exist? install_hook_file
      end

      def run_uninstall_hook
        uninstall_hook_file = "#{project_env.root}/vendor/plugins/#{name}/uninstall.rb"
        load uninstall_hook_file if File.exist? uninstall_hook_file
      end

      def install_using_export(options = {})
        svn_command :export, options
      end
    
      def install_using_checkout(options = {})
        svn_command :checkout, options
      end
    
      def install_using_externals(options = {})
        externals = project_env.externals
        externals.push([@name, uri])
        project_env.externals = externals
        install_using_checkout(options)
      end

      def install_using_http(options = {})
        root = project_env.root
        mkdir_p "#{root}/vendor/plugins/#{@name}"
        Dir.chdir "#{root}/vendor/plugins/#{@name}" do
          puts "fetching from '#{uri}'" if $verbose
          fetcher = RecursiveHTTPFetcher.new(uri, -1)
          fetcher.quiet = true if options[:quiet]
          fetcher.fetch
        end
      end
    
      def install_using_git(options = {})
        root = project_env.root
        mkdir_p(install_path = "#{root}/vendor/plugins/#{name}")
        Dir.chdir install_path do
          init_cmd = "git init"
          init_cmd += " -q" if options[:quiet] and not $verbose
          puts init_cmd if $verbose
          system(init_cmd)
          base_cmd = "git pull --depth 1 #{uri}"
          base_cmd += " -q" if options[:quiet] and not $verbose
          base_cmd += " #{options[:revision]}" if options[:revision]
          puts base_cmd if $verbose
          if system(base_cmd)
            puts "removing: .git .gitignore" if $verbose
            rm_rf %w(.git .gitignore)
          else
            rm_rf install_path
          end
        end
      end

      def svn_command(cmd, options = {})
        root = project_env.root
        mkdir_p "#{root}/vendor/plugins"
        base_cmd = "svn #{cmd} #{uri} \"#{root}/vendor/plugins/#{name}\""
        base_cmd += ' -q' if options[:quiet] and not $verbose
        base_cmd += " -r #{options[:revision]}" if options[:revision]
        puts base_cmd if $verbose
        system(base_cmd)
      end

      def guess_name(url)
        @name = File.basename(url)
        if @name == 'trunk' || @name.empty?
          @name = File.basename(File.dirname(url))
        end
        @name.gsub!(/\.git$/, '') if @name =~ /\.git$/
      end
    
      def project_env
        @project_env || Coherent::Environment.default
      end
  end

end
