// Generated by CoffeeScript 1.8.0
(function() {
  "use strict";
  var globals, nonAsyncCount, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  globals = {
    '../vendor/underscore/underscore.js': '_'
  };

  window.require = function(path, herp) {
    var ext, name, _ref;
    if ((herp != null)) {
      path = herp;
    }
    if (path in globals) {
      return window[globals[path]];
    }
    _ref = BrowserFS.node.path.basename(path).split('.'), name = _ref[0], ext = _ref[1];
    return window[name] != null ? window[name] : window[name] = {};
  };

  nonAsyncCount = 0;

  root.asyncExecute = function(fn) {
    if ((typeof document !== "undefined" && document !== null) && (document.hidden || document.mozHidden || document.webkitHidden || document.msHidden) && nonAsyncCount++ < 10000) {
      return fn();
    } else {
      nonAsyncCount = 0;
      return setImmediate(fn);
    }
  };

  window.onerror = function(msg, url, line) {
    var progress;
    window.onerror = null;
    if (typeof console !== "undefined" && console !== null) {
      console.log(arguments);
    }
    progress = $("#progress");
    if ((progress != null ? progress.length : void 0) > 0) {
      progress.html("Ooops!<br>Note for developers (" + msg + ":" + url + " at line " + line + ")");
    }
    if (window.location.hostname === 'localhost') {
      alert("" + msg + "\n+" + url + " " + line);
    }
    return false;
  };

}).call(this);
