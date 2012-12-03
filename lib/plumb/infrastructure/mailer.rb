require 'aws/simple_email_service'

module Plumb
  module Infrastructure
    class Mailer
      def initialize(mail_config, aws_config)
        @from = mail_config['from']
        @ses = AWS::SimpleEmailService.new(aws_config)
      end

      def build_failed(failure)
        @ses.send_email(
          subject: 'Build failure',
          from: @from,
          to: failure.build.pipeline.notification_email,
          body_text: <<-MESSAGE
Uh oh...

The following commits caused a build failure:

#{failure.build.details[:commits].join("\n")}

You might want to check it out.

Keep it futile,

CI
          MESSAGE
        )
      end
    end
  end
end
