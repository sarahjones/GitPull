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
  def self.status
    puts "Executing: git status\n"
    status_output = `git status`
    puts status_output
  end
  

  
end
