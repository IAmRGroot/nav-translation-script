# nav-translator
Powershell script used for the creation of [NAV translation files](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files). This enables you to keep track of all of the translations directly in the AL code.  

## Usage

Make sure to enable the translation feature in `app.json`

```json
{
    ...
    "features": [ "TranslationFile"],
    ...
}
```

Add translations in AL code by using a comment:

```al
Caption = 'English',
    Comment = '[NLD = Dutch][NLB = Dutch Belguim]';
```

:warning: Brackets ('[' and ']') are not allowed in the translations as they (probably) break the regex that is used.

Run the script **after compiling** with `.\create_translations.ps1`.

## Parameters

Parameter | Explaination | Default
------------ | ------------- | -------------
Path | Location of the translation file (`.g.xlf`) | ./Translations
Languages | Array with languages to translate. Format is the same as the old `CaptionML` languages | NLD
Targets | Array with iso language codes. Must be equal in length as `Languages` parameter | nl-NL
CheckForError | Throws error if not all texts in the translation file have a translation | 1
OverwriteFiles | Overwrite existing translation files | 1
