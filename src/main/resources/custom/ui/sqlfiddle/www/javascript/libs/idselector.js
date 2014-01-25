(function () {
    function gen_selector() {
        var quirksMode = document.compatMode != 'CSS1Compat';
        
        function log(msg) {
            if (window.console) {window.console.log('ID Selector: ' + msg);}
        }
        
        function readCookie(name) {
            var nameEQ = name + "=";
            var ca = document.cookie.split(';');
            for(var i=0;i < ca.length;i++) {
                var c = ca[i];
                while (c.charAt(0)==' ') c = c.substring(1,c.length);
                if (c.indexOf(nameEQ) == 0)
                    return decodeURIComponent(c.substring(nameEQ.length,c.length));
            }
            return null;
        }
        var openidCookie = readCookie('__openid_selector_openid');
        var opIdCookie = readCookie('__openid_selector_op_id');
        var unameCookie = readCookie('__openid_selector_uname');

        var s;
        var providers = [
            {
                "shortname": "myOpenID",
                "url_suffix": ".myopenid.com/",
                "openid1": true,
                "openid2": true,
                "id": 8,
                "icon": "-27px -326px",
                "url_prefix": "http://",
                "website": "https://www.myopenid.com/",
                "longname": "myOpenID",
                "usercalled": "username"
            },
            {
                "shortname": "claimID",
                "url_suffix": "",
                "openid1": true,
                "openid2": false,
                "id": 4,
                "icon": "-1px -326px",
                "url_prefix": "http://claimid.com/",
                "website": "http://claimid.com/",
                "longname": "claimID",
                "usercalled": "username"
            },
            {
                "shortname": "Clickpass",
                "url_suffix": "",
                "openid1": true,
                "openid2": true,
                "id": 5,
                "icon": "-1px -274px",
                "url_prefix": "http://clickpass.com/public/",
                "website": "http://www.clickpass.com/",
                "longname": "Clickpass",
                "usercalled": "username"
            },
            {
                "shortname": "Wordpress",
                "url_suffix": ".wordpress.com/",
                "openid1": true,
                "openid2": false,
                "id": 14,
                "icon": "-1px -404px",
                "url_prefix": "http://",
                "website": "http://www.wordpress.com/",
                "longname": "Wordpress",
                "usercalled": "username"
            },
            {
                "shortname": "Blogger",
                "url_suffix": ".blogspot.com/",
                "openid1": true,
                "openid2": false,
                "id": 2,
                "icon": "-1px -249px",
                "url_prefix": "http://",
                "website": "http://www.blogger.com/",
                "longname": "Google Blogger",
                "usercalled": "blog name"
            },
            {
                "shortname": "Livejournal",
                "url_suffix": ".livejournal.com/",
                "openid1": true,
                "openid2": false,
                "id": 7,
                "icon": "-1px -352px",
                "url_prefix": "http://",
                "website": "http://www.livejournal.com/",
                "longname": "Livejournal",
                "usercalled": "username"
            },
            {
                "shortname": "Google",
                "url_suffix": "",
                "openid1": false,
                "openid2": true,
                "id": 26,
                "icon": "-27px -274px",
                "url_prefix": "",
                "website": "https://www.google.com/accounts/o8/id",
                "longname": "Google",
                "usercalled": "username"
            },
            {
                "shortname": "Yahoo!",
                "url_suffix": "",
                "openid1": false,
                "openid2": true,
                "id": 15,
                "icon": "-27px -300px",
                "url_prefix": "http://me.yahoo.com/",
                "website": "http://yahoo.com/",
                "longname": "Yahoo!",
                "usercalled": "yahoo id"
            },
            {
                "shortname": "AOL",
                "url_suffix": "",
                "openid1": true,
                "openid2": false,
                "id": 1,
                "icon": "-27px -249px",
                "url_prefix": "http://openid.aol.com/",
                "website": "http://www.aol.com/",
                "longname": "America Online/AIM",
                "usercalled": "screenname"
            }
        ];
  
        var oidTbId = window.idselector_input_id ? window.idselector_input_id : "openid_identifier";
        var oidTb = document.getElementById(oidTbId);
        if (oidTb == null) {
            log('couldn\'t find openid input box with id = ' + oidTbId);
            for (i = 0; !oidTb && i < document.forms.length; i++) {
                oidTb = document.forms[i].openid_identifier;}
            for (i = 0; !oidTb && i < document.forms.length; i++) {
                oidTb = document.forms[i].openid_url;}
        }
        
        if (oidTb == null) {log('couldn\'t find openid input box'); return;}
        var orig = oidTb.value;


        var btnMkr = document.createElement('div');
        btnMkr.innerHTML = "<button type=\"button\"></button>";
                
        var btn = btnMkr.firstChild;
        btnMkr.removeChild(btn);
	    btn.id = '__idselector_button';
        btn.style.cursor = "pointer";
        btn.style.background = "#fff url(http://cdn.sstatic.net/Img/openid/openid-logos.png?v=8)";
        btn.style.backgroundPosition = "-27px -404px";
        btn.style.width = "27px";
        btn.style.height = "27px";
        

        var popup = document.createElement('iframe');
        popup.frameBorder = 0; popup.scrolling = 'no';
        s = popup.style; s.display = 'none'; s.position = 'absolute';
        s.width = '400px'; s.height = '0px'; s.margin = '0px'; s.padding = '0px'; s.zIndex = 10000;
        s.border = '0px';

        var prnt = oidTb.parentNode;
        var target = null;
        if (window.idselector_target_id) {
            target = document.getElementById(window.idselector_target_id);
            if (!target) {log("couldn't find element with id " + window.idselector_target_id);}
        }
        if (target) {
            target.insertBefore(btn, target.firstChild);
        } else {
            prnt.insertBefore(btn, oidTb.nextSibling);
            prnt.insertBefore(document.createTextNode(" "), btn);
        }
        document.body.appendChild(popup);

        var pdoc = popup.contentWindow.document;
        pdoc.open();
        pdoc.write('<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\"><html><head><title>ID Selector</title><style type=\"text/css\">html{color:#000;background:#6e91af;}body,div,dl,dt,dd,ul,ol,li,h1,h2,h3,h4,h5,h6,pre,code,form,fieldset,legend,input,textarea,p,blockquote,th,td{margin:0;padding:0;}table{border-collapse:collapse;border-spacing:0;}fieldset,img{border:0;}address,caption,cite,code,dfn,em,strong,th,var{font-style:normal;font-weight:normal;}li{list-style:none;}caption,th{text-align:left;}h1,h2,h3,h4,h5,h6{font-size:100%;font-weight:normal;}q:before,q:after{content:\'\';}abbr,acronym {border:0;font-variant:normal;}sup {vertical-align:text-top;}sub {vertical-align:text-bottom;}input,textarea,select{font-family:inherit;font-size:inherit;font-weight:inherit;}input,textarea,select{*font-size:100%;}legend{color:#000;}body {border:1px solid #6e91af;font:13px/1.231 arial,helvetica,clean,sans-serif;*font-size:small;*font:x-small;}table {font-size:inherit;font:100%;}pre,code,kbd,samp,tt{font-family:monospace;*font-size:108%;line-height:100%;}</style></head><body></body></html>');
        pdoc.close();

        var pbody = pdoc.body;
 

        var headRight = pdoc.createElement('div');
        headRight.style[document.all ? 'styleFloat' : 'cssFloat'] = 'right';
        headRight.innerHTML = '<a href="https://www.myopenid.com/signup?affiliate_id=21239" style="color:#fff;" target="_blank">Get an OpenID</a>';

        var header = pdoc.createElement('div');
        s = header.style; s.fontWeight = "bold"; s.color = "#fff";
        s.padding = "2px 8px 2px 8px";

        header.appendChild(headRight);
        header.appendChild(pdoc.createTextNode("Sign in with OpenID using"));

        var nameLabel = pdoc.createElement('span');
        nameLabel.appendChild(pdoc.createTextNode("xxx:"));

        var nameTb = pdoc.createElement('input');
        nameTb.type = "text";
        nameTb.size = 20;
        s = nameTb.style; 
        s.height = '24px';
        s.marginLeft = 0;
        s.paddingLeft = 0;

        var footer = pdoc.createElement('div');
        s = footer.style;
        s.color = "#fff";
        s.padding = "2px 8px 2px 8px";
        s.textAlign = "right";
        s.position = "relative";

        var nameIcon = pdoc.createElement("div");

        nameIcon.style.background = "#fff url(http://cdn.sstatic.net/Img/openid/openid-logos.png?v=8)";

        nameIcon.style.display = "inline-block";
        nameIcon.style.width = "24px";
        nameIcon.style.height = "24px";
        nameIcon.style.verticalAlign = "top";
        nameIcon.style.borderStyle = "inset";
        nameIcon.style.borderWidth = "2px 0 2px 2px";
        nameIcon.style.visibility = "hidden";


        footer.appendChild(nameLabel);
        footer.appendChild(nameIcon);
        //footer.appendChild(pdoc.createTextNode(" "))
            footer.appendChild(nameTb);

        function Cell(grid, idx) {
            this.grid = grid;
            this.idx = idx;

            var td = this.td = pdoc.createElement('td');
            s = td.style;
            s.fontWeight = "bold";
            s.padding = "4px";
            s.verticalAlign = "middle";
            s.cursor = "pointer";

            var _this = this;
            td.onmouseover = function () {
                _this.onMouseOver();
            }
            td.onmouseout = function () {
                _this.onMouseOut();
            }
            td.onclick = function () {
                _this.onClick();
            }

            var provider = providers[idx];
            var icon = pdoc.createElement("div");

            icon.style.background = "#fff url(http://cdn.sstatic.net/Img/openid/openid-logos.png?v=8)";

            icon.style.backgroundPosition = provider ? provider.icon : "-27px -404px";
            icon.style.display = "inline-block";
            icon.style.width = "24px";
            icon.style.height = "24px";
            icon.style.verticalAlign = "middle";

            td.appendChild(icon);
            td.appendChild(pdoc.createTextNode(" "));
            td.appendChild(pdoc.createTextNode(provider ? provider.shortname : "Other OpenID"));

            this.selected = false;
        }

        _id = Cell.prototype = {};
        _id.onMouseOver = function () {
            if (!this.selected) {
                this.td.style.backgroundColor = "#eee";
            }
        }
        _id.onMouseOut = function () {
            if (!this.selected) {
                this.td.style.backgroundColor = "";
            }
        }
        _id.onClick = function () {
            this.grid.select(this);
            provider = providers[this.idx];
            if (this.idx == -1) {
                oidTb.value = 'http://';
                oidTb.focus();
            } else {
                if (provider["openid2"] && !provider["openid1"]) {
                    oidTb.focus();
                    setTimeout(hidePopup, 1);
                } else {
                    nameTb.focus();
                    nameTb.select();
                }
            }
        }

        _id.setSelected = function (selected) {
            this.td.style.backgroundColor = selected ? '#c6d9e8' : "";
            this.selected = selected;
        }

        function Grid() {
            this.table = pdoc.createElement('table');
            this.table.style.backgroundColor = "#FFF";
            this.table.style.width = "100%";
            this.table.style.border = "1px solid #6e91af";
            this.tbody = pdoc.createElement('tbody');
            this.table.appendChild(this.tbody);
            this.maxOffset = (Math.ceil(providers.length/12) - 1) * 12;
            this.cells = [];
            for (var i = 0; i < providers.length; i++) {
                this.cells[i] = new Cell(this, i);
            }

            this.rows = [pdoc.createElement('tr'), pdoc.createElement('tr'),
                         pdoc.createElement('tr'), pdoc.createElement('tr')];

            this.otherCell = new Cell(this, -1);
            var links = pdoc.createElement('td');
            links.style.padding = "4px";
            links.style.textAlign = "right";
            links.style.verticalAlign = "middle";
            links.colSpan = 2;
            links.innerHTML = '<a href="http://openid.net/" style="color:#6e91af;" target="_blank">Help</a>';

            var bottom_row = pdoc.createElement('tr');
            bottom_row.style.borderTop = "1px solid #AAA";
            bottom_row.appendChild(this.otherCell.td);
            bottom_row.appendChild(links);

            for (var j = 0; j < 4; j++) {this.tbody.appendChild(this.rows[j]);}
            this.tbody.appendChild(bottom_row);

            this.offset = 0;
        }

        _id = Grid.prototype = {};
        _id.forward = function() {
            this.offset = Math.min(this.offset + 12, this.maxOffset)
            this.gen();
        }
        _id.back = function() {
            this.offset = Math.max(this.offset - 12, 0)
            this.gen();
        }
        _id.gen = function() {
            for (var i = 0; i < 4; i++) {
                var row = this.rows[i];
                while (row.firstChild) {row.removeChild(row.firstChild);}
            }
            for (var i = 0; i < 12; i++) {
                var row = this.rows[Math.floor(i/3)];
                var cell = this.cells[this.offset + i];
                if (cell) {
                    row.appendChild(cell.td);
                } else {
                    row.appendChild(pdoc.createElement('td'));
                }
            }
            popup.style.height = (pbody.offsetHeight + 2) + "px";
        }

        _id.select = function (cell) {
            if (this.curr) {
                this.curr.setSelected(false);
            }

            this.curr = cell;
            cell.setSelected(true);
            if (cell.idx > -1) {
                var provider = providers[cell.idx];

                if (provider["openid2"] && !provider["openid1"]) {
                    nameLabel.style.visibility = 'hidden';
                    nameTb.style.visibility = 'hidden';
                    nameIcon.style.visibility = 'hidden';
                    nameIcon.style.display = 'none';
                    oidTb.value = provider['website'];
                } else {
                    nameLabel.style.visibility = '';
                    nameIcon.style.display = 'inline-block';
                    nameTb.style.visibility = '';
                    nameIcon.style.visibility = '';

                    nameLabel.removeChild(nameLabel.firstChild);
                    var s = pdoc.createTextNode(provider.longname + " " +
                                                provider.usercalled + ":");

                    nameLabel.appendChild(s);

                    nameIcon.style.backgroundPosition = provider ? provider.icon : "-27px -404px";

                    nameTb.style.borderLeftWidth = 0;
                    oidTb.value = provider.url_prefix + "username" +
                        provider.url_suffix;
                    nameTb.value = "username";
                }
                btn.style.backgroundPosition = provider ? provider.icon : "-27px -404px";
            } else {
                hidePopup();
                nameLabel.style.visibility = 'hidden';
                nameIcon.style.visibility = 'hidden';
                nameIcon.style.display = 'none';
                nameTb.style.visibility = 'hidden';
                btn.style.backgroundPosition = "-27px -404px";
            }
        }

        _id.setName = function (name) {
            var p = providers[this.curr.idx];
            oidTb.value = p.url_prefix + name + p.url_suffix;
        }

        var grid = new Grid();
        grid.gen();

        pbody.appendChild(header);
        pbody.appendChild(grid.table);
        pbody.appendChild(footer);

        function showPopup() {
            var scrolled = window.ActiveXObject ? (quirksMode ? document.body.scrollLeft : document.documentElement.scrollLeft) : window.pageXOffset;
            var viewportWidth = quirksMode ? document.body.clientWidth : document.documentElement.clientWidth;
            var xUpper = viewportWidth + scrolled - 401;
            var x = oidTb.offsetLeft;
            var y = oidTb.offsetTop;
            if (oidTb.clientTop) {
                y += oidTb.clientTop;
            } else if (document.defaultView &&
                       document.defaultView.getComputedStyle) {
                var cs = document.defaultView.getComputedStyle(oidTb, '');
                y += parseInt(cs.getPropertyValue('border-top-width'));
                y += parseInt(cs.getPropertyValue('border-bottom-width'));
            }
            
            var w = oidTb.offsetParent;
            while (w) {
                x += w.offsetLeft;
                y += w.offsetTop;
                if (w.clientLeft) {
                    x += w.clientLeft;
                    y += w.clientTop;
                } else if (document.defaultView &&
                           document.defaultView.getComputedStyle) {
            
                    var cs = document.defaultView.getComputedStyle(w, '');
                    y += parseInt(cs.getPropertyValue('border-top-width'));
                    x += parseInt(cs.getPropertyValue('border-left-width'));
                }
                w = w.offsetParent;
            }
            y = y + oidTb.offsetHeight;

            x = Math.max(Math.min(x, xUpper), 0);
            
            var s = popup.style; s.left = x + "px"; s.top = y + "px";
            s.display = 'block'; s.height = (pbody.offsetHeight + 2) + "px";
            var html = document.body.parentNode;
        }

        function hidePopup() {
            popup.style.display = 'none';
        }

        function cursorEnd(tb) {
            if (tb.isTextEdit) {
                var rng = tb.createTextRange();
                if (rng) {
                    rng.move("character", tb.value.length);
                    rng.select();
                }
            }
      
        }

        function oidFocus() {
            if (oidTb.value == "Click to Sign In") {
                oidTb.value = 'http://';
            }
            cursorEnd(oidTb);
            showPopup();
        }

        btn.onclick = function(e) {
            (popup.style.display == 'none') ? showPopup() : hidePopup();
            if (e) {e.cancelBubble = true;} /* safari */
            return false;
        }

        btn.onfocus = function () {
            btn.blur();
        }

        oidTb.onkeypress = function(e) {
            var key;
            if(window.event) {
                key = window.event.keyCode;
            } else if(e.which) {key = e.which;}
            if (key != 13 && key != 9) {
                grid.select(grid.otherCell);
            }
        }


        nameTb.onkeydown = function(e) {
            var key;
            if(popup.contentWindow.event) {
                key = popup.contentWindow.event.keyCode;
            } else if(e.which) {key = e.which;}
            if (key == 13 || key == 9) {
                setTimeout(function () {
                        oidTb.onfocus = oidFocus;
                        oidTb.focus();
                        setTimeout(hidePopup, 1);
                    }, 1);
            }
        }

        nameTb.onkeyup = function() {
            var val = this.value;
            if (!val) {
                val = "username";
                this.value = val;
                this.select();
            }
            grid.setName(val);
        }

        oldOnResize = window.onresize;
        window.onresize = function (evt) {
            try {
                if (popup.style.display == 'block') {
                    showPopup();
                }
            } finally {
                oldOnResize && oldOnResize(evt);
            }
        }

        oldOnScroll = window.onscroll;
        window.onscroll = function (evt) {
            try {
                if (popup.style.display == 'block') {
                    showPopup();
                }
            } finally {
                oldOnScroll && oldOnScroll(evt);
            }
        }

        if (opIdCookie) {
            var cell = null;
            for (var i = 0; i < providers.length; i++) {
                if (providers[i].id == opIdCookie) {
                    cell = grid.cells[i];
                }
            }

            if (cell) {
                grid.select(cell);
                nameTb.value = unameCookie;
            }
        }

        if (!grid.curr) {
            grid.select(grid.otherCell);
        }
        if (openidCookie) {
            oidTb.value = openidCookie;
        } else if (orig.length == 0) {
            oidTb.value = "Click to Sign In";
        }

        function createCookie(name,value,days) {
            if (days) {
                var date = new Date();
                date.setTime(date.getTime()+(days*24*60*60*1000));
                var expires = "; expires="+date.toGMTString();
            }
            else var expires = "";
            document.cookie = name+"="+encodeURIComponent(value)+expires+"; path=/";
        }

        oidTb.onfocus = oidFocus;


        var form = null;
        prnt = oidTb.parentNode;
        while (prnt && prnt.nodeType == 1) {
            if (prnt.nodeName == 'FORM') {
                form = prnt;
                break;
            }
            prnt = prnt.parentNode;
        }
        if (form) {
            var oldOnSubmit = form.onsubmit;
            form.onsubmit = function(evt) {
                try {
                    createCookie('__openid_selector_openid', oidTb.value, 365);
                    if (grid.curr.idx > -1) {
                        var opId = providers[grid.curr.idx].id;
                        createCookie('__openid_selector_op_id', opId, 365);
                        createCookie('__openid_selector_uname', nameTb.value, 365);
                    } else {
                        createCookie('__openid_selector_op_id','',-1);
                        createCookie('__openid_selector_uname','',-1);
                    }
                } finally {
                    if (oldOnSubmit) {
                        return oldOnSubmit(evt);
                    }
                }
            };
        }

        if (window.ActiveXObject) {
            document.body.parentNode.attachEvent('onclick', function() {
                    if (window.event.srcElement != oidTb &&
                        window.event.srcElement != btn) {
                        hidePopup();
                    }
                });
        } else {
            document.body.parentNode.addEventListener('click', function(evt) {
                    if (evt.target != oidTb && evt.target != btn) {hidePopup();}
                }, false);
        }
    }
    
    var oldOnLoad = window.onload;
    window.onload = function(evt) {
        try {
            gen_selector();
        } finally {
            return oldOnLoad && oldOnLoad(evt);
        }
    }
})();