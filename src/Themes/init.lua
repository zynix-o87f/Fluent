local Themes = {
	Names = {
		"Dark",
		"Darker",
		"Light",
		"Aqua",
		"Amethyst",
		"Rose",
		"Ember",
		"Emerald",
		"Midnight",
		"Sakura",
		"Catppuccin Mocha",
		"Catppuccin Latte",
		"Catppuccin Frappe",
		"Catppuccin Macchiato",
		"GitHub Dark",
		"GitHub Light",
		"VS Code Dark",
		"VS Code Light",
		"Ubuntu",
		"Dracula",
		"Nord",
		"Gruvbox",
		"One Dark",
		"Solarized Dark",
		"Tokyo Night",
	},
}

for _, Theme in next, script:GetChildren() do
	local Required = require(Theme)
	Themes[Required.Name] = Required
end

return Themes
