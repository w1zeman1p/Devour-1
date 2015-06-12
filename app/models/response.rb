class Response < ActiveRecord::Base
  validates :card_id, :quality, :e_factor, :repetitions, :next_rep, presence: true

  belongs_to :card


  def update_e_factor(quality)
    assess_response(quality)
  end

  def update_last_passed
    self.last_passed = Time.now
  end

  def assert_response
    self.e_factor = self.e_factor - 0.8 + 0.28*self.quality - 0.02*(self.quality*self.quality)
    if (self.e_factor < 1.3)
      self.e_factor = 1.3
    end
    if (quality > 1)
      self.repetitions += 1
      set_time_interval(quality)
      last_passed = Time.now
    else
      repetitions = 0
      next_rep = 1
    end
    self.save
    return self
  end

  def set_time_interval(quality)
    if (self.repetitions == 1)
      if (quality < 4)
        self.next_rep = 1
      elsif (quality < 5)
        self.next_rep = 2
      else
        self.next_rep = 3
      end
    else
      self.next_rep = (self.next_rep * self.e_factor).round
    end
  end

end