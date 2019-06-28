# frozen_string_literal: true

RSpec.describe 'global/fold_sv_interface_port' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, :fold_sv_interface_port)
  end

  describe '#fold_sv_interface_port?' do
    specify '既定値はtrueである' do
      configuration = create_configuration
      expect(configuration).to have_property(:fold_sv_interface_port?, true)
    end

    context 'true/on/yesが入力された場合' do
      it 'trueを返す' do
        configuration = create_configuration(fold_sv_interface_port: true)
        expect(configuration).to have_property(:fold_sv_interface_port?, true)

        [
          /true/i,
          /on/i,
          /yes/i
        ].each do |pattern|
          value = random_string(pattern)
          configuration = create_configuration(fold_sv_interface_port: value)
          expect(configuration).to have_property(:fold_sv_interface_port?, true)

          value = random_string(pattern).to_sym
          configuration = create_configuration(fold_sv_interface_port: value)
          expect(configuration).to have_property(:fold_sv_interface_port?, true)
        end
      end
    end

    context 'false/off/noが入力された場合' do
      it 'falseを返す' do
        configuration = create_configuration(fold_sv_interface_port: false)
        expect(configuration).to have_property(:fold_sv_interface_port?, false)

        [
          /false/i,
          /off/i,
          /no/i
        ].each do |pattern|
          value = random_string(pattern)
          configuration = create_configuration(fold_sv_interface_port: value)
          expect(configuration).to have_property(:fold_sv_interface_port?, false)

          value = random_string(pattern).to_sym
          configuration = create_configuration(fold_sv_interface_port: value)
          expect(configuration).to have_property(:fold_sv_interface_port?, false)
        end
      end
    end
  end

  describe 'エラーチェック' do
    context 'true/on/yes/false/off/no以外が入力された場合' do
      it 'ConfigurationErrorを起こす' do
        [nil, '', 'foo', :foo, 0, Object.new].each do |value|
          expect {
            create_configuration(fold_sv_interface_port: value)
          }.to raise_configuration_error "cannot convert #{value.inspect} into boolean"
        end
      end
    end
  end
end
