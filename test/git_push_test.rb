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
#"
  
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
#	out.txt"

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
#	modified:   lib/git_push.rb
#	modified:   test/git_push_test.rb
#"
  
  COMMIT = 
    "[master 6eac534] GitPush Temporary Commit
 2 files changed, 110 insertions(+), 23 deletions(-)"
  
  COMMIT_WITH_ERRORS = 
    "Aborting due to empty commit message
Error: Aborting commit due to empty message."

  PULL = 
    "remote: Counting objects: 92, done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 51 (delta 39), reused 47 (delta 35)
Unpacking objects: 100% (51/51), done.
From github.com:GitPush/dir
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

    GitPush: Temporary Commit

#{LOG_WITHOUT_TEMPORARY_COMMIT}"
  
  
  RESET = 
    "Unstaged changes after reset:
M	lib/git_push.rb
M	test/git_push_test.rb"
  
  PUSH =
    "Counting objects: 11, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 3.21 KiB, done.
Total 6 (delta 2), reused 0 (delta 0)
To git@github.com:sarahjones/GitPush.git
   f4bcd36..501ce5d  master -> master"
  
  PUSH_OUT_OF_DATE =
    "To user@remote.net:/home/user/repos/remoterepo.git
 ! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to 'user@remote:/home/user/repos/remoterepo.git'
To prevent you from losing history, non-fast-forward updates were rejected
Merge the remote changes (e.g. 'git pull') before pushing again.  See the
'Note about fast-forwards' section of 'git push --help' for details."

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
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.twice
      GitPush.expects(:`).with("git status").returns(STATUS_TRACKED_FILES).once
      
      GitPush.status
      
      assert_equal  "Executing: git status\n#{STATUS_TRACKED_FILES}\n", out
    end
  end
  
  context "add" do
    should "add all files " do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.twice
      GitPush.expects(:`).with("git add .").returns("").once
      GitPush.expects(:`).with("git status").returns(STATUS_NORMAL).once
      assert GitPush.add
      assert_equal "Executing: git add .\n\n", out
    end
    should "return false if not all untracked files were added correctly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(3)
      GitPush.expects(:`).with("git add .").returns("").once
      GitPush.expects(:`).with("git status").returns(STATUS_UNTRACKED_FILES).once
      
      assert_equal false, GitPush.add
      
      assert_equal "Executing: git add .\n\nError: not all files were added\nExiting...\n", out
    end
    
    should "return false if not all tracked files were added correctly" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(3)
      GitPush.expects(:`).with("git add .").returns("").once
      GitPush.expects(:`).with("git status").returns(STATUS_TRACKED_FILES).once
      
      assert_equal false, GitPush.add
      
      assert_equal "Executing: git add .\n\nError: not all files were added\nExiting...\n", out
    end
    
  end
  
  context "commit" do
    should "commit all files" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(3)
      GitPush.expects(:`).with("git commit -m \"GitPush Temporary Commit\"").returns(COMMIT).once
      GitPush.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPush.commit
      assert_equal "Executing: git commit -m \"GitPush Temporary Commit\"\n#{COMMIT}\n#{STATUS_AFTER_COMMIT}\n", out
    end
    should "return false if the commit was unsuccessful" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.times(4)
      GitPush.expects(:`).with("git commit -m \"GitPush Temporary Commit\"").returns(COMMIT_WITH_ERRORS).once
      GitPush.expects(:`).with("git status").returns(STATUS_NORMAL).once
      assert_equal false, GitPush.commit
      assert_equal "Executing: git commit -m \"GitPush Temporary Commit\"\n#{COMMIT_WITH_ERRORS}\n#{STATUS_NORMAL}\nError: Commit failed\nExiting...\n", out
    end
  end
  
  context "pull" do
    should "pull files" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git pull").returns(PULL).once
      GitPush.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPush.pull
      assert_equal "Executing: git pull\n#{PULL}\n#{STATUS_AFTER_COMMIT}\n", out
    end
    
    should "succeed if up to date" do
      
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git pull").returns("Already up-to-date.").once
      GitPush.expects(:`).with("git status").returns(STATUS_AFTER_COMMIT).once
      assert GitPush.pull
      assert_equal "Executing: git pull\n#{"Already up-to-date."}\n#{STATUS_AFTER_COMMIT}\n", out
    end
    
    should "return false if merge conflict" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git pull").returns(PULL_MERGE_CONFLICT).once
      GitPush.expects(:`).with("git status").returns(STATUS_AFTER_PULL_MERGE_CONFLICT).once
      assert_equal false, GitPush.pull
      assert_equal "Executing: git pull\n#{PULL_MERGE_CONFLICT}\n#{STATUS_AFTER_PULL_MERGE_CONFLICT}\nError: Merge Conflicts\nYour 'GitPush Temporary Commit' is still committed.  Exiting...\n", out
    end
    
    should "return false if other error" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git pull").returns(PULL).once #Not sure what error message would look like
      GitPush.expects(:`).with("git status").returns(STATUS_AFTER_PULL_MERGE_CONFLICT).once
      assert_equal false, GitPush.pull
      assert_equal "Executing: git pull\n#{PULL}\n#{STATUS_AFTER_PULL_MERGE_CONFLICT}\nError: Unknown Error.  There are untracked files in your status.\nYour 'GitPush Temporary Commit' is still committed.  Exiting...\n", out
     
    end
  end
  
  context "reset" do 
    should "find first hash after the temporary commit message" do
      GitPush.expects(:`).with("git log").returns(LOG).once
      assert_equal HASH, GitPush.find_reset_hash
    end
    
    should "return nil if cannot find temporary commit message" do
      GitPush.expects(:`).with("git log").returns(LOG_WITHOUT_TEMPORARY_COMMIT).once
      assert_nil GitPush.find_reset_hash
    end
    
    should "undo 'Temporary Commit'" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git log").returns(LOG).once
      GitPush.expects(:`).with("git reset #{HASH}").returns(RESET).once
      assert GitPush.reset
      assert_equal "Executing: git reset #{HASH}\n#{RESET}\n", out
    end
    
    should "print message and return if nothing to undo" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:find_reset_hash).returns(nil)
      GitPush.expects(:`).with("git reset #{/.*/}").never
      assert_equal false, GitPush.reset
      assert_equal "'GitPush Temporary Commit' not found.  Check git log or git reflog, maybe?\n", out
    end
  end
  
  context "push" do
    should "display an error if could not push" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git push").returns(PUSH_OUT_OF_DATE).once
      assert_equal false, GitPush.push
      assert_equal "Executing: git push\n#{PUSH_OUT_OF_DATE}\nError: Unable to push.  Exiting...\n", out 
    end
    
    should "show successful push" do
      out = ""
      IO.any_instance.expects(:puts).with { |s|  out << "#{s}\n" }.at_least_once
      GitPush.expects(:`).with("git push").returns(PUSH).once
      assert GitPush.push
      assert_equal "Executing: git push\n#{PUSH}\nGitPush complete!\n", out
    end
  end
  
  
  context "verbosity off"

end
