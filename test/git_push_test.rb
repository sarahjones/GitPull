# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'git_push'

class GitPushTest < Test::Unit::TestCase
  should "fail miserably" do
    assert false, "Yay!"
  end
end
