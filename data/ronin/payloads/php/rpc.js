var PHP_RPC = {
  requestMethod: "GET",

  serverURL: window.location.href,

  cwd: null,
  env: {},

  encodeRequest: function(request) {
    return window.atob($.toJSON(request));
  },

  decodeResponse: function(body) {
    var extractor = new RegExp("<rpc-response>([^<]+)<\/rpc-response>");
    var match     = body.match(extractor);

    if (match == null || match[1] == null) {
      throw "PHP-RPC Response missing";
    }

    var response = $.parseJSON(window.btoa(match[1]));

    if (response == null) {
      throw "Invalid PHP-RPC Response";
    }

    if (response.exception) { throw response.exception; }
    else                    { return response.value;    }
  },

  call: function(method,args,callback) {
    var request = {'method': method, 'arguments': args};

    if (PHP_RPC.cwd)        { request['cwd'] = PHP_RPC.cwd; }
    if (PHP_RPC.env.length) { request['env'] = PHP_RPC.env; }

    $.ajax({
      type: PHP_RPC.requestMethod,
      data: {rpc_request: encodeRequest(request)},

      success: function(data)     { callback(decodeResponse(data)); },
      error:   function(xhr,type) {
        throw "PHP-RPC Request failed to complete: " + type;
      }
    });
  }
};
