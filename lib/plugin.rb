# This is the coherent plugin manager and was adapted from the Rails plugin
# manager by Ryan Tomayko (rtomayko@gmail.com).
# 
# Listing available plugins:
#
#   $ ./script/plugin list
#   continuous_builder            http://dev.rubyonrails.com/svn/rails/plugins/continuous_builder
#   asset_timestamping            http://svn.aviditybytes.com/rails/plugins/asset_timestamping
#   enumerations_mixin            http://svn.protocool.com/rails/plugins/enumerations_mixin/trunk
#   calculations                  http://techno-weenie.net/svn/projects/calculations/
#   ...
#
# Installing plugins:
#
#   $ ./script/plugin install continuous_builder asset_timestamping
#
# Finding Repositories:
#
#   $ ./script/plugin discover
# 
# Adding Repositories:
#
#   $ ./script/plugin source http://svn.protocool.com/rails/plugins/
#
# How it works:
# 
#   * Maintains a list of subversion repositories that are assumed to have
#     a plugin directory structure. Manage them with the (source, unsource,
#     and sources commands)
#     
#   * The discover command scrapes the following page for things that
#     look like subversion repositories with plugins:
#     http://wiki.rubyonrails.org/rails/pages/Plugins
# 
#   * Unless you specify that you want to use svn, script/plugin uses plain old
#     HTTP for downloads.  The following bullets are true if you specify
#     that you want to use svn.
#
#   * If `vendor/plugins` is under subversion control, the script will
#     modify the svn:externals property and perform an update. You can
#     use normal subversion commands to keep the plugins up to date.
# 
#   * Or, if `vendor/plugins` is not under subversion control, the
#     plugin is pulled via `svn checkout` or `svn export` but looks
#     exactly the same.
# 
# Specifying revisions:
#
#   * Subversion revision is a single integer.
#
#   * Git revision format:
#     - full - 'refs/tags/1.8.0' or 'refs/heads/experimental'
#     - short: 'experimental' (equivalent to 'refs/heads/experimental')
#              'tag 1.8.0' (equivalent to 'refs/tags/1.8.0')
#
#
# This is Free Software, copyright 2005 by Ryan Tomayko (rtomayko@gmail.com) 
# and is licensed MIT: (http://www.opensource.org/licenses/mit-license.php)




require 'open-uri'
require 'fileutils'
require 'tempfile'

include FileUtils

LIB_DIR = File.dirname(__FILE__)
$:.unshift(LIB_DIR)

$verbose = false

require 'plugin/commands'
require 'plugin/environment'
require 'plugin/plugin'
require 'plugin/recursive-http-fetcher'
require 'plugin/repositories'
require 'plugin/repository'

require 'plugin/commands'


