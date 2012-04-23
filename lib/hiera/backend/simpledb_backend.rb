# Class Simpledb_backend
# Description: AWS SimpleDB backend to Hiera.
# Author: Nathan Butler <nathan.butler@newsweekdailybeast.com>
# 
class Hiera
  module Backend
    class Simpledb_backend
      def initialize
        begin
          require 'aws-sdk'
        rescue LoadError
          require 'rubygems'
          require 'aws-sdk'
        end

        @sdb = AWS::SimpleDB.new(Config[:simpledb])
        
        Hiera.debug("Hiera SimpleDB backend initialized")
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = Backend.empty_answer(resolution_type)
        query = Backend.parse_string(Config[:simpledb][:query], scope, { "key" => key })

        Hiera.debug("Looking up \"#{key}\" in SimpleDB Backend")
        Hiera.debug("Resolution_type: #{resolution_type}")

        # Search list of domains specified in the hierarchy section in hiera.yaml
        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for simpledb domain #{source}")

          begin
            results = @sdb.domains[source].items[key].data.attributes
          rescue AWS::SimpleDB::Errors::NoSuchDomain
            Hiera.warn("Cannot find domain #{source}, skipping")
            next
          end

          next if ! results
          next if results.empty?

          Hiera.debug("Found Results: #{results.inspect}")

          # for array resolution we just append to the array whatever
          # we find, we then go onto the next file and keep adding to
          # the array
          #
          # for priority searches we break after the first found data item
          new_answer = type_conv(Backend.parse_answer(results, scope))
          case resolution_type
            when :array
              answer << new_answer
            when :hash
              answer = new_answer.merge answer
            else
              answer = new_answer
              break
          end
        end
        # The hiera backend.rb library breaks if the answer is true
        # and empty [] or {} return true, which prevents additional
        # backends from running. We don't want to prevent this so we
        # return nil instead so additional lesser priority backends
        # can run. The reason this works for :priority is that 
        # Backend.empty_answer(:priority) returns nil already
        answer = nil if answer == Backend.empty_answer(resolution_type)
        return answer
      end

      # The simpledb aws-sdk returns attribute values as an array
      # of values even if there is only one value. This normalizes the 
      # data type to a string if their are less than 2 array values.
      def type_conv(results)
        new_results = Hash.new
        results.each do |k,v|
          if v.size < 2
            new_results[k] = v.to_s
          else
            new_results[k] = v
          end
        end
        return new_results
      end

    end
  end
end
