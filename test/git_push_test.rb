# To change this template, choose Tools | Templates
# and open the template in the editor.

#To run: ruby -I test test/git_push_test.rb 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'git_push'
require 'test_helper'

class GitPushTest < Test::Unit::TestCase

  STATUS_NORMAL = 
    "# On branch master
# Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#	modified:   lib/git_push.rb
#	modified:   test/git_push_test.rb
#
"
  
  STATUS_UNTRACKED_FILES =         
    "# On branch master
# Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#	modified:   lib/git_push.rb
#	modified:   test/git_push_test.rb
#
# Untracked files:
#   (use \"git add <file>...\" to include in what will be committed)
#
#	out.txt
"

  STATUS_TRACKED_FILES = 
  "# On branch master
# Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#	modified:   lib/git_push.rb
#	modified:   test/git_push_test.rb
#
# Changes not staged for commit:
#   (use \"git add <file>...\" to update what will be committed)
#   (use \"git checkout -- <file>...\" to discard changes in working directory)
#
#	modified:   lib/git_push.rb
#	modified:   test/git_push_test.rb
#"
  
  STATUS_AFTER_COMMIT =
  "# On branch master
# Your branch is ahead of 'origin/master' by 1 commit.
#
nothing to commit (working directory clean)
"
  
  COMMIT = 
    "[master 6eac534] GitPush Temporary Commit
 2 files changed, 110 insertions(+), 23 deletions(-)
  "
  
  COMMIT_WITH_ERRORS = 
    "Aborting due to empty commit message
Error: Aborting commit due to empty message.
"
  
  context "when a GitPush is already in progress" do
    should "be detectable"
    should "git reset and restart"
  end
  
  context "git_push" do
    should "exit if add returns false" do
      GitPush.expects(:commit).never
      GitPush.expects(:pull).never
      GitPush.expects(:reset).never
      GitPush.expects(:push).never
      assert false, "Not finished"
    end
    
    should "execute status, commit, pull, reset, push" do
      GitPush.expects(:status).then.expects(:add).then.expects(:commit).then.expects(:pull).then.expects(:reset).then.expects(:push)
      GitPush.git_push
      assert false, "Not finished"
    end
  end
  
  
  context "status" do
    should "print properly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.twice
      GitPush.expects(:`).with("git status").returns(STATUS_TRACKED_FILES).once
      
      GitPush.status
      
      assert_equal  "Executing: git status\n#{STATUS_TRACKED_FILES}", out
    end
  end
  
  context "add" do
    should "add all files " do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.twice
      GitPush.expects(:`).with("git add .").returns("").once
      GitPush.expects(:`).with("git status").returns(STATUS_NORMAL).once
      assert GitPush.add
      assert_equal "Executing: git add .\n", out
    end
    should "return false if not all untracked files were added correctly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.times(3)
      GitPush.expects(:`).with("git add .").returns("").once
      GitPush.expects(:`).with("git status").returns(STATUS_UNTRACKED_FILES).once
      
      assert_equal false, GitPush.add
      
      assert_equal "Executing: git add .\nError: not all files were added\nExiting...", out
    end
    
    should "return false if not all tracked files were added correctly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.times(3)
      GitPush.expects(:`).with("git add .").returns("").once
      GitPush.expects(:`).with("git status").returns(STATUS_TRACKED_FILES).once
      
      assert_equal false, GitPush.add
      
      assert_equal "Executing: git add .\nError: not all files were added\nExiting...", out
    end
    
  end
  
  context "commit" do
    should "commit all files" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.times(3)
      GitPush.expects(:`).with("git commit -m \"GitPush Temporary Commit\"").returns(COMMIT).once
      GitPush.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPush.commit
      assert_equal "Executing: git commit -m \"GitPush Temporary Commit\"\n#{COMMIT}#{STATUS_AFTER_COMMIT}", out
    end
    should "return false if the commit was unsuccessful" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << s }.times(4)
      GitPush.expects(:`).with("git commit -m \"GitPush Temporary Commit\"").returns(COMMIT_WITH_ERRORS).once
      GitPush.expects(:`).with("git status").returns(STATUS_NORMAL).once
      assert_equal false, GitPush.commit
      assert_equal "Executing: git commit -m \"GitPush Temporary Commit\"\n#{COMMIT_WITH_ERRORS}#{STATUS_NORMAL}Error: Commit failed\nExiting...", out
    end
  end
  
  context "pull" do
    should "pull files"
    
    should "return false if merge conflict"
    
    should "return false if other error"
  end
  
  context "reset"
  
  
  context "verbosity off"

end
