#Example of containing all requires for project

#lib = File.dirname(__FILE__)
#
#require lib + '/object.rb'






class GitPull
  
  COMMIT_MESSAGE = "GitPull Temporary Commit"
  
  def self.git_pull
    add && commit && pull && reset
  end
  
  def self.status
    puts "Executing: git status"
    status_output = `git status`
    puts status_output
  end
  
  def self.add
    puts "Executing: git add ."
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
    puts "Executing: git commit -m \"#{COMMIT_MESSAGE}\""
    commit_output = `git commit -m \"GitPull Temporary Commit\"`
    puts commit_output
    
    status_output = `git status`
    puts status_output
    
    if commit_output['GitPull Temporary Commit'].nil?
      puts "Error: Commit failed\nExiting..."
      false
    else 
      true
    end
  end
  
  def self.pull
    puts "Executing: git pull"
    pull_output = `git pull`
    puts pull_output

    status_output = `git status`
    puts status_output
    
    if pull_output['Automatic merge failed; fix conflicts and then commit the result.']
      puts "Error: Merge Conflicts\nYour 'GitPull Temporary Commit' is still committed.  Exiting..."
      false
    elsif status_output['# Changes to be committed:']
      puts "Error: Unknown Error.  There are untracked files in your status.\nYour 'GitPull Temporary Commit' is still committed.  Exiting..."
      false
    else
      true
    end
  end

  def self.reset
    hash = find_reset_hash
    unless hash
      puts "'GitPull Temporary Commit' not found.  Check git log or git reflog, maybe?"
      return false
    end
    
    puts "Executing: git reset #{hash}"
    reset_output = `git reset #{hash}`
    puts reset_output
    true
  end
  
  protected
  def self.find_reset_hash
    log_output = `git log`
    
    regex = /#{COMMIT_MESSAGE}\s+commit ([a-f0-9]{40})\s+Author/
    match = regex.match(log_output)
    match[1] if match
  end
  
end


if __FILE__==$0
  GitPull.git_pull
end
