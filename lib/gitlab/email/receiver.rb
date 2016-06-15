
require 'gitlab/email/handler'

# Inspired in great part by Discourse's Email::Receiver
module Gitlab
  module Email
    class ProcessingError < StandardError; end
    class EmailUnparsableError < ProcessingError; end
    class SentNotificationNotFoundError < ProcessingError; end
    class ProjectNotFound < ProcessingError; end
    class EmptyEmailError < ProcessingError; end
    class AutoGeneratedEmailError < ProcessingError; end
    class UserNotFoundError < ProcessingError; end
    class UserBlockedError < ProcessingError; end
    class UserNotAuthorizedError < ProcessingError; end
    class NoteableNotFoundError < ProcessingError; end
    class InvalidNoteError < ProcessingError; end
    class InvalidIssueError < ProcessingError; end
    class UnknownIncomingEmail < ProcessingError; end

    class Receiver
      def initialize(raw)
        @raw = raw
      end

      def execute
        raise EmptyEmailError if @raw.blank?

        mail = build_mail
        mail_key = extract_mail_key(mail)
        handler = Handler.for(mail, mail_key)

        if handler
          handler.execute
        else
          raise UnknownIncomingEmail
        end
      end

      def build_mail
        Mail::Message.new(@raw)
      rescue Encoding::UndefinedConversionError,
             Encoding::InvalidByteSequenceError => e
        raise EmailUnparsableError, e
      end

      def extract_mail_key(mail)
        key_from_to_header(mail) || key_from_additional_headers(mail)
      end

      def key_from_to_header(mail)
        mail.to.find do |address|
          key = Gitlab::IncomingEmail.key_from_address(address)
          break key if key
        end
      end

      def key_from_additional_headers(mail)
        Array(mail.references).find do |mail_id|
          key = Gitlab::IncomingEmail.key_from_fallback_message_id(mail_id)
          break key if key
        end
      end
    end
  end
end
