#Example of containing all requires for project

#lib = File.dirname(__FILE__)
#
#require lib + '/object.rb'
#require lib + '/symbol.rb'
#require lib + '/array.rb'
#require lib + '/string.rb'
#require lib + '/numeric.rb'
#require lib + '/time.rb'
#require lib + '/sql_statement.rb'
#require lib + '/where_builder.rb'
#require lib + '/select.rb'
#require lib + '/insert.rb'
#require lib + '/update.rb'
#require lib + '/delete.rb'


#git commit -a -m "Temporary work"
#git pull
##get commit hash
#git reset <hash>
#git push

#puts "git status"
#puts `git status`
#puts "Committing unstaged and untracked work to 'Temporary work'"
#puts `git commit -a -m "Temporary work"`
#puts "Pulling"
#puts `git pull`
##check for errors?
#log = `git log`
##output first 15 lines of git log - puts log
#puts "Reseting to <name>.  Hash = <hash>"
#puts `git reset <hash>`
#puts "Pushing"
#puts `git push`



class GitPush
  
  def self.git_push

  end
  
  def self.status
    puts "Executing: git status\n"
    status_output = `git status`
    puts status_output
  end
  
  def self.add
    puts "Executing: git add .\n"
    add_output = `git add .`
    puts add_output
    
    status_output = `git status`
        
    if status_output['# Untracked files:'] || status_output['# Changes not staged for commit:']
      puts "Error: not all files were added\nExiting..."
      false
    else  
      true
    end
  end
  
  def self.commit
    puts "Executing: git commit -m \"GitPush Temporary Commit\"\n"
    commit_output = `git commit -m \"GitPush Temporary Commit\"`
    puts commit_output
    
    status_output = `git status`
    puts status_output
    
    if commit_output['GitPush Temporary Commit'].nil?
      puts "Error: Commit failed\nExiting..."
      false
    else 
      true
    end
  end

  
end
