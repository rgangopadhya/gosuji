if @just_entered_scoring_phase
  json.just_entered_scoring_phase true
  json.instructions scoring_instructions
  json.form_action mark_stones_game_path(@game)
  json.status_message "Time to score the game!"
end

json.points do
  json.black @game.black_point_count
  json.white @game.white_point_count
end

json.tiles @tiles do |tile|
  json.pos tile.pos
  json.classes tile.container_classes
  json.image_src image_path(tile.display_image_path)
end
