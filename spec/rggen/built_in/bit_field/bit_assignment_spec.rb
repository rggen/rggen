# frozen_string_literal: true

RSpec.describe 'bit_field/bit_assignment' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, :data_width)
    RgGen.enable(:bit_field, :bit_assignment)
  end

  let(:data_width) { [8, 16, 32].sample }

  let(:configuration) do
    create_configuration(data_width: data_width)
  end

  describe '#msb/#lsb/#width' do
    let(:bit_assignments) do
      assignments = []

      lsb = rand(0...data_width)
      assignments << [lsb]

      lsb = rand(0...data_width)
      assignments << [lsb, lsb]

      lsb = rand(0...(data_width - 1))
      msb = rand((lsb + 1)...data_width)
      assignments << [msb, lsb]

      assignments
    end

    let(:bit_assignment_strings) do
      bit_assignments.map do |assignment|
        pattern =
          if assignment.size == 2
            /\[ *#{assignment[0]} *: *#{assignment[1]} *\]/
          else
            /\[ *#{assignment[0]} *\]/
          end
        random_string(pattern)
      end
    end

    let(:register_map) do
      create_register_map(configuration) do
        register_block do
          register { bit_field { bit_assignment bit_assignment_strings[0] } }
          register { bit_field { bit_assignment bit_assignment_strings[1] } }
          register { bit_field { bit_assignment bit_assignment_strings[2] } }
        end
      end
    end

    it '入力されたビット割当を返す' do
      expect(register_map.bit_fields[0]).to have_property(:msb, bit_assignments[0][0])
      expect(register_map.bit_fields[0]).to have_property(:lsb, bit_assignments[0][0])
      expect(register_map.bit_fields[0]).to have_property(:width, 1)

      expect(register_map.bit_fields[1]).to have_property(:msb, bit_assignments[1][0])
      expect(register_map.bit_fields[1]).to have_property(:lsb, bit_assignments[1][0])
      expect(register_map.bit_fields[1]).to have_property(:width, 1)

      width = bit_assignments[2][0] - bit_assignments[2][1] + 1
      expect(register_map.bit_fields[2]).to have_property(:msb, bit_assignments[2][0])
      expect(register_map.bit_fields[2]).to have_property(:lsb, bit_assignments[2][1])
      expect(register_map.bit_fields[2]).to have_property(:width, width)
    end
  end

  describe 'エラーチェック' do
    context '入力パターンに一致しない場合' do
      let(:invalid_patterns) do
        [
          '0',
          '[0',
          '0]',
          '[]',
          random_string(/\[[a-z]+\]/),
          '1:0',
          '[1:0',
          '1:0]',
          '[1:]',
          '[:0]',
          '[:]',
          random_string(/\[[a-z]+:0\]/),
          random_string(/\[1:[a-z]+\]/)
        ]
      end

      it 'RegisterMapErrorを起こす' do
        invalid_patterns.each do |invalid_pattern|
          expect {
            create_register_map(configuration) do
              register_block do
                register { bit_field { bit_assignment invalid_pattern } }
              end
            end
          }.to raise_register_map_error "illegal input value for bit assignment: #{invalid_pattern.inspect}"
        end
      end
    end

    context 'LSBがMSBより大きい場合' do
      let(:msb) do
        rand(0..(data_width - 2))
      end

      let(:lsb) do
        rand((msb + 1)..(data_width - 1))
      end

      it 'RegisterMapErrorを起こす' do
        expect {
          create_register_map(configuration) do
            register_block do
              register { bit_field { bit_assignment "[#{msb}:#{lsb}]" } }
            end
          end
        }.to raise_register_map_error "lsb is larger than msb: msb #{msb} lsb #{lsb}"
      end
    end

    context 'LSBが0未満の場合' do
      it 'RegisterMapErrorを起こす' do
        [-1, -2, -data_width].each do |invalid_lsb|
          expect {
            create_register_map(configuration) do
              register_block do
                register { bit_field { bit_assignment "[#{invalid_lsb}]" } }
              end
            end
          }.to raise_register_map_error "lsb is less than 0: lsb #{invalid_lsb}"
        end
      end
    end

    context 'LSBがデータ幅以上の場合' do
      it 'RegisterMapErrorを起こす' do
        [data_width, (data_width + 1), rand((data_width + 2)..(2*data_width))].each do |invalid_msb|
          expect {
            create_register_map(configuration) do
              register_block do
                register { bit_field { bit_assignment "[#{invalid_msb}]" } }
              end
            end
          }.to raise_register_map_error "msb is not less than data width: msb #{invalid_msb} data width #{data_width}"
        end
      end
    end

    context '既存のビットフィールドとビット割当が重複する場合' do
      let(:existing_bit_assignment) do
        lsb = rand(1..(data_width - 4))
        msb = rand((lsb + 2)..(data_width - 2))
        [msb, lsb]
      end

      let(:bit_assignments) do
        assignments = []

        assignments << [existing_bit_assignment[0] + 0, existing_bit_assignment[1] + 0]
        assignments << [existing_bit_assignment[0] - 1, existing_bit_assignment[1] + 0]
        assignments << [existing_bit_assignment[0] - 0, existing_bit_assignment[1] + 1]
        assignments << [existing_bit_assignment[0] - 1, existing_bit_assignment[1] + 1]
        assignments << [existing_bit_assignment[0] + 1, existing_bit_assignment[1] - 1]

        assignments
      end

      it 'RegisterMapErrorを起こす' do
        bit_assignments.each do |assignment|
          expect {
            create_register_map(configuration) do
              register_block do
                register do
                  bit_field { bit_assignment "[#{existing_bit_assignment[0]}:#{existing_bit_assignment[1]}]" }
                  bit_field { bit_assignment "[#{assignment[0]}:#{assignment[1]}]" }
                end
              end
            end
          }.to raise_register_map_error "overlapped bit assignment: msb #{assignment[0]} lsb #{assignment[1]}"
        end
      end
    end
  end
end
