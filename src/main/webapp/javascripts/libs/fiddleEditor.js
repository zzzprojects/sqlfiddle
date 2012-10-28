define(["CodeMirror", "MySQLCodeMirror", "jQuery"], function (CodeMirror, myMode, $){ 
	
	var fiddleEditor = function (domID, changeHandler, viewRef, runHandler) {
		this.codeMirrorSupported = !( /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) );
		
		if (this.codeMirrorSupported)
		{
			this.codeMirror = CodeMirror.fromTextArea(document.getElementById(domID), {
				mode: "mysql",
				matchBrackets: true,
				extraKeys: {Tab: "indentMore"},
				lineNumbers: true,
				onChange: function(){ changeHandler.call(viewRef) }
			  });
			$(this.codeMirror.getWrapperElement()).on("keypress", function (e) {
				if (e.keyCode == 13 && e.ctrlKey && runHandler)
				{
					e.preventDefault();
					runHandler();
				}
			})
		}
		else
		{
			this.textArea = document.getElementById(domID);
			$(this.textArea).on('change', function(){ changeHandler.call(viewRef) });
			$(this.textArea).on('keyup', function(){ changeHandler.call(viewRef) });
			$(this.textArea).on('keypress', function(e){
				if (e.keyCode == 13 && e.ctrlKey && runHandler)
				{
					e.preventDefault();
					runHandler();
				}
			});
			
			$(this.textArea).attr('fullscreen',false);
		}
		
		return this;
	};
	fiddleEditor.prototype.getValue = function () {
		if (this.codeMirrorSupported) return this.codeMirror.getValue();
		else return this.textArea.value;
	}
	fiddleEditor.prototype.setValue = function(val) {
		if (this.codeMirrorSupported) this.codeMirror.setValue(val);
		else { 
			this.textArea.value = val;
			$(this.textArea).trigger('change');
		}
	}
	fiddleEditor.prototype.refresh = function() {
		if (this.codeMirrorSupported) this.codeMirror.refresh();
		else { /* NOOP */ }
	}
	fiddleEditor.prototype.somethingSelected = function() {
		if (this.codeMirrorSupported) return this.codeMirror.somethingSelected();
		else { return false }
	}
	fiddleEditor.prototype.getSelection = function() {
		if (this.codeMirrorSupported) return this.codeMirror.getSelection();
		else { return this.textArea.value }
	}
	fiddleEditor.prototype.getScrollerElement = function () {
		if (this.codeMirrorSupported) return this.codeMirror.getScrollerElement();
		else { return null }
	}
	fiddleEditor.prototype.getGutterElement = function () {
		if (this.codeMirrorSupported) return this.codeMirror.getGutterElement();
		else { return null }
	}
	fiddleEditor.prototype.isFullscreen = function () {
		if (this.codeMirrorSupported) return $(this.codeMirror.getScrollerElement()).hasClass('CodeMirror-fullscreen')
		else { return  $(this.textArea).attr('fullscreen') == true; }
	}
	fiddleEditor.prototype.setFullscreen = function (fullscreenMode) {
		if (fullscreenMode)
		{
			var wHeight = $(window).height() - 40;
			if (this.codeMirrorSupported)
			{
				$(this.codeMirror.getScrollerElement()).addClass('CodeMirror-fullscreen').height(wHeight);
				$(this.codeMirror.getGutterElement()).height(wHeight);
			}
			else
			{
				$(this.textArea).addClass('fullscreen');
				$(this.textArea).height(wHeight);
				$(this.textArea).attr('fullscreen', fullscreenMode);
			}
		}
		else
		{
			if (this.codeMirrorSupported)
			{
				$(this.codeMirror.getScrollerElement()).removeClass('CodeMirror-fullscreen');
				$(this.codeMirror.getGutterElement()).css('height', 'auto');
				$(this.codeMirror.getScrollerElement()).css('height', '200px');
			}
			else
			{
				$(this.textArea).removeClass('fullscreen');

				$(this.textArea).height(100);
				$(this.textArea).attr('fullscreen', fullscreenMode);				
			}
		}
	}
	
	return fiddleEditor;
	
});