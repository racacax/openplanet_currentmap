<?php
/**
 * Script to get and send back players information for each group. Not a plugin file.
 */
function formatMilliseconds($milliseconds) {
    $seconds = floor($milliseconds / 1000);
    $minutes = floor($seconds / 60);
    $hours = floor($minutes / 60);
    $milliseconds = $milliseconds % 1000;
    $seconds = $seconds % 60;
    $minutes = $minutes % 60;
	if($hours >0) {
		$format = '%u:%02u:%02u.%03u';
		$time = sprintf($format, $hours, $minutes, $seconds, $milliseconds);
	} elseif($minutes > 0) {
		$format = '%02u:%02u.%03u';
		$time = sprintf($format, $minutes, $seconds, $milliseconds);
	} else {
		$format = '%u.%03u';
		$time = sprintf($format, $seconds, $milliseconds);
	}
    return rtrim($time, '0');
}
function generateSlugFrom($string)
{
    // Put any language specific filters here, 
    // like, for example, turning the Swedish letter "å" into "a"

    // Remove any character that is not alphanumeric, white-space, or a hyphen 
    $string = preg_replace('/[^a-z0-9\s\-]/i', '', $string);
    // Replace all spaces with hyphens
    $string = preg_replace('/\s/', '-', $string);
    // Replace multiple hyphens with a single hyphen
    $string = preg_replace('/\-\-+/', '-', $string);
    // Remove leading and trailing hyphens, and then lowercase the URL
    $string = strtolower(trim($string, '-'));

    return $string;
}
$json = @file_get_contents('php://input');
$data = @json_decode($json, true);
if(!isset($data['apiKey'])) {
	die;
}
$apiKey = generateSlugFrom($data['apiKey']);
if($apiKey == ""){
	die;
}
$filename = "playersData/".$apiKey.'.json'; // playersData directory needs to be created in the first place
$players = @json_decode(file_get_contents($filename), true);
if(!isset($players)) {
	$players = [];
}
if(isset($data['player'])) {
	$atGap = formatMilliseconds(abs($data['authorTime'] - $data['personalBest']));
	if($data['personalBest'] == 4294967295) {
		$atGap = "      /";
	}
	elseif($data['authorTime'] < $data['personalBest']) {
		$atGap = '$f00+'.$atGap.'$fff';
	} else {
		$atGap = "$0f0-".$atGap.'$fff';
	}
	if($data["tag"] == null) {
		$data["tag"] = "";
	}
	$players[$data['login']] = array("atGap"=>$atGap,"tag"=>$data["tag"],"player"=>$data['player'], "flag"=>$data["flag"], "map"=>$data["map"], "timestamp"=>strtotime("now"));
}
foreach($players as $key => $player) {
	if(strtotime("now") - $player["timestamp"] > 3600) {
		unset($players[$key]);
	}
}
file_put_contents($filename, json_encode($players));

echo json_encode(array_values($players));