/++
 + Authors: Stephan Dilly, lastname dot firstname at gmail dot com
 + Copyright: MIT
 +/
module ask.alexaskill;

import vibe.d;

import ask.types;
import ask.locale;
import ask.baseintent;

/// annotation to mark an intent callback, use name to specify the exact intent name as specified in the intent schema
struct CustomIntent
{
	///
	string name;
}

/++
 + Abstract base class to inherit your skill from.
 +
 + There are two ways to implement a alexa intent:
 +	* add a @CustomIntent annotation to a method in your skill class
 +	* create an intent class inheriting from `BaseIntent` and register it using `addIntent`
 +/
abstract class AlexaSkill(T) : ITextManager
{
	///
	private AlexaText[] localeText;
	///
	private BaseIntent[] intents;

	/++
	 + constructor that requires the loca table as input
	 +
	 + params:
	 +   text = loca table to use for that request
	 +
	 + see_also:
	 +  `AlexaText`, `LocaParser`
	 +/
	public this(AlexaText[] text)
	{
		localeText = text;
	}

	///
	public int runInEventLoop(AlexaEvent event, AlexaContext context, Duration timeout = 2.seconds)
	{
		import std.stdio:writeln,stderr;

		runTask({
			scope(exit) exitEventLoop();

			stderr.writefln("execute request: %s",event.request.type);

			auto result = executeEvent(event, context);

			writeln(serializeToJson(result).toPrettyString());
		});

		setTimer(timeout, {
			writeln("{}");
			stderr.writeln("intent timeout");
			exitEventLoop();
		});

		return runEventLoop();
	}

	///
	package AlexaResult executeEvent(AlexaEvent event, AlexaContext context)
	{
		AlexaResult result;

		if(event.request.type == AlexaRequest.Type.LaunchRequest)
			result = onLaunch(event, context);
		else if(event.request.type == AlexaRequest.Type.IntentRequest)
			result = onIntent(event, context);
		else if(event.request.type == AlexaRequest.Type.SessionEndedRequest)
			onSessionEnd(event, context);

		return result;
	}

	/++
	 + adds an intent handler
	 +
	 + see_also:
	 +	`BaseIntent`
	 +/
	public void addIntent(BaseIntent intent)
	{
		intents ~= intent;
		intent.textManager = this;
	}

	/++
	 + returns the localized text string depending on the loaded locale database
	 +
	 + see_also:
	 +	`this`, `ITextManager`
	 +/
	string getText(int _key) const pure nothrow
	{
		return localeText[_key].text;
	}

	/// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/custom-standard-request-types-reference#launchrequest
	protected AlexaResult onLaunch(AlexaEvent, AlexaContext)
	{
		throw new Exception("not implemented");
	}

	/// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/custom-standard-request-types-reference#intentrequest
	private AlexaResult onIntent(AlexaEvent event, AlexaContext context)
	{
		import std.traits:hasUDA,getUDAs;

		foreach(i, member; __traits(derivedMembers, T))
		{
			enum isPublic = __traits(getProtection, __traits(getMember, cast(T)this, member)) == "public";

			static if(isPublic && hasUDA!(__traits(getMember, T, member), CustomIntent))
			{
				enum name = getUDAs!(__traits(getMember, T, member), CustomIntent)[0].name;

				if(event.request.intent.name == name)
				{
					mixin("return (cast(T)this)."~member~"(event, context);");
				}
			}
		}

		return tryRegisteredIntents(event, context);
	}

	///
	private AlexaResult tryRegisteredIntents(AlexaEvent event, AlexaContext context)
	{
		import std.stdio:stderr;

		const eventIntent = event.request.intent.name;

		foreach(baseIntent; intents)
		{
			if(baseIntent.name == eventIntent)
				return baseIntent.onIntent(event,context);
		}

		stderr.writefln("onIntent did not match: %s",eventIntent);
		return AlexaResult();
	}

	/// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/custom-standard-request-types-reference#sessionendedrequest
	protected void onSessionEnd(AlexaEvent, AlexaContext)
	{
		throw new Exception("not implemented");
	}
}
