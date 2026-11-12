extends RefCounted
class_name BPData

const MAPS := {
	"Foundry": {
		"title": "Foundry",
		"description": "Заброшенный промышленный комплекс с центральным цехом и архивом.",
		"objectives": ["Станция навигации", "Архивный терминал", "Маяк связи"]
	},
	"Harbor": {
		"title": "Harbor",
		"description": "Портовая зона с контейнерными площадками и старым краном.",
		"objectives": ["Станция навигации", "Архивный терминал", "Маяк связи"]
	}
}

static func map_names() -> Array[String]:
	return ["Foundry", "Harbor"]
