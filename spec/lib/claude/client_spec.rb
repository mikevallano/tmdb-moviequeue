# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Claude::Client do
  let(:messages) { double('messages') }
  let(:anthropic) { double('anthropic', beta: double('beta', messages: messages)) }
  let(:schema) { { type: 'object' } }

  def response(stop_reason: :end_turn, text: '{"suggestions":[]}')
    double(
      'response',
      model: described_class::MODEL,
      stop_reason: stop_reason,
      stop_details: nil,
      usage: double('usage', input_tokens: 10, output_tokens: 5),
      content: [double('block', type: :text, text: text)]
    )
  end

  before do
    described_class.instance_variable_set(:@client, nil)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('anthropic_api_key').and_return('test-key')
    allow(Anthropic::Client).to receive(:new)
      .with(api_key: 'test-key', timeout: described_class::TIMEOUT_SECONDS, max_retries: 0)
      .and_return(anthropic)
  end

  after { described_class.instance_variable_set(:@client, nil) }

  it 'requests structured JSON and returns it parsed' do
    allow(messages).to receive(:create).and_return(response(text: '{"suggestions":[{"title":"Heat"}]}'))

    result = described_class.request_json(system: 'sys', prompt: 'hi', schema: schema)

    expect(result).to eq(suggestions: [{ title: 'Heat' }])
    expect(messages).to have_received(:create).with(hash_including(
      model: described_class::MODEL,
      system_: 'sys',
      messages: [{ role: :user, content: 'hi' }],
      output_config: { effort: described_class::EFFORT, format: { type: :json_schema, schema: schema } }
    ))
  end

  it 'raises a Claude::Client::Error on a refusal' do
    allow(messages).to receive(:create).and_return(response(stop_reason: :refusal))

    expect { described_class.request_json(system: 'sys', prompt: 'hi', schema: schema) }
      .to raise_error(Claude::Client::Error, /declined/)
  end

  it 'wraps SDK errors in a Claude::Client::Error' do
    allow(messages).to receive(:create).and_raise(Anthropic::Errors::Error, 'nope')

    expect { described_class.request_json(system: 'sys', prompt: 'hi', schema: schema) }
      .to raise_error(Claude::Client::Error, /nope/)
  end
end
