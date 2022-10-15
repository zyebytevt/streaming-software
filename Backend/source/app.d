module app;

// Remove openssl dependecy from dub.selections.json and reload import paths
// to get code completion to work
// TODO: scriptify

import std.stdio;
import std.conv : to;

import vibe.vibe;

import starburst.settings;
import starburst.subsystem.obs;

@path("/obs")
interface OBSAPI
{
@safe:
	@method(HTTPMethod.PUT) @path("/scene")
	void setScene(@viaQuery("name") string name);

	@method(HTTPMethod.GET) @path("/scene")
	string getScene();
}

class OBSAPIImpl : OBSAPI
{
protected:
	OBSWebSocketClient mClient;

public:
	this()
	{
		mClient = new OBSWebSocketClient();

		OBSWebSocketClient.ConnectArgs args;

		args.password = "WKHtaaJmk2jkxXSv";
		args.eventSubscription = EventSubscription.none;

		mClient.connect(args);
	}

	~this()
	{
		mClient.disconnect();
	}

	void setScene(string name)
	{
		mClient.sendMessageData(SerializedRequestData("SetCurrentProgramScene", "", parseJsonString(`{ "sceneName":"` ~ name ~ `" }`)));
		SerializedRequestResponseData response = mClient.receiveMessageData!SerializedRequestResponseData();
	}

	string getScene()
	{
		mClient.sendMessageData(SerializedRequestData("GetCurrentProgramScene", "", Json.emptyObject));
		SerializedRequestResponseData response = mClient.receiveMessageData!SerializedRequestResponseData();

		return response.responseData["currentProgramSceneName"].get!string;
	}
}

Settings globalSettings;

void main()
{
	globalSettings = Settings.loadFromFile("settings.json");

	auto settings = new HTTPServerSettings();
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter();
	router.registerRestInterface(new OBSAPIImpl());

	auto listener = listenHTTP(settings, router);
	scope (exit) listener.stopListening();

	runApplication();
}