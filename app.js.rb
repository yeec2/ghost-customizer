require 'ostruct'
require 'native'
# to compile: opal -c app.js.rb > app.js
# doc: https://opalrb.com/

### --------------------------- ###
### Define available selections ###
### --------------------------- ###
death_year = (1800..2020).to_a
personality = ["Spirited", "Haunting", "Transparent"]
alignment = [
  "Lawful good", "Neutral good", "Chaotic good",
  "Lawful neutral", "True neutral", "Chaotic neutral",
  "Lawful evil", "Neutral evil", "Chaotic evil",
]
face = (1..7).map { |i| "##{i}" }
colour = ["#FFC996", "#FF8474", "#9F5F80", "#583D72"]
occupation = [ "Unemployed", "Student", "Librarian", "Musician", "Gamer", "Customer Service", "McDonald's" ]

# map containing all available options to select from.
# note that the order affects how the selections are displayed & calculated
all_selections = {
  death_year: death_year,
  personality: personality,
  alignment: alignment,
  face: face,
  colour: colour,
  occupation: occupation
}
# total no. of possible selections = product of length of all arrays
total_selections_count = all_selections.values.map { |x| x.length }.reduce(:*)


### ------------------------------------- ###
### Method to update UI with slider value ###
### ------------------------------------- ###
def update(num, total_selections_count, all_selections)
  num -= 1  # num range from 0 to total_selections_count-1

  result = {}
  i = total_selections_count
  
  # calculate expected value for each selection
  for k in all_selections.keys
    i = (i / all_selections[k].length).to_i
    q, r = num.divmod(i)
    num = r
    result[k] = all_selections[k][q]
  end

  result.each do |k, v|
    $$[:document].getElementById("#{k}Col").innerHTML = "#{v}"
  end

  # update colour and image using values from :colour and :face respectively
  $$[:document].getElementById("characterContainer").style.backgroundColor = result[:colour]
  $$[:document].getElementById("characterContainer").style.backgroundImage = "url('img/ghost#{result[:face][1..-1]}.png')"
end

### ------------------------ ###
### Initialize UI components ###
### ------------------------ ###
# table rows
stats_table = $$[:document].getElementById("statsTable")
stats_table.innerHTML = all_selections.keys.map { |k| "<tr><td>#{k.split('_').join(' ').capitalize}</td><td class='statsResult' id='#{k}Col'></td></tr>" }.join("")

# slider
slider_container = $$[:document].getElementById("sliderContainer")
slider_container.innerHTML = %{
  <button id='minusBtn' class='buttonClass'>-</button>
  <input type='range' min='1' max='#{total_selections_count}' value='0' class='sliderClass' id='slider'>
  <button id='plusBtn' class='buttonClass'>+</button>
}

# click event for slider
the_slider = $$[:document].getElementById("slider")
the_slider.addEventListener :input do |event|
  update(the_slider.value.to_i, total_selections_count, all_selections)
end

# click events for the - and + buttons
minus_btn = $$[:document].getElementById("minusBtn")
minus_btn.addEventListener :click do |event|
  slider_value = $$[:document].getElementById("slider").value.to_i
  if slider_value > 1 # slider value range from 1 to total_selections_count
    $$[:document].getElementById("slider").value = slider_value - 1
    update(slider_value - 1, total_selections_count, all_selections)
  end
end

plus_btn = $$[:document].getElementById("plusBtn")
plus_btn.addEventListener :click do |event|
  slider_value = $$[:document].getElementById("slider").value.to_i
  if slider_value < total_selections_count # slider value range from 1 to total_selections_count
    $$[:document].getElementById("slider").value = slider_value + 1
    update(slider_value + 1, total_selections_count, all_selections)
  end
end

# click event for the create button
btn = $$[:document].getElementById("createBtn")
btn.addEventListener :click do |event|
  result = all_selections.each_key.map do |k|
    v = $$[:document].getElementById("#{k}Col").innerHTML
    "#{k.split('_').join(' ').capitalize}: #{v}"
  end.to_a.join('; ')
  txt = $$[:document].getElementById("createdContainer").innerHTML
  $$[:document].getElementById("createdContainer").innerHTML = "Created: #{result}<br />#{txt}"
end

# populate with slider value 1 as default
update(1, total_selections_count, all_selections)

p "Successfully initialized"