# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :sv_ral_package) do
  sv_ral do
    write_file '<%= package_name %>.sv' do |file|
      file.body do
        package_definition(package_name) do |package|
          package.package_imports packages
          package.include_files include_files
          package.body do |code|
            register_block.generate_code(:ral_package, :bottom_up, code)
          end
        end
      end
    end

    main_code :ral_package do
      class_definition(model_name) do |sv_class|
        sv_class.base 'rggen_ral_block'
        sv_class.parameters parameters
        sv_class.variables variables
        sv_class.body do
          process_template(File.join(__dir__, 'sv_ral_block_model.erb'))
        end
      end
    end

    private

    def package_name
      "#{register_block.name}_ral_pkg"
    end

    def packages
      [
        'uvm_pkg', 'rggen_ral_pkg',
        *register_block.package_imports(:ral_package)
      ]
    end

    def include_files
      ['uvm_macros.svh', 'rggen_ral_macros.svh']
    end

    def model_name
      "#{register_block.name}_block_model"
    end

    def parameters
      register_block.declarations(:register_block, :parameter)
    end

    def variables
      register_block.declarations(:register_block, :variable)
    end

    def reg_model_constructors
      register_block.registers.flat_map(&:constructors)
    end

    def byte_width
      configuration.byte_width
    end
  end
end
