require 'activities/hello_world_activity'
require_relative '../route_guide_services_pb'

class GrpcClientWorkflow < Cadence::Workflow
  def execute
    Routeguide::RouteGuide::Stub.new('localhost:50051', :this_channel_is_insecure)
  end
end