/++
 + Authors: Stephan Dilly, lastname dot firstname at gmail dot com
 + Copyright: MIT
 +/
module ask.baseintent;

import ask.alexaskill;
import ask.locale;
import ask.types;

/// abstract base class for a separate intent
abstract class BaseIntent
{
	///
	private immutable string _name;
	///
	private ITextManager _texts;
	/// allows to query for the intents string representation that needs to match intent schema
	public @property string name() const nothrow pure { return _name; }
	/// allows to define used textManager
	public @property void textManager(ITextManager _mgr) nothrow { _texts = _mgr; }

	/// c'tor
	public this()
	{
		import std.array:split;

		TypeInfo_Class info = cast(TypeInfo_Class)typeid(this);
		auto fullnameParts = info.name.split(".");
		_name = fullnameParts[$-1];
	}

	/// forwards to currently active `ITextManager.getText`
	protected string getText(int _key) const pure nothrow
	{
		return _texts.getText(_key);
	}

	/// handler that needs to be implemented in inheriting Intent
	public AlexaResult onIntent(AlexaEvent, AlexaContext);
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