module ask.ask;

import vibe.data.serialization:name,optional,byName;
import std.typecons:Nullable;

///
struct AlexaUser {
  string userId;
  @optional
  string accessToken;
}

///
struct AlexaApplication {
  string applicationId;
}

///
struct AlexaOutputSpeech {
  ///	
  enum Type
  {
    PlainText,
    SSML,
  }

  @byName
  Type type = Type.PlainText;
  string text;
  string ssml;
}

// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#card-object
///
struct AlexaCard {

  ///
  enum Type
  {
    Simple,
    Standard,
    LinkAccount
  }

  @byName
  Type type = Type.Simple;
  string title;
  string text;
  string content;

  ///
  struct Image
  {
    string smallImageUrl;
    string largeImageUrl;
  }

  Image image;
}

///
struct AlexaResponse {
  
  ///
  struct Reprompt {
    AlexaOutputSpeech outputSpeech;
  }

  AlexaOutputSpeech outputSpeech;
  AlexaCard card;
  Nullable!Reprompt reprompt;
}

///
struct AlexaResult {

  @name("version") 
  string _version = "1.0";

  string[string] sessionAttributes;
  
  bool shouldEndSession;

  AlexaResponse response;
}

//TODO:
///
/+struct AlexaDevice
{
  supportedInterfaces
}+/

//see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#context-object
///
struct AlexaRequestContext {
  
  //see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#system-object
  ///
  struct AlexaSystem
  {
    AlexaApplication application;
    AlexaUser user;
    //TODO:
    //AlexaDevice device;
  }

  ///
  struct AlexaAudioPlayer
  {
    string token;
    int offsetInMilliseconds;
    string playerActivity;
  }

 AlexaSystem System;
 AlexaAudioPlayer AudioPlayer;
}

///
struct AlexaIntent
{
  ///
  struct AlexaSlot
  {
    string name;
    @optional
    string value;
  }

  string name;

  @optional
  AlexaSlot[string] slots;
}

///
struct AlexaRequest
{
  ///
  struct Error
  {
    string type;
    string message;
  }

  string type;
  string requestId;
  string timestamp;
  string locale;

  @optional
  string reason;

  @optional
  Error error;

  @optional
  AlexaIntent intent;
}

//see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#request-format
///
struct AlexaEvent {

  ///
  struct Session {

    @name("new")
    bool _new;
    string sessionId;
    AlexaApplication application;
    @optional
    string[string] attributes;
    AlexaUser user;
  }

  @name("version") 
  string _version;

  Session session;

  AlexaRequest request;
}

///
struct AlexaContext
{
  string functionName;
  string invokedFunctionArn;
  string awsRequestId;
  string logStreamName;
  string invokeid;
  bool callbackWaitsForEmptyEventLoop;
  string logGroupName;
  string functionVersion;
  int memoryLimitInMB;
}
