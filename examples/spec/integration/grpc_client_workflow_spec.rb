require 'workflows/grpc_client_workflow'

describe GrpcClientWorkflow, :integration do
  it 'executes HelloWorldActivity' do
    run_workflow(described_class)
  end

end