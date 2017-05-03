/++
 + Authors: Stephan Dilly, lastname dot firstname at gmail dot com
 + Copyright: MIT
 +/
module ask.locale;

///
interface ITextManager
{
	/++
	 + returns the localized text string depending on the loaded locale database
	 +
	 + params:
	 +	_key = loca lookup key
	 +
	 + see_also:
	 +	`this`, `AlexaText`, `LocaParser`
	 +/
	string getText(int _key) const pure nothrow;
}

///
struct AlexaText
{
	///
	int key;
	///
	string text;
}

/// template to parse csv of loca entries
string LocaParser(E, string input)()
{
	import std.string : splitLines, strip;
	import std.algorithm : startsWith;
	import std.format : format;
	import std.array : split;

	enum string[] lines = input.splitLines;

	string res = "[";

	allMembers: foreach (enumMember; __traits(allMembers, E))
	{
		bool found = false;

		foreach (line; lines)
		{
			line = line.strip;

			if (line.startsWith(enumMember))
			{
				auto lineArgs = line.split(",");
				auto locaKey = lineArgs[0];
				auto locaText = line[locaKey.length + 1 .. $].strip;
				auto entry = format("AlexaText(%s.%s, \"%s\"),", E.stringof, enumMember, locaText);
				res ~= entry ~ "\n";
				found = true;
				continue allMembers;
			}
		}

		assert(found, "" ~ format("loca key '%s' not found", enumMember));
	}

	return res ~ "]";
}

///
unittest
{
	enum TextIds
	{
		key1,
		key2,
	}

	enum testCsv = "key2, foo\n key1 ,  bar, 2  ";

	enum AlexaText[] AlexaText_test = mixin(LocaParser!(TextIds, testCsv));

	static assert(AlexaText_test[0].text == "bar, 2");
	static assert(AlexaText_test[1].text == "foo");

	static assert(AlexaText_test[0].key == TextIds.key1);
	static assert(AlexaText_test[1].key == TextIds.key2);
}
