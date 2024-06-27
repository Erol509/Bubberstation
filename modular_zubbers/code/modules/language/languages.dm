/datum/preference_middleware/languages/give_language(list/params)
	var/language_name = params["language_name"]
	var/max_languages = preferences.all_quirks.Find(TRAIT_LINGUIST) ? MAX_LANGUAGES_LINGUIST : MAX_LANGUAGES_NORMAL

	if(preferences.languages && preferences.languages.len == max_languages) // too many languages
		return TRUE

	var/datum/language/choice = tgui_input_list(
		"Understood only or Both",
		list(LANGUAGE_SPOKEN, LANGUAGE_UNDERSTOOD),
	)
	preferences.languages[name_to_language[language_name]] = choice
	return TRUE
