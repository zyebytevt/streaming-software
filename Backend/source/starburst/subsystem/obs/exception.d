module starburst.subsystem.obs.exception;

import std.string : format;

import starburst.subsystem.obs;

@safe:

class OBSSubSystemException : Exception
{
protected:
    WebSocketCloseCode mCloseCode;

    final string getCloseReasonMessage(WebSocketCloseCode code)
    {
        final switch (code) with (WebSocketCloseCode)
        {
        case dontClose: return "'dontClose' returned.";
        case unknownReason: return "Unknown reason.";
        case messageDecodeError: return "Was unable to decode incoming message.";
        case missingDataField: return "A required data field was missing from the payload.";
        case invalidDataFieldType: return "A data field's value type is invalid.";
        case invalidDataFieldValue: return "A data field's value is invalid.";
        case unknownOpCode: return "The specified op code is invalid or missing.";
        case notIdentified: return "Send a websocket message without identifying first.";
        case alreadyIdentified: return "Tried to re-identify with an Identify message.";
        case authenticationFailed: return "The authentication attempt has failed.";
        case unsupportedRpcVersion: return "Requested RPC version not supported.";
        case sessionInvalidated: return "The websocket session has been invalidated by the server.";
        case unsupportedFeature: return "The requested feature is not supported.";
        }
    }

public:
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }

    this(WebSocketCloseCode code, string file = __FILE__, size_t line = __LINE__)
    {
        super(format!"Websocket closed: %s"(getCloseReasonMessage(code)), file, line);
        mCloseCode = code;
    }

    WebSocketCloseCode closeCode()
    {
        return mCloseCode;
    }
}