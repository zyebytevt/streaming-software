import vibe.vibe;

// Remove openssl dependecy from dub.selections.json and reload import paths
// to get code completion to work
// TODO: scriptify

/*@path("/")
interface TestAPIInterface
{
@safe:
	// GET /api/greeting
	@property string greeting();

	// PUT /api/greeting
	@property void greeting(string text);

	// POST /api/users
	@path("/users")
	void addNewUser(string name);

	// GET /api/users
	@property string[] users();

	// GET /api/:id/name
	string getName(int id);
}

class TestAPI : TestAPIInterface
{
@safe:
	private {
		string m_greeting;
		string[] m_users;
	}

	@property string greeting() { return m_greeting; }
	@property void greeting(string text) { m_greeting = text; }

	void addNewUser(string name) { m_users ~= name; }

	@property string[] users() { return m_users; }

	string getName(int id) { return m_users[id]; }
}

void main()
{
	auto settings = new HTTPServerSettings();
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter();
	router.registerRestInterface(new TestAPI());

	auto listener = listenHTTP(settings, router);
	scope (exit)
	{
		listener.stopListening();
	}

	runApplication();
}*/

import std.stdio;
import std.conv : to;

import obs;

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
		mClient.password = "Ztx0kvDzVlZaYwQZ";
		mClient.eventSubscription = OBSEventSubscription.none;

		mClient.connect();
	}

	~this()
	{
		mClient.disconnect();
	}

	void setScene(string name)
	{
		mClient.sendData(OBSMessageDataRequest("SetCurrentProgramScene", "", parseJsonString(`{ "sceneName":"` ~ name ~ `" }`)));
		OBSMessageDataRequestResponse response = mClient.receiveData!OBSMessageDataRequestResponse();
	}

	string getScene()
	{
		mClient.sendData(OBSMessageDataRequest("GetCurrentProgramScene", "", Json.emptyObject));
		OBSMessageDataRequestResponse response = mClient.receiveData!OBSMessageDataRequestResponse();

		return response.responseData["currentProgramSceneName"].get!string;
	}
}

void main()
{
	auto settings = new HTTPServerSettings();
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter();
	router.registerRestInterface(new OBSAPIImpl());

	auto listener = listenHTTP(settings, router);
	scope (exit) listener.stopListening();

	runApplication();
}