# frozen_string_literal: true

RSpec.describe RgGen do
  include_context 'clean-up builder'

  describe '規定セットアップファイル' do
    before(:all) do
      @original_stdout = $stdout
      $stdout = File.open(File::NULL, 'w')
    end

    after(:all) do
      $stdout = @original_stdout
    end

    let(:builder) { RgGen.builder }

    describe RgGen::DEFAULT_SETUP_FILE do
      it '規定セットアップファイルのパスを示す' do
        path = File.expand_path('../../lib/rggen/setup/default.rb', __dir__)
        expect(RgGen::DEFAULT_SETUP_FILE).to eq path
      end
    end

    specify 'セットアップファイルが未指定の場合、規定セットアップファイルが読み込まれる' do
      RgGen::BuiltIn.module_eval do
        const_defined?(:BUILT_IN_FILES) && remove_const(:BUILT_IN_FILES)
      end

      $LOADED_FEATURES.delete_if do |file|
        [
          %r{rggen/systemverilog\.rb},
          %r{rggen/built_in\.rb},
          %r{rggen/spreadsheet_loader\.rb}
        ].any? do |pattern|
          pattern.match(file)
        end
      end

      expect(builder).to receive(:setup).with(:systemverilog, equal(RgGen::SystemVerilog))
      expect(builder).to receive(:setup).with(:'built-in', equal(RgGen::BuiltIn))
      expect(builder).to receive(:setup).with(:'spreadsheet-loader', equal(RgGen::SpreadsheetLoader))

      expect(builder).to receive(:enable).with(:global, match([:bus_width, :address_width, :array_port_format, :fold_sv_interface_port])).and_call_original

      expect(builder).to receive(:enable).with(:register_block, match([:name, :byte_size])).and_call_original
      expect(builder).to receive(:enable).with(:register, match([:name, :offset_address, :size, :type])).and_call_original
      expect(builder).to receive(:enable).with(:register, :type, match([:external, :indirect])).and_call_original
      expect(builder).to receive(:enable).with(:bit_field, match([:name, :bit_assignment, :type, :initial_value, :reference, :comment])).and_call_original
      expect(builder).to receive(:enable).with(:bit_field, :type, match([:rc, :reserved, :ro, :rof, :rs, :rw, :rwe, :rwl, :w0c, :w1c, :w0s, :w1s, :wo])).and_call_original

      expect(builder).to receive(:enable).with(:register_block, match([:sv_rtl_top, :protocol])).and_call_original
      expect(builder).to receive(:enable).with(:register_block, :protocol, match([:apb, :axi4lite])).and_call_original
      expect(builder).to receive(:enable).with(:register, match([:sv_rtl_top])).and_call_original
      expect(builder).to receive(:enable).with(:bit_field, match([:sv_rtl_top])).and_call_original

      expect(builder).to receive(:enable).with(:register_block, match([:sv_ral_package])).and_call_original

      cli = RgGen::Core::CLI.new(builder)
      cli.run(['--verbose-version'])
    end
  end
end
