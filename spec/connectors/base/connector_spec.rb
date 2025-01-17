#
# Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
# or more contributor license agreements. Licensed under the Elastic License;
# you may not use this file except in compliance with the Elastic License.
#

# frozen_string_literal: true

require 'connectors/base/connector'

describe Connectors::Base::Connector do
  subject { described_class.new(job_description: job_description) }

  let(:advanced_config) {
    {
      :find => {
        :filter => {
          :$text => {
            :$search => 'garden',
            :$caseSensitive => false
          }
        },
        :options => {
          :skip => 10,
          :limit => 1000
        }
      }
    }
  }

  let(:rules) {
    [
      {
        :id => '90owilfksdoifuw',
        :policy => 'exclude',
        :field => 'url',
        :rule => 'regex',
        :value => '.*/sample/.*\.pdf',
        :order => 0,
        :created_at => '2022-10-10T00:00:00Z',
        :updated_at => '2022-10-10T00:00:00Z'
      }
    ]
  }

  let(:filtering) {
    {
      :advanced_config => advanced_config,
      :rules => rules
    }
  }

  let(:job_description) {
    {
      :filtering => filtering
    }
  }

  context '.advanced_filter_config?' do
    shared_examples_for 'advanced_config is not present' do
      it 'returns empty object' do
        expect(subject.advanced_filter_config).to be_empty
      end
    end

    context 'advanced config is present' do
      it 'returns advanced filter config' do
        expect(subject.advanced_filter_config).to eq(advanced_config)
      end
    end

    context 'advanced config is nil' do
      let(:advanced_config) {
        nil
      }

      it_behaves_like 'advanced_config is not present'
    end

    context 'advanced config is empty' do
      let(:advanced_config) {
        {}
      }

      it_behaves_like 'advanced_config is not present'
    end
  end

  context '.rules' do
    shared_examples_for 'rules are not present' do
      it 'returns empty array' do
        expect(subject.rules).to be_empty
      end
    end

    context 'rules are present' do
      it 'returns true' do
        expect(subject.rules).to eq(rules)
      end
    end

    context 'rules are nil' do
      let(:rules) {
        nil
      }

      it_behaves_like 'rules are not present'
    end

    context 'rules are empty' do
      let(:rules) {
        []
      }

      it_behaves_like 'rules are not present'
    end
  end

  context '.filtering_present?' do
    shared_examples_for 'filtering is not present' do
      it 'returns false' do
        expect(subject.filtering_present?).to eq(false)
      end
    end

    shared_examples_for 'filtering is present' do
      it 'returns true' do
        expect(subject.filtering_present?).to eq(true)
      end
    end

    context 'rules and advanced_config are present' do
      it_behaves_like 'filtering is present'
    end

    context 'only rules are nil' do
      let(:rules) {
        nil
      }

      it_behaves_like 'filtering is present'
    end

    context 'only rules are empty' do
      let(:rules) {
        []
      }

      it_behaves_like 'filtering is present'
    end

    context 'only advanced_config is empty' do
      let(:advanced_config) {
        {}
      }

      it_behaves_like 'filtering is present'
    end

    context 'only advanced_config is nil' do
      let(:advanced_config) {
        nil
      }

      it_behaves_like 'filtering is present'
    end

    context 'rules are empty and advanced_config is empty' do
      let(:rules) {
        []
      }

      let(:advanced_config) {
        {}
      }

      it_behaves_like 'filtering is not present'
    end

    context 'rules are nil and advanced_config is nil' do
      let(:rules) {
        nil
      }

      let(:advanced_config) {
        nil
      }

      it_behaves_like 'filtering is not present'
    end

    context '.rules' do
      let(:rules) {
        [
          {
            :id => '90owilfksdoifuw',
            :policy => 'exclude',
            :field => 'url',
            :rule => 'regex',
            :value => '.*/sample/.*\.pdf',
            :order => 0,
            :created_at => '2022-10-10T00:00:00Z',
            :updated_at => '2022-10-10T00:00:00Z'
          },
          {
            :id => '09wuekwisdfjslk',
            :policy => 'include',
            :field => 'id',
            :rule => 'regex',
            :value => '.*',
            :order => 1,
            :created_at => '2022-10-10T00:00:00Z',
            :updated_at => '2022-10-10T00:00:00Z'
          }
        ]
      }

      context 'two rules are present' do
        it 'should extract three rules from job description' do
          extracted_rules = subject.rules

          expect(extracted_rules).to_not be_nil
          expect(extracted_rules.size).to eq(2)

          expect(extracted_rules[0]).to eq(rules[0])
          expect(extracted_rules[1]).to eq(rules[1])
        end
      end

      shared_examples_for 'has default rules value' do
        it 'defaults to an empty array' do
          extracted_rules = subject.rules

          expect(extracted_rules).to_not be_nil
          expect(extracted_rules.size).to eq(0)
        end
      end

      context 'no rules are present' do
        let(:rules) {
          []
        }

        it_behaves_like 'has default rules value'
      end

      context 'rules are nil' do
        let(:rules) {
          nil
        }

        it_behaves_like 'has default rules value'
      end

      context 'advanced filter config is present' do
        it 'extracts the advanced filter config' do
          advanced_filter_config = subject.advanced_filter_config

          expect(advanced_filter_config).to eq(advanced_config)
        end
      end

      shared_examples_for 'has default filter config value' do
        it 'defaults to an empty hash' do
          advanced_filter_config = subject.advanced_filter_config

          expect(advanced_filter_config).to_not be_nil
          expect(advanced_filter_config).to eq({})
        end
      end

      context 'filter config is nil' do
        let(:advanced_config) {
          nil
        }

        it_behaves_like 'has default filter config value'
      end

      context 'filter config is empty' do
        let(:advanced_config) {
          {}
        }

        it_behaves_like 'has default filter config value'
      end
    end
  end
end
