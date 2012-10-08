/*!
 * jQuery Cookie Plugin
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2011, Klaus Hartl
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 */

(function(e){e.cookie=function(t,n,r){if(arguments.length>1&&(!/Object/.test(Object.prototype.toString.call(n))||n===null||n===undefined)){r=e.extend({},r);if(n===null||n===undefined)r.expires=-1;if(typeof r.expires=="number"){var i=r.expires,s=r.expires=new Date;s.setDate(s.getDate()+i)}return n=String(n),document.cookie=[encodeURIComponent(t),"=",r.raw?n:encodeURIComponent(n),r.expires?"; expires="+r.expires.toUTCString():"",r.path?"; path="+r.path:"",r.domain?"; domain="+r.domain:"",r.secure?"; secure":""].join("")}r=n||{};var o=r.raw?function(e){return e}:decodeURIComponent,u=document.cookie.split("; ");for(var a=0,f;f=u[a]&&u[a].split("=");a++)if(o(f[0])===t)return o(f[1]||"");return null}})(jQuery)