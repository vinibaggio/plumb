require 'gmail'

class GMailClient
  attr_reader :start_inbox_count

  def initialize(options)
    check_config(options)
    @options = options
  end

  def connect
    @gmail = Gmail.connect(@options['email'], @options['password'])
    reset
  end

  def reset
    @start_inbox_count = @gmail.inbox.count
  end

  def receives_failure_notification_about_commit_id(commit_id)
    current_inbox_count.must_be :>, start_inbox_count, "No new mail"
  end

  def logout
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
