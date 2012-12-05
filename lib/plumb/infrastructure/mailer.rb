require 'aws/simple_email_service'

module Plumb
  module Infrastructure
    class Mailer
      NoRecipients = Class.new(ArgumentError)

      def initialize(mail_config, aws_config)
        @from = mail_config['from']
        @ses = AWS::SimpleEmailService.new(aws_config)
      end

      def build_failed(failure)
        if failure.build.pipeline.notification_email.nil?
          raise NoRecipients, "pipeline does not have a notification email"
        end

        @ses.send_email(
          subject: 'Build failure',
          from: @from,
          to: failure.build.pipeline.notification_email,
          body_text: <<-MESSAGE
Uh oh...

The following commits caused a build failure:

#{failure.build.commits.join("\n")}

You might want to check it out.

Keep it futile,

CI
          MESSAGE
        )
      end
    end
  end
end
