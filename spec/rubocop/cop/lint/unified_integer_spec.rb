# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnifiedInteger, :config do
  subject(:cop) { described_class.new(config) }

  context 'target ruby version < 2.4', :ruby23 do
    it 'does not register an offense when using `Fixnum`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        1.is_a?(Fixnum)
      RUBY
    end

    it 'does not register an offense when using `Bignum`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        (2 ** 64).is_a?(Bignum)
      RUBY
    end
  end

  context 'target ruby version >= 2.4', :ruby24 do
    shared_examples 'registers an offence' do |klass|
      context "when #{klass}" do
        context 'without any decorations' do
          let(:source) { "1.is_a?(#{klass})" }

          it 'registers an offence' do
            inspect_source(source)
            expect(cop.offenses.size).to eq(1)
            expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
          end

          it 'autocorrects' do
            new_source = autocorrect_source(source)
            expect(new_source).to eq('1.is_a?(Integer)')
          end
        end

        context 'when explicitly specified as toplevel constant' do
          let(:source) { "1.is_a?(::#{klass})" }

          it 'registers an offence' do
            inspect_source(source)
            expect(cop.offenses.size).to eq(1)
            expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
          end

          it 'autocorrects' do
            new_source = autocorrect_source(source)
            expect(new_source).to eq('1.is_a?(::Integer)')
          end
        end

        context 'with MyNamespace' do
          let(:source) { "1.is_a?(MyNamespace::#{klass})" }

          include_examples 'accepts'
        end
      end
    end

    include_examples 'registers an offence', 'Fixnum'
    include_examples 'registers an offence', 'Bignum'

    context 'when Integer' do
      context 'without any decorations' do
        let(:source) { '1.is_a?(Integer)' }

        include_examples 'accepts'
      end

      context 'when explicitly specified as toplevel constant' do
        let(:source) { '1.is_a?(::Integer)' }

        include_examples 'accepts'
      end

      context 'with MyNamespace' do
        let(:source) { '1.is_a?(MyNamespace::Integer)' }

        include_examples 'accepts'
      end
    end
  end
end
