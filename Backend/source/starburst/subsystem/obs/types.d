module starburst.subsystem.obs.types;

import vibe.vibe;

// ENUMS

enum WebSocketOpCode
{
    hello = 0,
    identify = 1,
    identified = 2,
    reidentify = 3,
    event = 5,
    request = 6,
    requestResponse = 7,
    requestBatch = 8,
    requestBatchResponse = 9,
}

enum WebSocketCloseCode
{
    dontClose = 0,
    unknownReason = 4000,
    messageDecodeError = 4002,
    missingDataField = 4003,
    invalidDataFieldType = 4004,
    invalidDataFieldValue = 4005,
    unknownOpCode = 4006,
    notIdentified = 4007,
    alreadyIdentified = 4008,
    authenticationFailed = 4009,
    unsupportedRpcVersion = 4010,
    sessionInvalidated = 4011,
    unsupportedFeature = 4012,
}

enum RequestBatchExecutionType
{
    none = -1,
    serialRealtime = 0,
    serialFrame = 1,
    parallel = 2
}

enum EventSubscription
{
    none = 0,
    general = 1 << 0,
    config = 1 << 1,
    scenes = 1 << 2,
    inputs = 1 << 3,
    transitions = 1 << 4,
    filters = 1 << 5,
    outputs = 1 << 6,
    sceneItems = 1 << 7,
    mediaInputs = 1 << 8,
    vendors = 1 << 9,
    ui = 1 << 10,
    all = general | config | scenes | inputs | transitions | filters | outputs | sceneItems | mediaInputs | vendors | ui,
    inputVolumeMeters = 1 << 16,
    inputActiveStateChanged = 1 << 17,
    inputShowStateChanged = 1 << 18,
    sceneItemTransformChanged = 1 << 19,
}

enum RequestStatus
{
    unknown = 0,
    noError = 10,
    success = 100,
    missingRequestType = 203,
    unknownRequestType = 204,
    genericError = 205,
    unsupportedRequestBatchExecutionType = 206,
    missingRequestField = 300,
    missingRequestData = 301,
    invalidRequestField = 400,
    invalidRequestFieldType = 401,
    requestFieldOutOfRange = 402,
    requestFieldEmpty = 403,
    tooManyRequestFields = 404,
    outputRunning = 500,
    outputNotRunning = 501,
    outputPaused = 502,
    outputNotPaused = 504,
    studioModeActive = 505,
    studioModeNotActive = 506,
    resourceNotFound = 600,
    resourceAlreadyExists = 601,
    invalidResourceType = 602,
    notEnoughResources = 603,
    invalidResourceState = 604,
    invalidInputKind = 605,
    resourceNotConfigurable = 606,
    invalidFilterKind = 607,
    resourceCreationFailed = 700,
    resourceActionFailed = 701,
    requestProcessingFailed = 702,
    cannotAct = 703,
}

// UDAs

struct boundOpCode
{
    WebSocketOpCode opCode;
}

// MESSAGES

struct WebSocketMessage
{
    WebSocketOpCode op;
    Json d;
}

@boundOpCode(WebSocketOpCode.hello)
struct SerializedHelloData
{
    struct Authentication
    {
        string challenge;
        string salt;
    }

    string obsWebSocketVersion;
    int rpcVersion;
    @optional Authentication authentication;
}

@boundOpCode(WebSocketOpCode.identify)
struct SerializedIdentifyData
{
    int rpcVersion;
    @optional EventSubscription eventSubscriptions = EventSubscription.all;
    @optional string authentication;
}

@boundOpCode(WebSocketOpCode.identified)
struct SerializedIdentifiedData
{
    int negotiatedRpcVersion;
}

@boundOpCode(WebSocketOpCode.reidentify)
struct SerializedReidentifyData
{
    @optional EventSubscription eventSubscriptions = EventSubscription.all;
}

@boundOpCode(WebSocketOpCode.event)
struct SerializedEventData
{
    string eventType;
    EventSubscription eventIntent;
    @optional Json eventData;
}

@boundOpCode(WebSocketOpCode.request)
struct SerializedRequestData
{
    string requestType;
    string requestId;
    @optional Json requestData;
}

@boundOpCode(WebSocketOpCode.requestResponse)
struct SerializedRequestResponseData
{
    struct RequestStatusData
    {
        bool result;
        RequestStatus code;
        @optional string comment;
    }

    string requestType;
    string requestId;
    RequestStatusData requestStatus;
    @optional Json responseData;
}

@boundOpCode(WebSocketOpCode.requestBatch)
struct SerializedRequestBatchData
{
    string requestId;
    @optional bool haltOnFailure = false;
    @optional RequestBatchExecutionType executionType = RequestBatchExecutionType.serialRealtime;
    Json[] requests;
}

@boundOpCode(WebSocketOpCode.requestBatchResponse)
struct SerializedRequestBatchResponseData
{
    string requestId;
    Json[] results;
}