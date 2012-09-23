# To change this template, choose Tools | Templates
# and open the template in the editor.

#To run: ruby -I test test/git_pull_test.rb 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'git_pull'
require 'test_helper'

class GitPullTest < Test::Unit::TestCase

  STATUS_NORMAL = 
    "# On branch master
# Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#	modified:   lib/git_pull.rb
#	modified:   test/git_pull_test.rb
#"
  
  STATUS_UNTRACKED_FILES =         
    "# On branch master
# Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#	modified:   lib/git_pull.rb
#	modified:   test/git_pull_test.rb
#
# Untracked files:
#   (use \"git add <file>...\" to include in what will be committed)
#
#	out.txt"

  STATUS_TRACKED_FILES = 
  "# On branch master
# Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#	modified:   lib/git_pull.rb
#	modified:   test/git_pull_test.rb
#
# Changes not staged for commit:
#   (use \"git add <file>...\" to update what will be committed)
#   (use \"git checkout -- <file>...\" to discard changes in working directory)
#
#	modified:   lib/git_pull.rb
#	modified:   test/git_pull_test.rb
#"
  
  STATUS_AFTER_COMMIT =
  "# On branch master
# Your branch is ahead of 'origin/master' by 1 commit.
#
nothing to commit (working directory clean)"
  
  STATUS_AFTER_PULL_MERGE_CONFLICT =
    "  # Changes to be committed:
#   (use \"git reset HEAD <file>...\" to unstage)
#
#    modified:   bogus_file.rb
#
# Changed but not updated:
#   (use \"git add <file>...\" to update what will be committed)
#   (use \"git checkout -- <file>...\" to discard changes in working directory)
#
#     unmerged:   bogus_file2.rb
#"  
  
  STATUS_AFTER_RESET =
    "# On branch master
# Changes not staged for commit:
#   (use \"git add <file>...\" to update what will be committed)
#   (use \"git checkout -- <file>...\" to discard changes in working directory)
#
#	modified:   lib/git_pull.rb
#	modified:   test/git_pull_test.rb
#"
  
  COMMIT = 
    "[master 6eac534] GitPull Temporary Commit
 2 files changed, 110 insertions(+), 23 deletions(-)"
  
  COMMIT_WITH_ERRORS = 
    "Aborting due to empty commit message
Error: Aborting commit due to empty message."

  PULL = 
    "remote: Counting objects: 92, done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 51 (delta 39), reused 47 (delta 35)
Unpacking objects: 100% (51/51), done.
From github.com:GitPull/dir
   c9bdc2a..3456d5c  branch1/branchA -> origin/branch1/branchA
   0e0a63f..4baca13  branch2 -> origin/branch2
 * [new branch]      branch3 -> origin/branch3
   338eb82..12b84de  master     -> origin/master
 * [new branch]      branch4 -> origin/branch4"
  PULL_MERGE_CONFLICT =
    "CONFLICT (content): Merge conflict in lib/bogus_file.rb
Automatic merge failed; fix conflicts and then commit the result."
  
  HASH = "f4bad36116f8b0557059c1cb2e581afac7694958"
  
  LOG_WITHOUT_TEMPORARY_COMMIT =
    "commit #{HASH}
Author: My Name <my_name@gmail.com>
Date:   Sat Sep 8 16:11:41 2012 -0700

    Add and commit

commit cd76809cee49cd668f4492b465bcc75b4a3a2f3e
Author: My Name <my_name@gmail.com>
Date:   Sat Sep 8 14:25:05 2012 -0700

    Tests framework setup. Added status."

  LOG =
    "commit 3edfbfae71bac9b7ee466c89771bd85feae42d6c
Author: My Name <my_name@gmail.com>
Date:   Sat Sep 8 17:35:42 2012 -0700

    #{GitPull::COMMIT_MESSAGE}

