function closelayer(layer,section){
 document.getElementById("layer"+layer).style.visibility="hidden";
}
function openlayer(layer,section){
 document.getElementById("layer"+layer).style.visibility="visible";
}


function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}
function WriteCookie (cookieName, cookieValue, expiry) 
{
var expDate = new Date();
	if(expiry){
		expDate.setTime (expDate.getTime() + expiry);
		document.cookie = cookieName + "=" + escape (cookieValue) + "; expires=" + expDate.toGMTString() + "; path=/";
	}
	else{
		document.cookie = cookieName + "=" + escape (cookieValue);
	}
}
function buy_products(a){
new_win(500,400,'new_window');
document.products_products.target='new_window';
document.products_products.prod_id.value=a;
document.products_products.submit();}
function new_win(w,h,name) { w1=window.open('',name,'resizable=no,menubar=no,status=no,scrollbars=yes,width='+w+',height='+h);}
function buys_products(){
if(!CheckSelect(document.products_products)) return false;
new_win(500,400,'new_window');
document.products_products.target='new_window';
document.products_products.submit();}
function product_products(a){
/*document.get_product_products.product_id_products.value=a;
document.get_product_products.submit();*/self.location.href="/products.php?id_toc=436&id_cur_toc=346&op_toc=0&product_id_products="+a+"&page_products=1"}
function ToggleAll(e) {if (e.checked) CheckAll(); else ClearAll();}
function CheckAll() {var ml = document.products_products; var len =ml.elements.length; for (var i = 0; i < len; i++) { var e = ml.elements[i]; if (e.name == "prid"){Check(e);}}ml.toggleAll.checked = true;}
function ClearAll(){var ml = document.products_products;var len =ml.elements.length;for (var i = 0; i < len; i++) { var e = ml.elements[i]; if (e.name == "prid"){Clear(e);}}ml.toggleAll.checked = false;}
function Check(e) {e.checked = true;}
function Clear(e){e.checked = false;}
function CheckSelect(form){var res =false; var f=false;
form.prod_id.value="";
for (i = 0; i < form.elements.length; i++){var item = form.elements[i]; if (item.name == "prid") {if (item.checked){res= true; if(f)form.prod_id.value+=","; else f=true; form.prod_id.value +=item.value;}} } if(!res) alert("­Ґ ўлЎа ­л Їа®¤гЄвл");return res;}



function getCoords(e){
	
	var posx = 0;
	var posy = 0;
	
	if (!e) var e = window.event;
	
	if (e.pageX || e.pageY) {

		posx = e.pageX;
		posy = e.pageY;
		
	} else if (e.clientX || e.clientY) {
		
		posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
		
	}
	
	return {x:posx, y:posy};
	
}

function showHelp(id, e, obj) {
	
	var div  = document.getElementById(id);
	
	div.style.display = 'block';
	div.style.top     = getCoords(e).y;
	div.style.left    = getCoords(e).x;
	obj.onblur = function() { hiddenHelp(id) };
	
	setTimeout("hiddenHelp('" + id + "')", 5000);
	
	return false;
	
}

function hiddenHelp(id) {
	var div = document.getElementById(id);
	div.style.display = 'none';
}

function addEngine(){
        if ((typeof window.sidebar == "object") && (typeof window.sidebar.addSearchEngine == "function")) {
                window.sidebar.addSearchEngine('http://search.brownbear.ru/bbsidebar.src', 'http://search.brownbear.ru/i/favicon.gif', 'BrownBear', '0');
        } else {
                alert("Извините, чтобы установить плагин поиска, Вы должны использовать браузер Firefox.");
        }
        return false;
}

function fade(sElemId, sRule, bBackward)
{
  if (!document.getElementById(sElemId)) return;
  var aRuleList = sRule.split(/\s*,\s*/);
  for (var j  = 0; j < aRuleList.length; j++)
  {
    sRule = aRuleList[j];
    
    if (!fade.aRules[sRule]) continue;
    var i=0;
    if (!fade.aProc[sElemId])
    {
      fade.aProc[sElemId] = {};
    }
    else if (fade.aProc[sElemId][sRule])
    {
      i = fade.aProc[sElemId][sRule].i;
      clearInterval(fade.aProc[sElemId][sRule].tId);
    }
    
    if ((i==0 && bBackward) || (i==fade.aRules[sRule][3] && !bBackward)) continue;
    fade.aProc[sElemId][sRule] = {'i':i, 'tId':setInterval('fade.run("'+sElemId+'","'+sRule+'")', fade.aRules[sRule][4]),'bBackward':Boolean(bBackward)};
  }
}
fade.aProc = {};
fade.aRules = {};

fade.run = function(sElemId, sRule)
{
  fade.aProc[sElemId][sRule].i += fade.aProc[sElemId][sRule].bBackward?-1:1;
  var finishPercent = fade.aProc[sElemId][sRule].i/fade.aRules[sRule][3];
  var startPercent = 1 - finishPercent;
  var aRGBStart = fade.aRules[sRule][0];
  var aRGBFinish = fade.aRules[sRule][1];
  document.getElementById(sElemId).style[fade.aRules[sRule][2]] = 'rgb('+ 
  Math.floor( aRGBStart['r'] * startPercent + aRGBFinish['r'] * finishPercent ) + ','+
  Math.floor( aRGBStart['g'] * startPercent + aRGBFinish['g'] * finishPercent ) + ','+
  Math.floor( aRGBStart['b'] * startPercent + aRGBFinish['b'] * finishPercent ) +')';
  
  if ( fade.aProc[sElemId][sRule].i == fade.aRules[sRule][3] || fade.aProc[sElemId][sRule].i ==0) clearInterval(fade.aProc[sElemId][sRule].tId); 
}

fade.back = function (sElemId, sRule){fade(sElemId, sRule, true);};
fade.addRule = function (sRuleName, sFadeStartColor, sFadeFinishColor, sCSSProp, nMiddleColors, nDelay)
{
  fade.aRules[sRuleName] = [fade.splitRGB(sFadeStartColor), fade.splitRGB(sFadeFinishColor), fade.ccs2js(sCSSProp), nMiddleColors || 50, nDelay || 1];
};

fade.splitRGB = function (color){var rgb = color.replace(/[# ]/g,"").replace(/^(.)(.)(.)$/,'$1$1$2$2$3$3').match(/.{2}/g); for (var i=0;  i<3; i++) rgb[i] = parseInt(rgb[i], 16); return {'r':rgb[0],'g':rgb[1],'b':rgb[2]};};
fade.ccs2js = function (prop){var i; while ((i=prop.indexOf("-"))!=-1) prop = prop.substr(0, i) + prop.substr(i+1,1).toUpperCase() + prop.substr(i+2); return prop;};

fade.addRule('fadeRule1',"#fff","#eaeaea", "background-color", 50, 1);
fade.addRule('fadeRule2',"#e8e8e8","#ffb802", "border-color", 60, 2);
fade.addRule('fadeRule3',"#FFF","#929292", "color", 50, 1);
window.onload = function() {fileLinks();}
