# == Schema Information
#
# Table name: decks
#
#  id         :integer          not null, primary key
#  owner_id   :integer          not null
#  title      :string           not null
#  course_id  :integer
#  public     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class Deck < ActiveRecord::Base
  validates :title, :owner_id, :public, presence: true

  after_save :share_with_self

  belongs_to(
  :owner,
  class_name: 'User',
  primary_key: :id,
  foreign_key: :owner_id
  )

  has_many :deck_shares
  has_many :cards
  has_many :users, through: :deck_shares
  has_many :responses, through: :cards


  def test_stuff
    day = 60*60*24*1000
      # SELECT
      #   cards.*
      # FROM
      #   cards
      # JOIN
      #   (
    sql_str = <<-SQL
          SELECT
            responses.*
          FROM
            responses
          JOIN
          (
            SELECT
              cards.id, MAX(responses.id) as last_response
            FROM
              responses
            JOIN
              cards ON cards.id = responses.card_id
            JOIN
              users ON users.id = responses.user_id
            WHERE
              users.id = ?
            GROUP BY
              cards.id
          ) as card_responses ON card_responses.last_response = responses.id
    SQL
      #   ) as latest_responses ON cards.id = latest_responses.card_id
      # WHERE
      #   ((? - latest_responses.last_passed)/?) > latest_responses.next_rep

    Response.find_by_sql([sql_str, 1])
    # Card.find_by_sql([sql_str, 1, Time.now.to_f, day])
  end

  def review_cards_by_sql(user_id)
    day = 60*60*24*1000
    sql_str = <<-SQL
      SELECT
        cards.*
      FROM
        cards
      JOIN
        decks ON decks.id = cards.deck_id
      JOIN
        responses ON cards.id = responses.card_id
      JOIN
        users ON users.id = responses.user_id
      JOIN
        (
          SELECT
            cards.id, MAX(responses.id) as last_response
          FROM
            responses
          JOIN
            cards ON cards.id = responses.card_id
          JOIN
            users ON users.id = responses.user_id
          WHERE
            users.id = :user_id
          GROUP BY
            cards.id
        ) as card_responses
      WHERE
        users.id = :user_id AND
        (:time - responses.last_passed)/:day > card_responses.last_response
      GROUP BY
        cards.id
      HAVING

    SQL
    Card.find_by_sql(sql_str, user_id: user_id, time: Time.now.to_f, day: day)
  end

  def review_cards(user_id)
    review_array = []
    self.cards.each do |card|
      review_array.push(card) if card.needs_review?(user_id)
    end

    return review_array
  end

  def share_with_self
    DeckShare.create!(user_id: owner.id, deck_id: self.id)
  end

  def public?
    # return self['public'] == true
    #code
  end

  def self.extract_words(location)
    words = []
    file = File.open(location, 'r') do |f|
      text = f.gets
      while text
        line = text.split(" ")
          # card = Card.create!()
        words.push((line[1] + "\n"))
        text = f.gets
      end
    end
    output = File.open('./vendor/assets/extracted_text.txt', 'w') do |f2|
      words.each do |word|
        f2.write(word)
      end
    end
  end
end
