require 'gmail'

class GMailClient
  attr_reader :start_inbox_count

  def initialize(options)
    check_config(options)
    @options = options
  end

  def connect
    puts "Connecting to GMail"
    @gmail = Gmail.connect(@options['email'], @options['password'])
    reset
  end

  def reset
    @start_inbox_count = @gmail.inbox.count
  end

  def receives_failure_notification_about_commit_ids(commit_ids)
    tries = 1
    while tries <= 10 && current_inbox_count == @start_inbox_count
      puts "Checking mail count (try #{tries})"
      tries +=1
    end
    current_inbox_count.must_be :>, start_inbox_count, "No new mail"

    mail = @gmail.inbox.emails.last
    mail.envelope.subject.must_equal "Build failure"

    commit_ids.each do |commit_id|
      mail.message.to_s.must_include commit_id
    end
  end

  def logout
    @gmail.logout if @gmail
  end

  private

  def check_config(options)
    raise ArgumentError, "Incomplete gmail_config.yml!" if invalid_config?(options)
  end

  def invalid_config?(options)
    (options.keys & ['email', 'password']).size != 2
  end

  def current_inbox_count
    @gmail.inbox.count
  end
end
