local BigButton = Button:extend('BigButton')

BigButton.slice = false
BigButton.fontSize = 36
BigButton.fontOffsets = {
	hovering = {x = 0; y = -5};
	normal = {x = 0; y = -5};
	down = {x = 0; y = -4};
}
BigButton.textureNames = {
	hovering = 'options_backtogamebutton0';
	normal = 'options_backtogamebutton0';
	down = 'options_backtogamebutton2';
}
BigButton.buttonOffsets = {}
BigButton.defaultOffsets = {x = 0; y = 0}

return BigButton