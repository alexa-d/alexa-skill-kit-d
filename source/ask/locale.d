module ask.locale;

///
interface ITextManager
{
    ///
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
string LocaParser(E,string input)()
{
	import std.string:splitLines,strip;
	import std.algorithm:startsWith;
	import std.format:format;
	import std.array:split;

	enum string[] lines = input.splitLines;

	string res = "[";

	allMembers:
	foreach(enumMember; __traits(allMembers, E))
	{
		foreach(line; lines)
		{
			line = line.strip;

			if(line.startsWith(enumMember))
			{
				auto lineArgs = line.split(",");
				auto locaKey = lineArgs[0];
				auto locaText = line[locaKey.length+1..$].strip;
				auto entry = format("AlexaText(%s.%s, \"%s\"),", E.stringof,enumMember,locaText);
				res ~= entry ~ "\n";
				continue allMembers;
			}
		}
	}

	return res ~ "]";
}

///
unittest
{
    enum TextIds 
    {
        key1,key2
    }

	enum testCsv = "key2, foo\n key1 ,  bar  ";

    enum AlexaText[] AlexaText_test = mixin(LocaParser!(TextIds,testCsv));

    static assert(AlexaText_test[0].text == "bar");
    static assert(AlexaText_test[1].text == "foo");

    static assert(AlexaText_test[0].key == TextIds.key1);
    static assert(AlexaText_test[1].key == TextIds.key2);
}