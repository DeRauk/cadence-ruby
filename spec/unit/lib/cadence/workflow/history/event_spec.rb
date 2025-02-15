require 'cadence/workflow/history/event'

describe Cadence::Workflow::History::Event do
  subject { described_class.new(raw_event) }

  describe '#initialize' do
    let(:raw_event) { Fabricate(:workflow_execution_started_event_thrift) }

    it 'sets correct id' do
      expect(subject.id).to eq(raw_event.eventId)
    end

    it 'sets correct timestamp' do
      current_time = Time.now
      allow(Time).to receive(:now).and_return(current_time)

      expect(subject.timestamp).to be_within(0.0001).of(current_time)
    end

    it 'sets correct type' do
      expect(subject.type).to eq('WorkflowExecutionStarted')
    end

    it 'sets correct attributes' do
      expect(subject.attributes).to eq(raw_event.workflowExecutionStartedEventAttributes)
    end
  end

  describe '#decision_id' do
    subject { described_class.new(raw_event).decision_id }

    context 'when event is TimerFired' do
      let(:raw_event) { Fabricate(:timer_fired_event_thrift, eventId: 42) }

      it { is_expected.to eq(raw_event.timerFiredEventAttributes.startedEventId) }
    end

    context 'when event is TimerCanceled' do
      let(:raw_event) { Fabricate(:timer_canceled_event_thrift, eventId: 42) }

      it { is_expected.to eq(raw_event.eventId) }
    end
  end

  describe '#target_attributes' do
    subject { described_class.new(raw_event).target_attributes }

    context 'when event is ActivityTaskScheduled' do
      let(:input) { ['foo', 'bar', { 'foo' => 'bar' }] }
      let(:raw_event) do
        Fabricate(:activity_task_scheduled_event_thrift, eventId: 42, input: input)
      end

      it {
        is_expected.to eq({ activity_id: 42, activity_type: 'TestActivity', input: input })
      }
    end

    context 'when event is DecisionTaskScheduled' do
      let(:input) { ['foo', 'bar', { 'foo' => 'bar' }] }
      let(:raw_event) do
        Fabricate(:decision_task_scheduled_event_thrift, eventId: 42)
      end

      it {
        is_expected.to eq({})
      }
    end
  end
end
