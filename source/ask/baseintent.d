module ask.baseintent;

import ask.alexaskill;
import ask.locale;
import ask.types;

///
abstract class BaseIntent
{
	///
	immutable string name;
	///
	ITextManager texts;

	///
	this()
	{
		import std.array:split;

		TypeInfo_Class info = cast(TypeInfo_Class)typeid(this);
		auto fullnameParts = info.name.split(".");
		this.name = fullnameParts[$-1];
	}

	///
	string getText(int _key) const pure nothrow
	{
		return texts.getText(_key);
	}

	///
	AlexaResult onIntent(AlexaEvent, AlexaContext);
}

///
unittest
{
	class TestIntent : BaseIntent{
		override AlexaResult onIntent(AlexaEvent, AlexaContext){
			AlexaResult res;
			res._version = "v3";
			return res;
		}
	}

	class TestSkill : AlexaSkill!TestSkill{
		this(){
			super([]);
			addIntent(new TestIntent);
		}
	}

	auto skill = new TestSkill();
	AlexaEvent ev;
	ev.request.type = AlexaRequest.Type.IntentRequest;
	ev.request.intent.name = "TestIntent";
	auto res = skill.executeEvent(ev,AlexaContext());
	assert(res._version == "v3");
}