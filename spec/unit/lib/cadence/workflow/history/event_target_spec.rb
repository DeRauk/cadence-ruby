require 'cadence/workflow/history/event_target'
require 'cadence/workflow/history/event'
require 'cadence/workflow/decision'

describe Cadence::Workflow::History::EventTarget do
  describe '.from_event' do
    subject { described_class.from_event(event) }
    let(:event) { Cadence::Workflow::History::Event.new(raw_event) }

    context 'when event is TimerStarted' do
      let(:raw_event) { Fabricate(:timer_started_event_thrift, eventId: 42) }

      it 'sets id and type' do
        expect(subject.id).to eq(42)
        expect(subject.type).to eq(described_class::TIMER_TYPE)
        expect(subject.attributes).to eq({})
      end
    end

    context 'when event is TimerCanceled' do
      let(:raw_event) { Fabricate(:timer_canceled_event_thrift, eventId: 42) }

      it 'sets id and type' do
        expect(subject.id).to eq(42)
        expect(subject.type).to eq(described_class::CANCEL_TIMER_REQUEST_TYPE)
        expect(subject.attributes).to eq({})
      end
    end

    context 'when event is ScheduleActivity' do
      let(:input) { ['foo', 'bar', { 'foo' => 'bar' }] }
      let(:raw_event) { Fabricate(:activity_task_scheduled_event_thrift, eventId: 42, input: input) }

      it 'sets id, type and attributes' do
        expect(subject.id).to eq(42)
        expect(subject.type).to eq(described_class::ACTIVITY_TYPE)
        expect(subject.attributes).to eq({ activity_id: 42, activity_type: 'TestActivity', input: input })
      end
    end
  end

  describe '.from_decision' do
    subject { described_class.from_decision(42, decision) }

    context 'when decision is ScheduleActivity' do
      let(:raw_decision) { { activity_type: 'foo', activity_id: 123, input: ['bar'], domain: 'domain' } }
      let(:decision) { Cadence::Workflow::Decision::ScheduleActivity.new(**raw_decision) }

      it 'sets id, type' do
        expect(subject.id).to eq(42)
        expect(subject.type).to eq(described_class::ACTIVITY_TYPE)
      end

      it 'sets and slice the attributes' do
        expect(raw_decision).to include(subject.attributes)
        expect(subject.attributes.keys).to eq(%i[activity_id activity_type input])
      end
    end

    context 'when decision is StartTimer' do
      let(:raw_decision) { { timeout: 10, timer_id: 123 } }
      let(:decision) { Cadence::Workflow::Decision::StartTimer.new(**raw_decision) }

      it 'sets id, type' do
        expect(subject.id).to eq(42)
        expect(subject.type).to eq(described_class::TIMER_TYPE)
      end

      it 'sets empty attributes' do
        expect(subject.attributes.keys).to eq([])
      end
    end
  end

  describe '#==' do
    subject do
      described_class.new(id, type, attributes: attributes) ==
        described_class.new(42, 'type', attributes: { foo: 'bar' })
    end
    let(:id) { 42 }
    let(:type) { 'type' }
    let(:attributes) { { foo: 'bar' } }

    context 'when all value are the same' do
      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when id are different' do
      let(:id) { 1 }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when type are different' do
      let(:type) { 'other_type' }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
