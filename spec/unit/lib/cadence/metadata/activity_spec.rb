require 'cadence/metadata/activity'

describe Cadence::Metadata::Activity do
  subject { described_class.new(**args.to_h) }
  let(:args) { Fabricate(:activity_metadata) }

  describe '#initialize' do
    it 'sets the attributes' do
      expect(subject.domain).to eq(args.domain)
      expect(subject.id).to eq(args.id)
      expect(subject.name).to eq(args.name)
      expect(subject.task_token).to eq(args.task_token)
      expect(subject.attempt).to eq(args.attempt)
      expect(subject.workflow_run_id).to eq(args.workflow_run_id)
      expect(subject.workflow_id).to eq(args.workflow_id)
      expect(subject.workflow_name).to eq(args.workflow_name)
      expect(subject.headers).to eq(args.headers)
      expect(subject.timeouts).to eq(args.timeouts)
    end

    it { is_expected.to be_frozen }
    it { is_expected.to be_activity }
    it { is_expected.not_to be_decision }
    it { is_expected.not_to be_workflow }
  end

  describe '#to_h' do
    it 'returns a hash' do
      expect(subject.to_h).to eq(
        attempt: subject.attempt,
        activity_id: subject.id,
        activity_name: subject.name,
        domain: subject.domain,
        workflow_id: subject.workflow_id,
        workflow_name: subject.workflow_name,
        workflow_run_id: subject.workflow_run_id
      )
    end
  end
end