#{LOG_WITHOUT_TEMPORARY_COMMIT}"
  
  LOG_WITH_MULTIPLE_TEMPORARY_COMMITS =
    "#{LOG}

commit 3edfbfae71bac9b7ee466c89771bd85feae44444
Author: My Name <my_name@gmail.com>
Date:   Sat Sep 8 16:11:41 2012 -0700

    #{GitPull::COMMIT_MESSAGE}

commit cd76809cee49cd668f4492b465bcc75b4a344444
Author: My Name <my_name@gmail.com>
Date:   Sat Sep 8 14:25:05 2012 -0700

    Tests framework setup. Added status."
  
  
  RESET = 
    "Unstaged changes after reset:
M	lib/git_pull.rb
M	test/git_pull_test.rb"
  

  context "when a GitPull is already in progress" do
    should "be detectable"
    should "git reset and restart"
  end
  
  context "git_pull" do
    should "exit if reset returns false" do
      GitPull.expects(:add).returns(true)
      GitPull.expects(:commit).returns(true)
      GitPull.expects(:pull).returns(true)
      GitPull.expects(:reset).returns(false).once
      
      GitPull.expects(:push).never
      GitPull.git_pull
    end
    
    should "exit if pull returns false" do
      GitPull.expects(:add).returns(true)
      GitPull.expects(:commit).returns(true)
      GitPull.expects(:pull).returns(false)
      
      GitPull.expects(:reset).never
      GitPull.expects(:push).never
      GitPull.git_pull
    end
    
    should "exit if commit returns false" do
      GitPull.expects(:add).returns(true)
      GitPull.expects(:commit).returns(false)
      
      GitPull.expects(:pull).never
      GitPull.expects(:reset).never
      GitPull.expects(:push).never
      GitPull.git_pull
    end
    
    should "exit if add returns false" do
      GitPull.expects(:add).returns(false)
      
      GitPull.expects(:commit).never
      GitPull.expects(:pull).never
      GitPull.expects(:reset).never
      GitPull.expects(:push).never
      GitPull.git_pull
    end
    
    should "execute status, commit, pull, reset" do
      GitPull.expects(:add).returns(true) #.then.expects(:commit).returns(true).then.expects(:pull).returns(true).then.expects(:reset).returns(true).then.expects(:push).returns(true)
      GitPull.expects(:commit).returns(true)
      GitPull.expects(:pull).returns(true)
      GitPull.expects(:reset).returns(true)
      GitPull.expects(:push).never
      GitPull.git_pull
    end
    
    should "skip temporary commit if there is nothing to commit"
  end
  
  
  context "status" do
    should "print properly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.twice
      GitPull.expects(:`).with("git status").returns(STATUS_TRACKED_FILES).once
      
      GitPull.status
      
      assert_equal  "Executing: git status\n#{STATUS_TRACKED_FILES}\n", out
    end
  end
  
  context "add" do
    should "add all files " do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.twice
      GitPull.expects(:`).with("git add .").returns("").once
      GitPull.expects(:`).with("git status").returns(STATUS_NORMAL).once
      assert GitPull.add
      assert_equal "Executing: git add .\n\n", out
    end
    should "return false if not all untracked files were added correctly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(3)
      GitPull.expects(:`).with("git add .").returns("").once
      GitPull.expects(:`).with("git status").returns(STATUS_UNTRACKED_FILES).once
      
      assert_equal false, GitPull.add
      
      assert_equal "Executing: git add .\n\nError: not all files were added\nExiting...\n", out
    end
    
    should "return false if not all tracked files were added correctly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(3)
      GitPull.expects(:`).with("git add .").returns("").once
      GitPull.expects(:`).with("git status").returns(STATUS_TRACKED_FILES).once
      
      assert_equal false, GitPull.add
      
      assert_equal "Executing: git add .\n\nError: not all files were added\nExiting...\n", out
    end
    
  end
  
  context "commit" do
    should "commit all files" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(3)
      GitPull.expects(:`).with("git commit -m \"GitPull Temporary Commit\"").returns(COMMIT).once
      GitPull.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPull.commit
      assert_equal "Executing: git commit -m \"GitPull Temporary Commit\"\n#{COMMIT}\n#{STATUS_AFTER_COMMIT}\n", out
    end
    should "return false if the commit was unsuccessful" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(4)
      GitPull.expects(:`).with("git commit -m \"GitPull Temporary Commit\"").returns(COMMIT_WITH_ERRORS).once
      GitPull.expects(:`).with("git status").returns(STATUS_NORMAL).once
      assert_equal false, GitPull.commit
      assert_equal "Executing: git commit -m \"GitPull Temporary Commit\"\n#{COMMIT_WITH_ERRORS}\n#{STATUS_NORMAL}\nError: Commit failed\nExiting...\n", out
    end
  end
  
  context "pull" do
    should "pull files" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPull.expects(:`).with("git pull").returns(PULL).once
      GitPull.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPull.pull
      assert_equal "Executing: git pull\n#{PULL}\n#{STATUS_AFTER_COMMIT}\n", out
    end
    
    should "succeed if up to date" do
      
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPull.expects(:`).with("git pull").returns("Already up-to-date.").once
      GitPull.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPull.pull
      assert_equal "Executing: git pull\n#{"Already up-to-date."}\n#{STATUS_AFTER_COMMIT}\n", out
    end
    
    should "return false if merge conflict" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPull.expects(:`).with("git pull").returns(PULL_MERGE_CONFLICT).once
      GitPull.expects(:`).with("git status").returns(STATUS_AFTER_PULL_MERGE_CONFLICT).once
      assert_equal false, GitPull.pull
      assert_equal "Executing: git pull\n#{PULL_MERGE_CONFLICT}\n#{STATUS_AFTER_PULL_MERGE_CONFLICT}\nError: Merge Conflicts\nYour 'GitPull Temporary Commit' is still committed.  Exiting...\n", out
    end
    
    should "return false if other error" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPull.expects(:`).with("git pull").returns(PULL).once #Not sure what error message would look like
      GitPull.expects(:`).with("git status").returns(STATUS_AFTER_PULL_MERGE_CONFLICT).once
      assert_equal false, GitPull.pull
      assert_equal "Executing: git pull\n#{PULL}\n#{STATUS_AFTER_PULL_MERGE_CONFLICT}\nError: Unknown Error.  There are untracked files in your status.\nYour 'GitPull Temporary Commit' is still committed.  Exiting...\n", out
     
    end
  end
  
  context "reset" do 
    should "find first hash after the temporary commit message" do
      GitPull.expects(:`).with("git log").returns(LOG).once
      assert_equal HASH, GitPull.find_reset_hash
    end
    
    should "find the first temporary commit message" do
      GitPull.expects(:`).with("git log").returns(LOG_WITH_MULTIPLE_TEMPORARY_COMMITS).once
      assert_equal HASH, GitPull.find_reset_hash
    end
    
    should "return nil if cannot find temporary commit message" do
      GitPull.expects(:`).with("git log").returns(LOG_WITHOUT_TEMPORARY_COMMIT).once
      assert_nil GitPull.find_reset_hash
    end
    
    should "undo 'Temporary Commit'" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPull.expects(:`).with("git log").returns(LOG).once
      GitPull.expects(:`).with("git reset #{HASH}").returns(RESET).once
      assert GitPull.reset
      assert_equal "Executing: git reset #{HASH}\n#{RESET}\n", out
    end
    
    should "print message and return if nothing to undo" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPull.expects(:find_reset_hash).returns(nil)
      GitPull.expects(:`).with("git reset #{/.*/}").never
      assert_equal false, GitPull.reset
      assert_equal "'GitPull Temporary Commit' not found.  Check git log or git reflog, maybe?\n", out
    end
  end
  
  context "verbosity off"

end
