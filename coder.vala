public class spliter {

public static void main (string[] args) {


 	string[] lines = file.split ("\n", -1);
 	string group = "";

 	foreach (var line in lines) {
 		var part = line.split (":");

 		if (part[0].contains ("#")) {
 			group = part[1];
 			stdout.printf ("""languages.set ("%s", dgettext ("xkeyboard-config","%s"));\n""", part[1], part[0].replace ("#",""));
 		} else {
 			stdout.printf ("""languages.set ("%s+%s", dgettext ("xkeyboard-config","%s"));\n""", group, part[1], part[0].replace ("#",""));
 		}

 		//languages.set ("latam", _("Spanish (Latin America)"));
 	}
}

static const string file =
"""#Afghani:af
Pashto (Afghanistan, OLPC):olpc-ps
Pashto:ps
Persian (Afghanistan, Dari OLPC):fa-olpc
Uzbek (Afghanistan):uz
Uzbek (Afghanistan, OLPC):uz-olpc
#Albanian:al
#Amharic:et
#Arabic (Morocco):ma
Berber (Morocco, Tifinagh alternative phonetic):tifinagh-alt-phonetic
Berber (Morocco, Tifinagh alternative):tifinagh-alt
Berber (Morocco, Tifinagh extended phonetic):tifinagh-extended-phonetic
Berber (Morocco, Tifinagh extended):tifinagh-extended
Berber (Morocco, Tifinagh phonetic):tifinagh-phonetic
Berber (Morocco, Tifinagh):tifinagh
French (Morocco):french
#Arabic (Syria):sy
Kurdish (Syria, F):ku_f
Kurdish (Syria, Latin Alt-Q):ku_alt
Kurdish (Syria, Latin Q):ku
Syriac (phonetic):syc_phonetic
Syriac:syc
#Arabic:ara
Arabic (Buckwalter):buckwalter
Arabic (azerty):azerty
Arabic (azerty/digits):azerty_digits
Arabic (digits):digits
Arabic (qwerty):qwerty
Arabic (qwerty/digits):qwerty_digits
#Armenian:am
Armenian (alternative eastern):eastern-alt
Armenian (alternative phonetic):phonetic-alt
Armenian (eastern):eastern
Armenian (phonetic):phonetic
Armenian (western):western
#Azerbaijani:az
Azerbaijani (Cyrillic):cyrillic
#Bambara:ml
English (Mali, US Macintosh):us-mac
English (Mali, US international):us-intl
French (Mali, alternative):fr-oss
#Belarusian:by
Belarusian (Latin):latin
Belarusian (legacy):legacy
#Belgian:be
Belgian (ISO alternate):iso-alternate
Belgian (Sun dead keys):sundeadkeys
Belgian (Wang model 724 azerty):wang
Belgian (alternative):oss
Belgian (alternative, Sun dead keys):oss_sundeadkeys
Belgian (alternative, latin-9 only):oss_latin9
Belgian (eliminate dead keys):nodeadkeys
#Bengali:bd
Bengali (Probhat):probhat
#Bosnian:ba
Bosnian (US keyboard with Bosnian digraphs):unicodeus
Bosnian (US keyboard with Bosnian letters):us
Bosnian (use Bosnian digraphs):unicode
Bosnian (use guillemets for quotes):alternatequotes
#Braille:brai
Braille (left hand):left_hand
Braille (right hand):right_hand
#Bulgarian:bg
Bulgarian (new phonetic):bas_phonetic
Bulgarian (traditional phonetic):phonetic
#Burmese:mm
#Catalan:ad
#Chinese:cn
Tibetan (with ASCII numerals):tib_asciinum
Tibetan:tib
Uyghur:uig
#Croatian:hr
Croatian (US keyboard with Croatian digraphs):unicodeus
Croatian (US keyboard with Croatian letters):us
Croatian (use Croatian digraphs):unicode
Croatian (use guillemets for quotes):alternatequotes
#Czech:cz
Czech (UCW layout, accented letters only):ucw
Czech (US Dvorak with CZ UCW support):dvorak-ucw
Czech (qwerty):qwerty
Czech (qwerty, extended Backslash):qwerty_bksl
Czech (with <\|> key):bksl
#Danish:dk
Danish (Dvorak):dvorak
Danish (Macintosh):mac
Danish (Macintosh, eliminate dead keys):mac_nodeadkeys
Danish (eliminate dead keys):nodeadkeys
#Dhivehi:mv
#Dutch:nl
Dutch (Macintosh):mac
Dutch (Sun dead keys):sundeadkeys
Dutch (standard):std
#Dzongkha:bt
#English (Cameroon):cm
Cameroon Multilingual (Dvorak):dvorak
Cameroon Multilingual (azerty):azerty
Cameroon Multilingual (qwerty):qwerty
French (Cameroon):french
#English (Ghana):gh
Akan:akan
Avatime:avn
English (Ghana, GILLBT):gillbt
English (Ghana, multilingual):generic
Ewe:ewe
Fula:fula
Ga:ga
Hausa:hausa
#English (Nigeria):ng
Hausa:hausa
Igbo:igbo
Yoruba:yoruba
#English (South Africa):za
#English (UK):gb
English (UK, Colemak):colemak
English (UK, Dvorak with UK punctuation):dvorakukp
English (UK, Dvorak):dvorak
English (UK, Macintosh international):mac_intl
English (UK, Macintosh):mac
English (UK, extended WinKeys):extd
English (UK, international with dead keys):intl
#English (US):us
Cherokee:chr
English (Colemak):colemak
English (Dvorak alternative international no dead keys):dvorak-alt-intl
English (Dvorak international with dead keys):dvorak-intl
English (Dvorak):dvorak
English (Macintosh):mac
English (US, alternative international):alt-intl
English (US, international with dead keys):intl
English (US, with euro on 5):euro
English (classic Dvorak):dvorak-classic
English (international AltGr dead keys):altgr-intl
English (layout toggle on multiply/divide key):olpc2
English (left handed Dvorak):dvorak-l
English (programmer Dvorak):dvp
English (right handed Dvorak):dvorak-r
Russian (US, phonetic):rus
Serbo-Croatian (US):hbs
#Esperanto:epo
Esperanto (displaced semicolon and quote, obsolete):legacy
#Estonian:ee
Estonian (Dvorak):dvorak
Estonian (US keyboard with Estonian letters):us
Estonian (eliminate dead keys):nodeadkeys
#Faroese:fo
Faroese (eliminate dead keys):nodeadkeys
#Filipino:ph
Filipino (Capewell-Dvorak Baybayin):capewell-dvorak-bay
Filipino (Capewell-Dvorak Latin):capewell-dvorak
Filipino (Capewell-QWERF 2006 Baybayin):capewell-qwerf2k6-bay
Filipino (Capewell-QWERF 2006 Latin):capewell-qwerf2k6
Filipino (Colemak Baybayin):colemak-bay
Filipino (Colemak Latin):colemak
Filipino (Dvorak Baybayin):dvorak-bay
Filipino (Dvorak Latin):dvorak
Filipino (QWERTY Baybayin):qwerty-bay
#Finnish:fi
Finnish (Macintosh):mac
Finnish (classic):classic
Finnish (classic, eliminate dead keys):nodeadkeys
Northern Saami (Finland):smi
#French (Canada):ca
Canadian Multilingual (first part):multi
Canadian Multilingual (second part):multi-2gr
Canadian Multilingual:multix
English (Canada):eng
French (Canada, Dvorak):fr-dvorak
French (Canada, legacy):fr-legacy
Inuktitut:ike
#French (Democratic Republic of the Congo):cd
#French (Guinea):gn
#French:fr
French (Bepo, ergonomic, Dvorak way):bepo
French (Bepo, ergonomic, Dvorak way, latin-9 only):bepo_latin9
French (Breton):bre
French (Dvorak):dvorak
French (Macintosh):mac
French (Sun dead keys):sundeadkeys
French (alternative):oss
French (alternative, Sun dead keys):oss_sundeadkeys
French (alternative, eliminate dead keys):oss_nodeadkeys
French (alternative, latin-9 only):oss_latin9
French (eliminate dead keys):nodeadkeys
French (legacy, alternative):latin9
French (legacy, alternative, Sun dead keys):latin9_sundeadkeys
French (legacy, alternative, eliminate dead keys):latin9_nodeadkeys
Georgian (France, AZERTY Tskapo):geo
Occitan:oci
#Georgian:ge
Georgian (MESS):mess
Georgian (ergonomic):ergonomic
Ossetian (Georgia):os
Russian (Georgia):ru
#German (Austria):at
German (Austria, Macintosh):mac
German (Austria, Sun dead keys):sundeadkeys
German (Austria, eliminate dead keys):nodeadkeys
#German (Switzerland):ch
French (Switzerland):fr
French (Switzerland, Macintosh):fr_mac
French (Switzerland, Sun dead keys):fr_sundeadkeys
French (Switzerland, eliminate dead keys):fr_nodeadkeys
German (Switzerland, Macintosh):de_mac
German (Switzerland, Sun dead keys):de_sundeadkeys
German (Switzerland, eliminate dead keys):de_nodeadkeys
German (Switzerland, legacy):legacy
#German:de
German (Dvorak):dvorak
German (Macintosh):mac
German (Macintosh, eliminate dead keys):mac_nodeadkeys
German (Neo 2):neo
German (Sun dead keys):sundeadkeys
German (dead acute):deadacute
German (dead grave acute):deadgraveacute
German (eliminate dead keys):nodeadkeys
Lower Sorbian (qwertz):dsb_qwertz
Lower Sorbian:dsb
Romanian (Germany):ro
Romanian (Germany, eliminate dead keys):ro_nodeadkeys
Russian (Germany, phonetic):ru
#Greek:gr
Greek (eliminate dead keys):nodeadkeys
Greek (extended):extended
Greek (polytonic):polytonic
Greek (simple):simple
#Hebrew:il
Hebrew (Biblical, Tiro):biblical
Hebrew (lyx):lyx
Hebrew (phonetic):phonetic
#Hungarian:hu
Hungarian (101/qwerty/comma/dead keys):101_qwerty_comma_dead
Hungarian (101/qwerty/comma/eliminate dead keys):101_qwerty_comma_nodead
Hungarian (101/qwerty/dot/dead keys):101_qwerty_dot_dead
Hungarian (101/qwerty/dot/eliminate dead keys):101_qwerty_dot_nodead
Hungarian (101/qwertz/comma/dead keys):101_qwertz_comma_dead
Hungarian (101/qwertz/comma/eliminate dead keys):101_qwertz_comma_nodead
Hungarian (101/qwertz/dot/dead keys):101_qwertz_dot_dead
Hungarian (101/qwertz/dot/eliminate dead keys):101_qwertz_dot_nodead
Hungarian (102/qwerty/comma/dead keys):102_qwerty_comma_dead
Hungarian (102/qwerty/comma/eliminate dead keys):102_qwerty_comma_nodead
Hungarian (102/qwerty/dot/dead keys):102_qwerty_dot_dead
Hungarian (102/qwerty/dot/eliminate dead keys):102_qwerty_dot_nodead
Hungarian (102/qwertz/comma/dead keys):102_qwertz_comma_dead
Hungarian (102/qwertz/comma/eliminate dead keys):102_qwertz_comma_nodead
Hungarian (102/qwertz/dot/dead keys):102_qwertz_dot_dead
Hungarian (102/qwertz/dot/eliminate dead keys):102_qwertz_dot_nodead
Hungarian (eliminate dead keys):nodeadkeys
Hungarian (qwerty):qwerty
Hungarian (standard):standard
#Icelandic:is
Icelandic (Dvorak):dvorak
Icelandic (Macintosh):mac
Icelandic (Sun dead keys):Sundeadkeys
Icelandic (eliminate dead keys):nodeadkeys
#Indian:in
Bengali (India):ben
Bengali (India, Baishakhi Inscript):ben_inscript
Bengali (India, Baishakhi):ben_baishakhi
Bengali (India, Bornona):ben_bornona
Bengali (India, Probhat):ben_probhat
Bengali (India, Uni Gitanjali):ben_gitanjali
English (India, with RupeeSign):eng
Gujarati:guj
Hindi (Bolnagri):bolnagri
Hindi (Wx):hin-wx
Kannada:kan
Malayalam (Lalitha):mal_lalitha
Malayalam (enhanced Inscript with Rupee Sign):mal_enhanced
Malayalam:mal
Oriya:ori
Punjabi (Gurmukhi Jhelum):jhelum
Punjabi (Gurmukhi):guru
Tamil (TAB typewriter):tam_TAB
Tamil (TSCII typewriter):tam_TSCII
Tamil (Unicode):tam_unicode
Tamil (keyboard with numerals):tam_keyboard_with_numerals
Tamil:tam
Telugu:tel
Urdu (WinKeys):urd-winkeys
Urdu (alternative phonetic):urd-phonetic3
Urdu (phonetic):urd-phonetic
#Iraqi:iq
Kurdish (Iraq, Arabic-Latin):ku_ara
Kurdish (Iraq, F):ku_f
Kurdish (Iraq, Latin Alt-Q):ku_alt
Kurdish (Iraq, Latin Q):ku
#Irish:ie
CloGaelach:CloGaelach
Irish (UnicodeExpert):UnicodeExpert
Ogham (IS434):ogam_is434
Ogham:ogam
#Italian:it
Georgian (Italy):geo
Italian (Macintosh):mac
Italian (US keyboard with Italian letters):us
Italian (eliminate dead keys):nodeadkeys
#Japanese (PC-98xx Series):nec_vndr/jp
#Japanese:jp
Japanese (Kana 86):kana86
Japanese (Kana):kana
Japanese (Macintosh):mac
Japanese (OADG 109A):OADG109A
#Kazakh:kz
Kazakh (with Russian):kazrus
Russian (Kazakhstan, with Kazakh):ruskaz
#Khmer (Cambodia):kh
#Korean:kr
Korean (101/104 key compatible):kr104
#Kyrgyz:kg
Kyrgyz (phonetic):phonetic
#Lao:la
Lao (STEA proposed standard layout):stea
#Latvian:lv
Latvian (F variant):fkey
Latvian (adapted):adapted
Latvian (apostrophe variant):apostrophe
Latvian (ergonomic, ŪGJRMV):ergonomic
Latvian (modern):modern
Latvian (tilde variant):tilde
#Lithuanian:lt
Lithuanian (IBM LST 1205-92):ibm
Lithuanian (LEKP):lekp
Lithuanian (LEKPa):lekpa
Lithuanian (US keyboard with Lithuanian letters):us
Lithuanian (standard):std
#Macedonian:mk
Macedonian (eliminate dead keys):nodeadkeys
#Maltese:mt
Maltese (with US layout):us
#Maori:mao
#Mongolian:mn
#Montenegrin:me
Montenegrin (Cyrillic with guillemets):cyrillicalternatequotes
Montenegrin (Cyrillic):cyrillic
Montenegrin (Cyrillic, Z and ZHE swapped):cyrillicyz
Montenegrin (Latin Unicode qwerty):latinunicodeyz
Montenegrin (Latin Unicode):latinunicode
Montenegrin (Latin qwerty):latinyz
Montenegrin (Latin with guillemets):latinalternatequotes
#Nepali:np
#Norwegian:no
Northern Saami (Norway):smi
Northern Saami (Norway, eliminate dead keys):smi_nodeadkeys
Norwegian (Dvorak):dvorak
Norwegian (Macintosh):mac
Norwegian (Macintosh, eliminate dead keys):mac_nodeadkeys
Norwegian (eliminate dead keys):nodeadkeys
#Persian:ir
Kurdish (Iran, Arabic-Latin):ku_ara
Kurdish (Iran, F):ku_f
Kurdish (Iran, Latin Alt-Q):ku_alt
Kurdish (Iran, Latin Q):ku
Persian (with Persian Keypad):pes_keypad
#Polish:pl
Kashubian:csb
Polish (Dvorak):dvorak
Polish (Dvorak, Polish quotes on key 1):dvorak_altquotes
Polish (Dvorak, Polish quotes on quotemark key):dvorak_quotes
Polish (programmer Dvorak):dvp
Polish (qwertz):qwertz
Russian (Poland, phonetic Dvorak):ru_phonetic_dvorak
#Portuguese (Brazil):br
Portuguese (Brazil, Dvorak):dvorak
Portuguese (Brazil, eliminate dead keys):nodeadkeys
Portuguese (Brazil, nativo for Esperanto):nativo-epo
Portuguese (Brazil, nativo for USA keyboards):nativo-us
Portuguese (Brazil, nativo):nativo
#Portuguese:pt
Esperanto (Portugal, Nativo):nativo-epo
Portuguese (Macintosh):mac
Portuguese (Macintosh, Sun dead keys):mac_sundeadkeys
Portuguese (Macintosh, eliminate dead keys):mac_nodeadkeys
Portuguese (Nativo for USA keyboards):nativo-us
Portuguese (Nativo):nativo
Portuguese (Sun dead keys):sundeadkeys
Portuguese (eliminate dead keys):nodeadkeys
#Romanian:ro
Romanian (WinKeys):winkeys
Romanian (cedilla):cedilla
Romanian (standard cedilla):std_cedilla
Romanian (standard):std
#Russian:ru
Bashkirian:bak
Chuvash (Latin):cv_latin
Chuvash:cv
Kalmyk:xal
Komi:kom
Mari:chm
Ossetian (WinKeys):os_winkeys
Ossetian (legacy):os_legacy
Russian (DOS):dos
Russian (legacy):legacy
Russian (phonetic WinKeys):phonetic_winkeys
Russian (phonetic):phonetic
Russian (typewriter):typewriter
Russian (typewriter, legacy):typewriter-legacy
Serbian (Russia):srp
Tatar:tt
Udmurt:udm
Yakut:sah
#Serbian (Cyrillic):rs
Pannonian Rusyn (homophonic):rue
Serbian (Cyrillic with guillemets):alternatequotes
Serbian (Cyrillic, Z and ZHE swapped):yz
Serbian (Latin Unicode qwerty):latinunicodeyz
Serbian (Latin Unicode):latinunicode
Serbian (Latin qwerty):latinyz
Serbian (Latin with guillemets):latinalternatequotes
Serbian (Latin):latin
#Sinhala (phonetic):lk
Tamil (Sri Lanka, TAB Typewriter):tam_TAB
Tamil (Sri Lanka, Unicode):tam_unicode
#Slovak:sk
Slovak (extended Backslash):bksl
Slovak (qwerty):qwerty
Slovak (qwerty, extended Backslash):qwerty_bksl
#Slovenian:si
Slovenian (US keyboard with Slovenian letters):us
Slovenian (use guillemets for quotes):alternatequotes
#Spanish (Latin American):latam
Spanish (Latin American, Sun dead keys):sundeadkeys
Spanish (Latin American, eliminate dead keys):nodeadkeys
Spanish (Latin American, include dead tilde):deadtilde
#Spanish:es
Asturian (Spain, with bottom-dot H and bottom-dot L):ast
Catalan (Spain, with middle-dot L):cat
Spanish (Dvorak):dvorak
Spanish (Macintosh):mac
Spanish (Sun dead keys):sundeadkeys
Spanish (eliminate dead keys):nodeadkeys
Spanish (include dead tilde):deadtilde
#Swahili (Kenya):ke
Kikuyu:kik
#Swahili (Tanzania):tz
#Swedish:se
Northern Saami (Sweden):smi
Russian (Sweden, phonetic):rus
Russian (Sweden, phonetic, eliminate dead keys):rus_nodeadkeys
Swedish (Dvorak):dvorak
Swedish (Macintosh):mac
Swedish (Svdvorak):svdvorak
Swedish (eliminate dead keys):nodeadkeys
Swedish Sign Language:swl
#Taiwanese:tw
Saisiyat (Taiwan):saisiyat
Taiwanese (indigenous):indigenous
#Tajik:tj
Tajik (legacy):legacy
#Thai:th
Thai (Pattachote):pat
Thai (TIS-820.2538):tis
#Tswana:bw
#Turkish:tr
Crimean Tatar (Turkish Alt-Q):crh_alt
Crimean Tatar (Turkish F):crh_f
Crimean Tatar (Turkish Q):crh
Kurdish (Turkey, F):ku_f
Kurdish (Turkey, Latin Alt-Q):ku_alt
Kurdish (Turkey, Latin Q):ku
Turkish (Alt-Q):alt
Turkish (F):f
Turkish (Sun dead keys):sundeadkeys
Turkish (international with dead keys):intl
#Turkmen:tm
Turkmen (Alt-Q):alt
#Ukrainian:ua
Russian (Ukraine, standard RSTU):rstu_ru
Ukrainian (WinKeys):winkeys
Ukrainian (homophonic):homophonic
Ukrainian (legacy):legacy
Ukrainian (phonetic):phonetic
Ukrainian (standard RSTU):rstu
Ukrainian (typewriter):typewriter
#Urdu (Pakistan):pk
Arabic (Pakistan):ara
Sindhi:snd
Urdu (Pakistan, CRULP):urd-crulp
Urdu (Pakistan, NLA):urd-nla
#Uzbek:uz
Uzbek (Latin):latin
#Vietnamese:vn
#Wolof:sn""";
}




