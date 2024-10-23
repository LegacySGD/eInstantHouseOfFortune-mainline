<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable">
<lxslt:script lang="javascript">
					
var debugFeed = [];
var debugFlag = false;
// Format instant win JSON results.
// @param jsonContext String JSON results to parse and display.
// @param translation Set of Translations for the game.
function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc) {
	var scenario = getScenario(jsonContext);
	var lines = getGridSymbols(scenario, 0);
	var outcomePrizes = getPrizeValues(scenario, 1);
	var prizeNames = (prizeNamesDesc.substring(1)).split(',');
	var convertedPrizeValues = (prizeValues.substring(1)).split('|');
	var r = [];
	r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
	r.push('&lt;tr&gt;');
	r.push('&lt;tr&gt;');
	r.push('&lt;td class="tablehead" width="50%"&gt;');
	r.push(getTranslationByName("boardSymbols", translations));
	r.push('&lt;/td&gt;');
	r.push('&lt;td class="tablehead" width="50%"&gt;');
	r.push(getTranslationByName("boardValues", translations));
	r.push('&lt;/td&gt;');
	r.push('&lt;/tr&gt;');
	for (var i = 0; i &lt; lines.length; ++i) {
		r.push('&lt;tr&gt;');
		r.push('&lt;td class="tablebody" width="50%"&gt;');
		if (checkLineWin(lines[i])) {
			r.push(getTranslationByName("lineWin", translations) + " : ");
		}
//		r.push(translateOutcomeNumber(lines[i], checkMultiplier(lines[i]), translations));
		r.push(lines[i]);
		r.push('&lt;/td&gt;');
		r.push('&lt;td class="tablebody" width="50%"&gt;');
		r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, outcomePrizes[i])] + checkMultiplier(lines[i]));
		r.push('&lt;/td&gt;');
		r.push('&lt;/tr&gt;');
	}
	r.push('&lt;/table&gt;');
	/////////////////////////////////////////////////////////////////////////////////////////
	// !DEBUG OUTPUT TABLE
	if (debugFlag) {
		r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
		for (var idx = 0; idx &lt; debugFeed.length; ++idx) {
			if (debugFeed[idx] == "")
				continue;
			r.push('&lt;tr&gt;');
			r.push('&lt;td class="tablebody"&gt;');
			r.push(debugFeed[idx]);
			r.push('&lt;/td&gt;');
			r.push('&lt;/tr&gt;');
		}
		r.push('&lt;/table&gt;');
	}
	return r.join('');
}
function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint) {
	var pricePointList = pricePoints.split(",");
	var prizeStructStrings = prizeStructures.split("|");
	for (var i = 0; i &lt; pricePoints.length; ++i) {
		if (wageredPricePoint == pricePointList[i]) {
			return prizeStructStrings[i];
		}
	}
	return "";
}
function getScenario(jsonContext) {
	// Parse json and retrieve scenario string.
	var jsObj = JSON.parse(jsonContext);
	var scenario = jsObj.scenario;
	// Trim null from scenario string.
	scenario = scenario.replace(/\0/g, '');
	return scenario;
}
function getPricePoint(jsonContext) {
	// Parse json and retrieve price point amount
	var jsObj = JSON.parse(jsonContext);
	var pricePoint = jsObj.amount;
	return pricePoint;
}
function getWinningNumbers(scenario) {
	var numsData = scenario.split("|")[0];
	return numsData.split(",");
}
function getGridSymbols(scenario, index) {
	var outcomeDatas = scenario.split("|")[index].split(",");
	var lineIdxesArr = [[2, 4, 6], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [6, 7, 8], [3, 4, 5], [0, 1, 2]];
	var result = [];
	for (var aIdx = 0; aIdx &lt; lineIdxesArr.length; aIdx++) {
		var lineIdxes = lineIdxesArr[aIdx];
		var line = [];
		for (var bIdx = 0; bIdx &lt; lineIdxes.length; bIdx++) {
			line.push(outcomeDatas[lineIdxes[bIdx]]);
		}
		result.push(line);
	}
	return result;
}
function getPrizeValues(scenario, index) {
	var outcomeDatas = scenario.split("|")[index].split(",");
	var result = [];
	for (var idx = 0; idx &lt; outcomeDatas.length; idx++) {
		result.push(outcomeDatas[idx]);
	}
	return result;
}
function parseMultiplier(symbol0, symbol1, symbol2) {
	var multiplier = null;
	if (parseInt(symbol0)) {
		multiplier = symbol0;
	} else if (parseInt(symbol1)) {
		multiplier = symbol1;
	} else if (parseInt(symbol2)) {
		multiplier = symbol2;
	}
	return multiplier;
}
function checkMultiplier(line) {
	var symbol0 = line[0];
	var symbol1 = line[1];
	var symbol2 = line[2];
	if (symbol0 == symbol1 || symbol0 == symbol2 || symbol1 == symbol2) {
		var multiplier = parseMultiplier(symbol0, symbol1, symbol2);
		if (!multiplier) {
			return "";
		}
		var result = "";
		if (multiplier == "1") {
		} else if (multiplier == "2") {
			result = "(2x)";
		} else if (multiplier == "3") {
			result = "(3x)";
		} else if (multiplier == "4") {
			result = "(4x)";
		}
		return result;
	}
	return "";
}
function checkLineWin(line) {
	var symbol0 = line[0];
	var symbol1 = line[1];
	var symbol2 = line[2];
	if (symbol0 == symbol1 &amp;&amp; symbol0 == symbol2) {
		return true;
	}
	if (symbol0 == symbol1 || symbol0 == symbol2 || symbol1 == symbol2) {
		if (parseMultiplier(symbol0, symbol1, symbol2)) {
			return true;
		}
	}
	return false;
}
function getPrizeNameIndex(prizeNames, currPrize) {
	for (var i = 0; i &lt; prizeNames.length; ++i) {
		if (prizeNames[i] == currPrize) {
			return i;
		}
	}
}
function getTranslationByName(keyName, translationNodeSet) {
	var index = 1;
	while (index &lt; translationNodeSet.item(0).getChildNodes().getLength()) {
		var childNode = translationNodeSet.item(0).getChildNodes().item(index);
		if (childNode.name == "phrase" &amp;&amp; childNode.getAttribute("key") == keyName) {
			return childNode.getAttribute("value");
		}
		index += 1;
	}
}
function registerDebugText(debugText) {
	debugFeed.push(debugText);
}
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="History.Detail"/>
</xsl:if>
<xsl:if test="OutcomeDetail/Stage = 'Wager' and OutcomeDetail/NextStage = 'Wager'">
<xsl:call-template name="History.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="History.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeTable" select="lxslt:nodeset(//lottery)"/>
<xsl:variable name="convertedPrizeValues">
<xsl:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
</xsl:variable>
<xsl:variable name="prizeNames">
<xsl:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="prize" mode="PrizeValue">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="text()"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</xsl:template>
<xsl:template match="description" mode="PrizeDescriptions">
<xsl:text>,</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
