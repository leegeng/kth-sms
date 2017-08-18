require 'kth/sms/version'
require 'kth/sms/case_sensitive_string'

module Kth
  module Sms
    class Client
      attr_accessor :client_id, :key

      BASE_URL = "http://api.apistore.co.kr".freeze

      def initialize(client_id, key)
        self.client_id = client_id
        self.key = key
      end

      def sms(send_phone, dest_phone, msg_body, options)
        request_url = "/ppurio/1/message/sms/#{client_id}"
        params = {
          'send_phone' => send_phone,
          'dest_phone' => dest_phone,
          'msg_body' => msg_body
        }

        if options.present?
          params['send_time'] = options['send_time'].strftime("%Y%m%d%H%M%S") if options['send_time']
          params['send_name'] = options['send_name'] if options['send_name']
          params['dest_name'] = options['dest_name'] if options['dest_name']
          # smsExcel 은 스펙 제외
        end

        send_post_request request_url, params
      end

      def lms(send_phone, dest_phone, msg_body, options)
        request_url = "/ppurio/1/message/lms/#{client_id}"

        params = {
          'send_phone' => send_phone,
          'dest_phone' => dest_phone,
          'msg_body' => msg_body
        }

        if options.present?
          params['send_time'] = options['send_time'].strftime("%Y%m%d%H%M%S") if options['send_time']
          params['send_name'] = options['send_name'] if options['send_name']
          params['dest_name'] = options['dest_name'] if options['dest_name']
          params['subject'] = options['subject'] if options['subject']
          # smsExcel 은 스펙 제외
        end

        send_post_request request_url, params
      end

      # mms 는 일단 스펙 제외

      def report(cmid)
        request_url = "/ppurio/1/message/report/#{client_id}?cmid=#{cmid}&client_id=#{client_id}"

        send_get_request request_url
      end

      def register_callback(send_phone_number, comment, pin_type = 'SMS')
        request_url = "/ppurio/2/sendnumber/save/#{client_id}"

        params = {
          'sendnumber' => send_phone_number,
          'comment' => comment,
          'pintype' => pin_type
        }

        send_post_request request_url, params
      end

      def verify_callback(send_phone_number, comment, pin_type = 'SMS', pin_code)
        request_url = "/ppurio/2/sendnumber/save/#{client_id}"

        params = {
          'sendnumber' => send_phone_number,
          'comment' => comment,
          'pintype' => pin_type,
          'pincode' => pin_code
        }

        send_post_request request_url, params
      end

      def callbacks(send_phone_number = nil)
        request_url = "/ppurio/1/sendnumber/list/#{client_id}?sendnumber=#{send_phone_number}"
        send_get_request request_url
      end

      def sms_test(send_phone, dest_phone, msg_body, options)
        request_url = "/ppurio_test/1/message_test/sms/#{client_id}"
        params = {
          'send_phone' => send_phone,
          'dest_phone' => dest_phone,
          'msg_body' => msg_body
        }

        if options.present?
          params['send_time'] = options['send_time'].strftime("%Y%m%d%H%M%S") if options['send_time']
          params['send_name'] = options['send_name'] if options['send_name']
          params['dest_name'] = options['dest_name'] if options['dest_name']
          # smsExcel 은 스펙 제외
        end

        send_post_request request_url, params
      end

      def report_test(cmid)
        request_url = "/ppurio_test/1/message_test/report/#{client_id}?cmid=#{cmid}&client_id=#{client_id}"

        send_get_request request_url
      end

      private

      def send_post_request(url, params)
        conn = Faraday.new(BASE_URL)
        res = conn.post do |req|
          req.url url
          req.headers[::CaseSensitiveString.new('x-waple-authorization')] = key
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
          req.body = params
        end

        JSON.parse(res.body)
      end

      def send_get_request(url)
        conn = Faraday.new(BASE_URL)
        res = conn.get do |req|
          req.url url
          req.headers[::CaseSensitiveString.new('x-waple-authorization')] = key
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        end

        JSON.parse(res.body)
      end
    end
  end
end
