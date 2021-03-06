module Fog
  module Parsers
    module AWS
      module CloudFormation

        class DescribeStacks < Fog::Parsers::Base

          def reset
            @stack = { 'Outputs' => [], 'Parameters' => [] }
            @output = {}
            @parameter = {}
            @response = { 'Stacks' => [] }
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'Outputs'
              @in_outputs = true
            when 'Parameters'
              @in_parameters = true
            end
          end

          def end_element(name)
            if @in_outputs
              case name
              when 'OutputKey', 'OutputValue'
                @output[name] = @value
              when 'member'
                @stack['Outputs'] << @output
                @output = {}
              when 'Outputs'
                @in_outputs = false
              end
            elsif @in_parameters
              case name
              when 'ParameterKey', 'ParameterValue'
                @parameter[name] = @value
              when 'member'
                @stack['Parameters'] << @parameter
                @parameter = {}
              when 'Parameters'
                @in_parameters = false
              end
            else
              case name
              when 'StackName', 'StackId', 'CreationTime', 'StackStatus', 'DisableRollback'
                @stack[name] = @value
              when 'member'
                @response['Stacks'] << @stack
                @stack = { 'Outputs' => [], 'Parameters' => [] }
              end
            end
          end

        end
      end
    end
  end
end
