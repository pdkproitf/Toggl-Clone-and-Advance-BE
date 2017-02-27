class TestsSerializer < ActiveModel::Serializer
    has_many :timers, serializer: TimerSerializer
    def timers
        object.timers.order('id desc')
    end

    #     def players
    #     object.players.collect { |player| [player.name, player.number, player.age]}
    # end
end
