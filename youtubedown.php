<?php 

$rgVerifyAge = 'verify-age-thumb';
$rgCaptcha = 'das_captcha';
$rgTitle = '/(.*) – YouTube/';
$rgEncoded = '/stream_map=(.[^&]*?)&/i';
$rgLink = '/^(.*?)\\\\u0026/';
# $rgLink = Regexp.new(/url=.*\\u0026/);

// $youtubepath = 'http://www.youtube.com/watch?v=6tWLqFmaNdQ';
$youtubepath = 'http://www.youtube.com/watch?v=Kk6HpPnsU74';
// $youtubepath = 'http://www.youtube.com/watch?v=D-iT8lPvwyE';
echo "Fetching HTML Source From YouTube";
$html = file_get_contents($youtubepath);
echo "HTML Source Fetch Done!";
if(strstr($html,$rgVerifyAge))
{
	echo 'Adult Video, Stop';
	exit;
}

if(strstr($html,$rgCaptcha))
{
	echo 'Captcah Requested';
	exit;
}

if(!preg_match($rgEncoded,$html,$vidEncodedSrc))
{
	echo 'Download URL not found';
	exit;
}

// print_r($vidEncodedSrc);
// exit;

$vidDecodedSrc = urldecode($vidEncodedSrc[1]);

if(preg_match($rgLink,$vidDecodedSrc,$vidLinks))
{
	$vidDecodedSrc = $vidLinks[1];
}

// print_r($vidDecodedSrc);
// exit;

$urls = explode(',',$vidDecodedSrc);
$foundLinks = array();

foreach($urls as $url)
{
	$uc=explode('&',$url);
	$um=explode('=',$uc[1]);
	$ul=explode('=',$uc[0]);
	$si=explode('=',$uc[4]);
	$u = urldecode(urldecode($um[1]));
	$foundLinks[$ul[1]]=$u.'&signature='.$si[1];
}

// print_r($foundArray);
// exit;

if(!preg_match($rgTitle,$html,$vidTitle)){
	$vidTitle[0]='YouTube Video';
}

$formats = array(
	'13'=>array('3gp','Low Quality'),
	'17'=>array('3gp','Medium Quality'),
	'36'=>array('3gp','High Quality'),
	'5'=>array('flv','Low Quality'),
	'6'=>array('flv','Low Quality'),
	'34'=>array('flv','High Quality (320p)'),
	'35'=>array('flv','High Quality (480p)'),
	'18'=>array('mp4','High Quality (480p)'),
	'22'=>array('mp4','High Quality (720p)'),
	'37'=>array('mp4','High Quality (1080p)'),
	);

foreach ($formats as $format => $meta) {
	if (isset($foundLinks[$format])) {
		$vidFile[$format] = array('ext' => $meta[0], 'type' => $meta[1], 'url' => $foundLinks[$format].'&title='.$vidTitle[0]);
	}
}

print_r($vidFile);
// return $videos;
// download($vidDownloadLink,$vidFileName)

 ?>