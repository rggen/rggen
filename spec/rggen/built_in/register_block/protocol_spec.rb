# frozen_string_literal: true

RSpec.describe 'register_block/protocol' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  describe 'configuration' do
    before(:all) do
      RgGen.define_list_item_feature(:register_block, :protocol, [:foo, :bar, :baz]) do
        sv_rtl {}
      end
    end

    before do
      RgGen.enable(:register_block, :protocol)
    end

    after do
      RgGen.disable(:register_block, :protocol)
      delete_configuration_factory
    end

    describe '#protocol' do
      before do
        RgGen.enable(:register_block, :protocol, [:qux, :baz, :foo])
      end

      specify '既定値は定義されているプロトコルで、最初に有効になったプロトコル' do
        configuration = create_configuration
        expect(configuration).to have_property(:protocol, :baz)

        configuration = create_configuration(protocol: nil)
        expect(configuration).to have_property(:protocol, :baz)

        configuration = create_configuration(protocol: '')
        expect(configuration).to have_property(:protocol, :baz)
      end

      it '指定されたホストプロトコルを返す' do
        {
          foo: [
            'foo', 'FOO', random_string(/foo/i)
          ],
          baz: [
            'baz', 'BAZ', random_string(/baz/i)
          ]
        }.each do |protocol, values|
          values.each do |value|
            configuration = create_configuration(protocol: value)
            expect(configuration).to have_property(:protocol, protocol)

            configuration = create_configuration(protocol: value.to_sym)
            expect(configuration).to have_property(:protocol, protocol)
          end
        end
      end
    end

    it '表示可能オブジェクトとして、設定されたプロトコル名を返す' do
      RgGen.enable(:register_block, :protocol, [:foo, :bar, :baz])
      protocol =  [:foo, :bar, :baz].sample
      configuration = create_configuration(protocol: protocol)
      expect(configuration.printables[:protocol]).to eq protocol
    end

    describe 'エラーチェック' do
      context '使用可能なプロトコルがない場合' do
        before do
          RgGen.enable(:register_block, :protocol, :qux)
        end

        it 'ConfigurationErrorを起こす' do
          expect {
            create_configuration
          }.to raise_configuration_error 'no protocols are available'

          expect {
            create_configuration(protocol: nil)
          }.to raise_configuration_error 'no protocols are available'

          expect {
            create_configuration(protocol: '')
          }.to raise_configuration_error 'no protocols are available'
        end
      end

      context '有効になっていないプロトコルを指定した場合' do
        before do
          RgGen.enable(:register_block, :protocol, [:foo, :bar, :qux])
        end

        it 'ConfigurationErrorを起こす' do
          value = random_string(/baz/i)
          expect {
            create_configuration(protocol: value)
          }.to raise_configuration_error "unknown protocol: #{value.inspect}"

          value = random_string(/baz/i).to_sym
          expect {
            create_configuration(protocol: value)
          }.to raise_configuration_error "unknown protocol: #{value.inspect}"
        end
      end

      context '定義されていないプロトコルを指定した場合' do
        before do
          RgGen.enable(:register_block, :protocol, [:foo, :bar, :qux])
        end

        it 'ConfigurationErrorを起こす' do
          value = random_string(/qux/i)
          expect {
            create_configuration(protocol: value)
          }.to raise_configuration_error "unknown protocol: #{value.inspect}"

          value = random_string(/qux/i).to_sym
          expect {
            create_configuration(protocol: value)
          }.to raise_configuration_error "unknown protocol: #{value.inspect}"
        end
      end
    end
  end
end
