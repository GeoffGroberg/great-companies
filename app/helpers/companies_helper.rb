module CompaniesHelper
  def big5_temperature(percent)
    t = ''
    case percent
    when -Float::INFINITY...-5.0
      t = 't-10'
    when -5.0..-4.0
      t = 't-9'
    when -4.0..-3.0
      t = 't-8'
    when -3.0..-2.0
      t = 't-7'
    when -2.0..-1.0
      t = 't-6'
    when -1.0..-0.0
      t = 't-5'
    when 0.0..1.0
      t = 't-4'
    when 1.0..2.0
      t = 't-3'
    when 2.0..3.0
      t = 't-2'
    when 3.0..4.0
      t = 't-1'
    when 4.0..5.0
      t = 't0'
    when 5.0..6.0
      t = 't1'
    when 6.0..7.0
      t = 't2'
    when 7.0..8.0
      t = 't3'
    when 8.0..9.0
      t = 't4'
    when 9.0..10.0
      t = 't5'
    when 10.0..11.0
      t = 't6'
    when 11.0..12.0
      t = 't7'
    when 12.0..13.0
      t = 't8'
    when 13.0..14.0
      t = 't9'
    when 14.0...Float::INFINITY
      t = 't10'
    end
    t
  end

  def debt_temperature(ratio)
    t = ''
    case ratio
    when 9.5...Float::INFINITY
      t = 't-10'
    when 9.0..9.5
      t = 't-9'
    when 8.5..9.0
      t = 't-8'
    when 8.0..8.5
      t = 't-7'
    when 7.5..8.0
      t = 't-6'
    when 7.0..7.5
      t = 't-5'
    when 6.5..7.0
      t = 't-4'
    when 6.0..6.5
      t = 't-3'
    when 5.5..6.0
      t = 't-2'
    when 5.0..5.5
      t = 't-1'
    when 4.5..5.0
      t = 't0'
    when 4.0..4.5
      t = 't1'
    when 3.5..4.0
      t = 't2'
    when 3.0..3.5
      t = 't3'
    when 2.5..3.0
      t = 't4'
    when 2.0..2.5
      t = 't5'
    when 1.5..2.0
      t = 't6'
    when 1.0..1.5
      t = 't7'
    when 0.5..1.0
      t = 't8'
    when 0.0..0.5
      t = 't9'
    when -Float::INFINITY...0.0
      t = 't10'
    end
    t
  end
end
