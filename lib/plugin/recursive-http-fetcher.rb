module Coherent
   
  class RecursiveHTTPFetcher
    attr_accessor :quiet
    def initialize(urls_to_fetch, level = 1, cwd = ".")
      @level = level
      @cwd = cwd
      @urls_to_fetch = RUBY_VERSION >= '1.9' ? urls_to_fetch.lines : urls_to_fetch.to_a
      @quiet = false
    end

    def ls
      @urls_to_fetch.collect do |url|
        if url =~ /^svn(\+ssh)?:\/\/.*/ || url =~ /\/svn\//
          `svn ls #{url}`.split("\n").map {|entry| "/#{entry}"} rescue nil
        else
          open(url) do |stream|
            links("", stream.read)
          end rescue nil
        end
      end.flatten
    end

    def push_d(dir)
      @cwd = File.join(@cwd, dir)
      FileUtils.mkdir_p(@cwd)
    end

    def pop_d
      @cwd = File.dirname(@cwd)
    end

    def links(base_url, contents)
      links = []
      contents.scan(/href\s*=\s*\"*[^\">]*/i) do |link|
        link = link.sub(/href="/i, "")
        next if link =~ /svnindex.xsl$/
        next if link =~ /^(\w*:|)\/\// || link =~ /^\./
        links << File.join(base_url, link)
      end
      links
    end
  
    def download(link)
      puts "+ #{File.join(@cwd, File.basename(link))}" unless @quiet
      open(link) do |stream|
        File.open(File.join(@cwd, File.basename(link)), "wb") do |file|
          file.write(stream.read)
        end
      end
    end
  
    def fetch(links = @urls_to_fetch)
      links.each do |l|
        (l =~ /\/$/ || links == @urls_to_fetch) ? fetch_dir(l) : download(l)
      end
    end
  
    def fetch_dir(url)
      @level += 1
      push_d(File.basename(url)) if @level > 0
      open(url) do |stream|
        contents =  stream.read
        fetch(links(url, contents))
      end
      pop_d if @level > 0
      @level -= 1
    end
  end

end