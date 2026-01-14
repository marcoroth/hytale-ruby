# frozen_string_literal: true

module Hytale
  module Client
    class Process
      attr_reader :pid, :started_at

      def initialize(pid:, started_at: nil)
        @pid = pid
        @started_at = started_at
      end

      def running?
        ::Process.kill(0, pid)
        true
      rescue Errno::ESRCH
        false
      rescue Errno::EPERM
        true
      end

      class << self
        def list
          processes = []

          case RUBY_PLATFORM
          when /darwin/, /linux/
            output = `pgrep -f "HytaleClient" 2>/dev/null`.strip

            output.split("\n").each do |pid_str|
              pid = pid_str.to_i
              processes << new(pid: pid) if pid.positive?
            end
          when /mswin|mingw|cygwin/
            output = `tasklist /FI "IMAGENAME eq HytaleClient.exe" /FO CSV 2>nul`.strip

            output.split("\n").drop(1).each do |line|
              parts = line.split(",")
              pid = parts[1]&.tr('"', "")&.to_i
              processes << new(pid: pid) if pid&.positive?
            end
          end

          processes
        end

        def running?
          list.any?
        end

        def find(pid)
          list.find { |p| p.pid == pid }
        end
      end
    end
  end
end
