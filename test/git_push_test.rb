# To change this template, choose Tools | Templates
# and open the template in the editor.

#To run: ruby -I test test/git_push_test.rb 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'git_push'
require 'test_helper'

class GitPushTest < Test::Unit::TestCase

  context "when a GitPush is already in progress" do
    should "be detectable"
    should "git reset and restart"
  end
  
  
  context "status" do
    should "print properly" do
      git_status_output = 
        "# On branch master
# Your branch is ahead of 'origin/master' by 1 commit.
#
# Changes not staged for commit:
#   (use \"git add <file>...\" to update what will be committed)
#   (use \"git checkout -- <file>...\" to discard changes in working directory)
#
#	modified:   Gemfile
#	modified:   Gemfile.lock
#	modified:   lib/git_push.rb
#	modified:   test/git_push_test.rb
#	modified:   test/test_helper.rb
#
no changes added to commit (use \"git add\" and/or \"git commit -a\")\n"
      
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.twice
      GitPush.expects(:`).returns(git_status_output).once
      GitPush.status
      assert_equal  "Executing: git status\n#{git_status_output}", out
    end
  end
  
  context "add" do
    should "add all files "
    shoudl "verify that all files have been added"
  end
  
  context "commit" do
    should "commit all files"
    should "verify that the commit was successful"
  end
  
  context "pull"
  
  context "reset"
  
  should "execute status, commit, pull, reset, push" do
    GitPush.expects(:status).then.expects(:add).then.expects(:commit).then.expects(:pull).then.expects(:reset).then.expects(:push)
  end
end
